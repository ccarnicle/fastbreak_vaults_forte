import "FungibleToken"
import "TSHOT"
import "IncrementFiSwapConnectors"
import "aiSportsJuice"
import "MetadataViews"
import "FungibleTokenMetadataViews"

/// ------------------------------------------------------
/// Simple swap: JUICE -> TSHOT using IncrementFi SwapRouter
/// ------------------------------------------------------
/// Composition preference: Option B (swap and deposit)
/// - We withdraw an input amount of JUICE from the signer (passed as an arg)
/// - Use IncrementFiSwapConnectors.Swapper with path [JUICE -> stFLOW -> FLOW -> TSHOT]
/// - Deposit TSHOT back to the signer via their TSHOT receiver
///
/// Note on types: While generic interface types exist, IncrementFiSwapConnectors.Swapper
/// validates `inVault` and `outVault` against the path (address/contractName). Therefore,
/// we pass concrete token-specific vault types (`Type<@aiSportsJuice.Vault>`, `Type<@TSHOT.Vault>`).
///
/// Per request, we do not use SwapSource composition.

transaction(amount: UFix64) {
    /// Amount of JUICE to swap (provided by the caller)
    let amountInJuice: UFix64

    /// Temporary JUICE vault withdrawn from signer
    let juiceVault: @{FungibleToken.Vault}

    /// Router path for IncrementFi (JUICE -> stFLOW -> FLOW -> TSHOT)
    let path: [String]

    /// Keep signer address for deposit step
    let signerAddress: Address

    prepare(acct: auth(BorrowValue, Storage) &Account) {
        self.signerAddress = acct.address
        self.amountInJuice = amount

        // Resolve JUICE vault storage path from on-chain metadata
        let vaultData = aiSportsJuice.resolveContractView(
            resourceType: nil,
            viewType: Type<FungibleTokenMetadataViews.FTVaultData>()
        ) as! FungibleTokenMetadataViews.FTVaultData

        // Withdraw JUICE from the signer's aiSportsJuice vault
        let juiceVaultRef = acct.storage
            .borrow<auth(FungibleToken.Withdraw) &aiSportsJuice.Vault>(from: vaultData.storagePath)
            ?? panic("Missing aiSportsJuice vault at \(vaultData.storagePath)")
        self.juiceVault <- juiceVaultRef.withdraw(amount: self.amountInJuice)

        // Define the swap path using IncrementFi token key identifiers
        // JUICE (A.9db94c9564243ba7.aiSportsJuice) -> stFLOW (A.d6f80565193ad727.stFlowToken) -> FLOW (A.1654653399040a61.FlowToken) -> TSHOT (A.05b67ba314000b2d.TSHOT)
        self.path = [
            "A.9db94c9564243ba7.aiSportsJuice",
            "A.d6f80565193ad727.stFlowToken",
            "A.1654653399040a61.FlowToken",
            "A.05b67ba314000b2d.TSHOT"
        ]
    }

    execute {
        // Build the IncrementFi swapper (JUICE -> TSHOT via stFLOW and FLOW)
        // Provide concrete token vault types for validation against the path
        let swapper = IncrementFiSwapConnectors.Swapper(
            path: self.path,
            inVault: Type<@aiSportsJuice.Vault>(),
            outVault: Type<@TSHOT.Vault>(),
            uniqueID: nil
        )

        // Perform the swap; the swapper internally quotes amountOutMin
        let tshotVault <- swapper.swap(quote: nil, inVault: <-self.juiceVault)

        // Deposit TSHOT into the signer's TSHOT receiver
        let tshotReceiver = getAccount(self.signerAddress)
            .capabilities
            .get<&{FungibleToken.Receiver}>(/public/TSHOTTokenReceiver)
            .borrow()
            ?? panic("Missing /public/TSHOTTokenReceiver capability on signer")

        tshotReceiver.deposit(from: <-tshotVault)
    }
}


