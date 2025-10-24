import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"
import "RickRoll"
import "FlowToken"
import "FungibleToken"

access(all)
contract RickRollTransactionHandler {
    /// Handler resource that implements the Scheduled Transaction interface
    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {
        access(FlowTransactionScheduler.Execute) fun executeTransaction(id: UInt64, data: AnyStruct?) {
            switch (RickRoll.messageNumber) {
                case 0:
                    RickRoll.message1()
                case 1:
                    RickRoll.message2()
                case 2:
                    RickRoll.message3()
                case 3:
                    return
                default:
                    panic("Invalid message number")
            }

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
            if RickRollTransactionHandler.account.storage.borrow<&AnyResource>(from: /storage/RickRollTransactionHandler) == nil {
                let handler <- RickRollTransactionHandler.createHandler()
                RickRollTransactionHandler.account.storage.save(<-handler, to: /storage/RickRollTransactionHandler)

                // Issue a non-entitled public capability for the handler that is publicly accessible
                let publicCap = RickRollTransactionHandler.account.capabilities.storage
                    .issue<&{FlowTransactionScheduler.TransactionHandler}>(/storage/RickRollTransactionHandler)

                // publish the capability
                RickRollTransactionHandler.account.capabilities.publish(publicCap, at: /public/RickRollTransactionHandler)
            }

            let vaultRef = RickRollTransactionHandler.account.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("missing FlowToken vault on contract account")
            let feesVault <- vaultRef.withdraw(amount: estimate.flowFee ?? 0.0) as! @FlowToken.Vault
            
            // borrow a reference to the scheduled transaction manager
            let manager = RickRollTransactionHandler.account.storage.borrow<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(from: FlowTransactionSchedulerUtils.managerStoragePath)
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
                    return /storage/RickRollTransactionHandler
                case Type<PublicPath>():
                    return /public/RickRollTransactionHandler
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
