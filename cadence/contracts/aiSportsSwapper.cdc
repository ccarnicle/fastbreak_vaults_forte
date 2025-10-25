/*
================================================================================
File: FastBreakVaultsCloser.cdc
Project: aiSports - Flow Forte Hackathon Upgrade

Development Plan & Testing Strategy (REVISED)
================================================================================

// OVERALL GOAL:
// This contract is designed to be executed by a Flow Scheduled Transaction.
// Its ultimate purpose is to take the $FLOW prize pool from a completed
// FastBreak Vault, swap it for $JUICE using the Increment.fi DEX Action,
// and hold the $JUICE within this contract's account for eventual distribution
// or further use in the aiSports ecosystem.

// ==============================================================================
// CURRENT STATUS & VALIDATION
// ==============================================================================
// Development has been split into two parallel streams which are now ready for
// integration.

// 1. MAINNET SWAP LOGIC - VALIDATED:
//    - A prototype contract, `aiSportsSwapper`, has been successfully
//      deployed and tested directly on Mainnet (account 0x46df6b5eeec6103a).
//    - This version confirms the core swap logic using Increment.fi's Action
//      is fully functional.
//    - The contract correctly checks its own balance, retains 0.5 $FLOW for
//      gas, and swaps the remaining balance into $JUICE.
//    - The architecture has been simplified: swaps are in-place, and the
//      $JUICE remains in the contract's account, removing transfer steps.

// 2. SCHEDULED TRANSACTION LOGIC - VALIDATED ON EMULATOR:
//    - The logic for scheduling, querying, and canceling the transaction
//      has been fully developed and tested on the Flow Emulator.
//    - Helper scripts to manage the scheduled transaction lifecycle (especially
//      for cancellation during testing) are ready.

// ==============================================================================
// NEXT STEPS: INTEGRATION AND FINAL TESTING
// ==============================================================================
// The primary task is to combine the two validated components and test them
// together on Mainnet in a controlled environment.

// 1. IMPLEMENT BLOCK TIMESTAMP LOGIC:
//    - Finalize the Cadence code in the scheduling transaction
//      (`ScheduleFastBreakVaultsCloser.cdc`) & contract (`aiSportsSwapperTransactionHandler`)
//    - Correctly use `getCurrentBlock().timestamp` to calculate and set the
//      `startTime` and `interval` parameters for the job to ensure it runs
//      at the desired daily cadence.

// 2. Deploy Transaction Handler:
//    - Use the update block timestamp info to deploy the Transaction Handler to the Mainnet test account
//      (0x46df6b5eeec6103a)
//    - Verify on-chain that the job executes at the correct time and that the
//      $FLOW is successfully swapped to $JUICE.
//    - Use the get_transaction_data.cdc & cancellation tx (CancelScheduledTransaction.cdc) to find and stop the test job.

// 4. PRODUCTION DEPLOYMENT:
//    - Once the end-to-end test is successful, deploy the final, production-ready
//      contract to the primary aiSports account (0x254b32edc33e5bc3).
//    - Schedule the transaction to run once per day to automate the conversion
//      of FastBreak Vault payouts.

// ==============================================================================
// Account Notes:
// - LIVE Mainnet Account (Final Destination): 0x254b32edc33e5bc3
// - Test Mainnet Account (Current Testing): 0x46df6b5eeec6103a
*/

import "FungibleToken"
import "FlowToken"
import "FungibleTokenMetadataViews"
import "aiSportsJuice"
import "IncrementFiSwapConnectors"

access(all) contract aiSportsSwapper_V1 {

      access(all) let SwapManagerStoragePath: StoragePath

    //add an array of token types that we should scan and swap
    access(all) let tokenStorageVaultPaths: [StoragePath]
    access(all) let swappers: [IncrementFiSwapConnectors.Swapper]

    access(all) fun swapToJuice() {

        var vaultPathIndex = 0

        // Deposit JUICE into the token holder's JUICE receiver
        let juiceReceiver = self.account.capabilities.get<&{FungibleToken.Receiver}>(/public/aiSportsJuiceReceiver).borrow()
            ?? panic("Missing /public/aiSportsJuiceReceiver capability on signer")

        //loop through the array of token public vault paths and check the balance of each token
        for tokenStorageVaultPath in self.tokenStorageVaultPaths {
            let vaultRef = self.account.storage.borrow<auth(FungibleToken.Withdraw) &{FungibleToken.Vault}>(from:tokenStorageVaultPath) ?? panic("Vault not found")

            //check the type of the vault - if it is a Flow Token Vault, we need to keep some Flow tokens in the contract account for fees
            if vaultRef.getType() == Type<@FlowToken.Vault>() {
                let balance = vaultRef.balance

                if balance > 0.5 {
                    let balanceToSwap = balance - 0.5
                    let flowToWithdraw  <- vaultRef.withdraw(amount: balanceToSwap)
                
                    // Perform the swap; the swapper internally quotes amountOutMin
                    let juiceVault <- self.swappers[0].swap(quote: nil, inVault: <-flowToWithdraw)

                    juiceReceiver.deposit(from: <-juiceVault)
                }
            } else { //once we add more tokens, will need to add else logic here to swap
                let balance = vaultRef.balance
                if balance > 0.0 {
                    let balanceToSwap = balance
                    let tokenToWithdraw  <- vaultRef.withdraw(amount: balanceToSwap)
                    let juiceVault <- self.swappers[vaultPathIndex].swap(quote: nil, inVault: <-tokenToWithdraw)
                    juiceReceiver.deposit(from: <-juiceVault)

                }
            }
            vaultPathIndex = vaultPathIndex + 1
        }
    }

    access(all) resource SwapManager{
        //this function is called by the contract admin to add a token type to the array of tokens to add/swap
        access(all) fun addTokenType(vaultStoragePath: StoragePath, swapper: IncrementFiSwapConnectors.Swapper) {
            aiSportsSwapper_V1.tokenStorageVaultPaths.append(vaultStoragePath)
            aiSportsSwapper_V1.swappers.append(swapper)
        }
    }

    init() {
        let vaultData = FlowToken.resolveContractView(
            resourceType: nil, 
            viewType: Type<FungibleTokenMetadataViews.FTVaultData>()
            ) as! FungibleTokenMetadataViews.FTVaultData
        self.tokenStorageVaultPaths = [ vaultData.storagePath ]

        // Initialize with IncrementFi FLOW -> JUICE (via stFLOW) swapper
        // Provide concrete token vault types for validation against the path
        self.swappers = [IncrementFiSwapConnectors.Swapper(
            path: [
            "A.1654653399040a61.FlowToken",
            "A.d6f80565193ad727.stFlowToken",
            "A.9db94c9564243ba7.aiSportsJuice"
        ],
            inVault: Type<@FlowToken.Vault>(),
            outVault: Type<@aiSportsJuice.Vault>(),
            uniqueID: nil
        )]

        //create the swap manager resource
        self.SwapManagerStoragePath = /storage/aiSportsSwapperSwapManager_V1
        self.account.storage.save(<-create SwapManager(), to: self.SwapManagerStoragePath)
    }
}