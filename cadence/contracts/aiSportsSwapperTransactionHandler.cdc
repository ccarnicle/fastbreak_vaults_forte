import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"
import "aiSportsSwapper"
import "FlowToken"
import "FungibleToken"

access(all)
contract aiSportsSwapperTransactionHandler {
    /// Handler resource that implements the Scheduled Transaction interface
    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {
        access(FlowTransactionScheduler.Execute) fun executeTransaction(id: UInt64, data: AnyStruct?) {

            let tokenHolder = aiSportsSwapperTransactionHandler.account.address
            aiSportsSwapper.swapToJuice()
            
            var delay: UFix64 = 86400.0 // 1 day in seconds
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
            if aiSportsSwapperTransactionHandler.account.storage.borrow<&AnyResource>(from: /storage/aiSportsSwapperTransactionHandler) == nil {
                let handler <- aiSportsSwapperTransactionHandler.createHandler()
                aiSportsSwapperTransactionHandler.account.storage.save(<-handler, to: /storage/aiSportsSwapperTransactionHandler)

                // Issue a non-entitled public capability for the handler that is publicly accessible
                let publicCap = aiSportsSwapperTransactionHandler.account.capabilities.storage
                    .issue<&{FlowTransactionScheduler.TransactionHandler}>(/storage/aiSportsSwapperTransactionHandler)

                // publish the capability
                aiSportsSwapperTransactionHandler.account.capabilities.publish(publicCap, at: /public/aiSportsSwapperTransactionHandler)
            }

            let vaultRef = aiSportsSwapperTransactionHandler.account.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("missing FlowToken vault on contract account")
            let feesVault <- vaultRef.withdraw(amount: estimate.flowFee ?? 0.0) as! @FlowToken.Vault
            
            // borrow a reference to the scheduled transaction manager
            let manager = aiSportsSwapperTransactionHandler.account.storage.borrow<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(from: FlowTransactionSchedulerUtils.managerStoragePath)
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
                    return /storage/aiSportsSwapperTransactionHandler
                case Type<PublicPath>():
                    return /public/aiSportsSwapperTransactionHandler
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
