import "FungibleToken"
import "TSHOT"
import "aiSportsJuice"
import "IncrementFiSwapConnectors"
import "aiSportsSwapper_V1"
import "MetadataViews"
import "FungibleTokenMetadataViews"

/// ------------------------------------------------------
/// Admin tx: Register TSHOT swapper with aiSportsSwapper_V1.SwapManager
/// ------------------------------------------------------
/// - Must be signed by the account that stores `SwapManager` at
///   /storage/aiSportsSwapperSwapManager_V1
/// - Adds the TSHOT storage vault path and its Swapper (TSHOT -> FLOW -> stFLOW -> JUICE)
///   so future swaps can convert TSHOT balances to JUICE
///
/// Notes:
/// - Uses the same path style as `swap_tshot_to_juice.cdc`.
/// - We resolve the TSHOT storage path from on-chain metadata (FTVaultData).

transaction() {
    prepare(acct: auth(BorrowValue, Storage) &Account) {
        // Borrow SwapManager from the signer's storage
        let manager = acct.storage.borrow<&aiSportsSwapper_V1.SwapManager>(from: /storage/aiSportsSwapperSwapManager_V1)
            ?? panic("Missing SwapManager at /storage/aiSportsSwapperSwapManager_V1")

        // Resolve TSHOT vault storage path via standard FT metadata view
        let tshotVaultData = TSHOT.resolveContractView(
            resourceType: nil,
            viewType: Type<FungibleTokenMetadataViews.FTVaultData>()
        ) as! FungibleTokenMetadataViews.FTVaultData

        // Define path for IncrementFi router: TSHOT -> FLOW -> stFLOW -> JUICE
        let path: [String] = [
            "A.05b67ba314000b2d.TSHOT",
            "A.1654653399040a61.FlowToken",
            "A.d6f80565193ad727.stFlowToken",
            "A.9db94c9564243ba7.aiSportsJuice"
        ]

        // Construct the swapper for TSHOT -> JUICE
        let tshotToJuice = IncrementFiSwapConnectors.Swapper(
            path: path,
            inVault: Type<@TSHOT.Vault>(),
            outVault: Type<@aiSportsJuice.Vault>(),
            uniqueID: nil
        )

        // Register with the SwapManager
        manager.addTokenType(vaultStoragePath: tshotVaultData.storagePath, swapper: tshotToJuice)
    }
}


