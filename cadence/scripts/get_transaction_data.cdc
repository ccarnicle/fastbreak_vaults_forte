import "FlowTransactionSchedulerUtils"
import "FlowTransactionScheduler"

access(all) fun main(address: Address): [UInt64] {

  var scheduledTransactions: [UInt64] = []

    let managerRef = FlowTransactionSchedulerUtils.borrowManager(at: address)
        ?? panic("Invalid address: Could not borrow a reference to the Scheduled Transaction Manager at address \(address)")

    //loop through the transaction IDs and get the transaction status
    for id in managerRef.getTransactionIDs() {
      let status = managerRef.getTransactionStatus(id: id)!
      if status == FlowTransactionScheduler.Status.Scheduled {
        scheduledTransactions.append(id)
      }
    } 
    return scheduledTransactions
}