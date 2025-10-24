import "RickRollTransactionHandler"
import "FlowTransactionScheduler"

transaction() {
    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Save a handler resource to storage if not already present
        if signer.storage.borrow<&AnyResource>(from: /storage/RickRollTransactionHandler) == nil {
            let handler <- RickRollTransactionHandler.createHandler()
            signer.storage.save(<-handler, to: /storage/RickRollTransactionHandler)

            // Validation/example that we can create an issue a handler capability with correct entitlement for FlowTransactionScheduler
            signer.capabilities.storage
                .issue<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>(/storage/RickRollTransactionHandler)

            // Issue a non-entitled public capability for the handler that is publicly accessible
            let publicCap = signer.capabilities.storage
                .issue<&{FlowTransactionScheduler.TransactionHandler}>(/storage/RickRollTransactionHandler)

            // publish the capability
            signer.capabilities.publish(publicCap, at: /public/RickRollTransactionHandler)

        }
    }
}
