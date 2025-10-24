import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"
import "FastbreakVaultsCloser"
import "FlowToken"
import "FungibleToken"

access(all)
contract FastbreakVaultsCloserTransactionHandler {
    /// Handler resource that implements the Scheduled Transaction interface
    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {
        access(FlowTransactionScheduler.Execute) fun executeTransaction(id: UInt64, data: AnyStruct?) {

            FastbreakVaultsCloser.testMessage()
            
            var delay: UFix64 = 5.0
            let future = getCurrentBlock().timestamp + delay
            let priority = FlowTransactionScheduler.Priority.Medium
            let executionEffort: UInt64 = 1000

            let estimate = FlowTransactionScheduler.estimate(
                data: data,
                timestamp: future,
                priority: priority,
                executionEffort: executionEffort
            )

            assert(
                estimate.timestamp != nil || priority == FlowTransactionScheduler.Priority.Low,
                message: estimate.error ?? "estimation failed"
            )

            // Ensure a handler resource exists in the contract account storage
            if FastbreakVaultsCloserTransactionHandler.account.storage.borrow<&AnyResource>(from: /storage/FastbreakVaultsCloserTransactionHandler) == nil {
                let handler <- FastbreakVaultsCloserTransactionHandler.createHandler()
                FastbreakVaultsCloserTransactionHandler.account.storage.save(<-handler, to: /storage/FastbreakVaultsCloserTransactionHandler)

                // Issue a non-entitled public capability for the handler that is publicly accessible
                let publicCap = FastbreakVaultsCloserTransactionHandler.account.capabilities.storage
                    .issue<&{FlowTransactionScheduler.TransactionHandler}>(/storage/FastbreakVaultsCloserTransactionHandler)

                // publish the capability
                FastbreakVaultsCloserTransactionHandler.account.capabilities.publish(publicCap, at: /public/FastbreakVaultsCloserTransactionHandler)
            }

            let vaultRef = FastbreakVaultsCloserTransactionHandler.account.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("missing FlowToken vault on contract account")
            let feesVault <- vaultRef.withdraw(amount: estimate.flowFee ?? 0.0) as! @FlowToken.Vault
            
            // borrow a reference to the scheduled transaction manager
            let manager = FastbreakVaultsCloserTransactionHandler.account.storage.borrow<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(from: FlowTransactionSchedulerUtils.managerStoragePath)
                ?? panic("Could not borrow a Manager reference from \(FlowTransactionSchedulerUtils.managerStoragePath)")

            let handlerTypeIdentifier = manager.getHandlerTypeIdentifiers().keys[0]

            manager.scheduleByHandler(
                handlerTypeIdentifier: handlerTypeIdentifier,
                handlerUUID: nil,
                data: data,
                timestamp: future,
                priority: priority,
                executionEffort: executionEffort,
                fees: <-feesVault
            )

        }

        access(all) view fun getViews(): [Type] {
                return [Type<StoragePath>(), Type<PublicPath>()]
            }

        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<StoragePath>():
                    return /storage/FastbreakVaultsCloserTransactionHandler
                case Type<PublicPath>():
                    return /public/FastbreakVaultsCloserTransactionHandler
                default:
                    return nil
            }
        }
    }


    /// Factory for the handler resource
    access(all) fun createHandler(): @Handler {
        return <- create Handler()
    }
}
