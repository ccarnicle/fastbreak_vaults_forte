import "FlowTransactionSchedulerUtils"
import "FlowToken"
import "FungibleToken"

transaction(transactionId: UInt64) {
    prepare(account: auth(BorrowValue, SaveValue, LoadValue) &Account) {

        // Borrow a reference to the manager
        let manager = account.storage.borrow<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(from: FlowTransactionSchedulerUtils.managerStoragePath)
            ?? panic("Could not borrow a Manager reference from \(FlowTransactionSchedulerUtils.managerStoragePath)")

        // Get the vault where the refund should be deposited
        let vault = account.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow FlowToken vault")

        // Cancel the transaction and deposit the refund
        vault.deposit(from: <-manager.cancel(id: transactionId))
    }
}
