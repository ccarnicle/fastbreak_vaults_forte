/*
================================================================================
File: aiSportsSwapper.cdc
Project: aiSports - Flow Forte Hackathon Upgrade

Deployment & Operations Summary (PRODUCTION)
================================================================================

// OVERALL PURPOSE:
// This contract is executed by a Flow Scheduled Transaction. It converts the
// account's supported token balances into $JUICE using Increment.fi swap
// actions, retaining a small $FLOW reserve for fees. The resulting $JUICE
// remains in this account for downstream aiSports use.

// =============================================================================
// CURRENT STATUS (LIVE ON MAINNET)
// =============================================================================
// - Contracts deployed to production account 0x254b32edc33e5bc3:
//   - aiSportsSwapper
//   - aiSportsSwapperTransactionHandler
// - Scheduled transactions are live on mainnet and execute as configured.
// - Core FLOW -> JUICE swap flow is stable; 0.5 $FLOW is retained for fees.
// - Multi-token swaps are supported. Initial additional token: TSHOT.

// =============================================================================
// NOTES
// =============================================================================
// - The architecture performs in-place swaps; proceeds remain in this account.
// - Use the helper scripts to inspect handler views and scheduled tx data.
// - Cancellation can be performed via CancelScheduledTransaction.cdc if needed.

// =============================================================================
// Accounts
// =============================================================================
// - Production/Mainnet: 0x254b32edc33e5bc3
// - Mainnet Test Account: 0x46df6b5eeec6103a

Flow CLI Deployment Commands: (current)
flow accounts add-contract cadence/contracts/aiSportsSwapper.cdc --network mainnet --signer mainnet     
flow accounts add-contract cadence/contracts/aiSportsSwapperTransactionHandler.cdc --network mainnet --signer mainnet
flow transactions send cadence/transactions/InitAiSportsSwapperTransactionHandler.cdc --network mainnet  --signer mainnet
//ADD TSHOT SWAPPER - if required
flow transactions send cadence/transactions/ScheduleAiSportsSwapper.cdc \                                    
  --network mainnet --signer mainnet \
  --args-json '[
    {"type":"UFix64","value":"1761403209.0"}, //change this to the required timestamp for the transaction to run
    {"type":"UInt8","value":"1"},
    {"type":"UInt64","value":"1000"},
    {"type":"Optional","value":null}
  ]'

*/

import "FungibleToken"
import "FlowToken"
import "FungibleTokenMetadataViews"
import "aiSportsJuice"
import "IncrementFiSwapConnectors"

access(all) contract aiSportsSwapper {

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
                if balance > 0.01 {
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
            aiSportsSwapper.tokenStorageVaultPaths.append(vaultStoragePath)
            aiSportsSwapper.swappers.append(swapper)
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
        self.SwapManagerStoragePath = /storage/aiSportsSwapperSwapManager
        self.account.storage.save(<-create SwapManager(), to: self.SwapManagerStoragePath)
    }
}