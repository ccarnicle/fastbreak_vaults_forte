import "FlowToken"
import "FungibleToken"
import "FungibleTokenConnectors"
import "BandOracleConnectors"
import "aiSportsJuice"

transaction() {

  prepare(acct: auth(IssueStorageCapabilityController) &Account) {
    // Ensure we have an authorized capability for FlowToken (auth Withdraw)
    let storagePath = /storage/flowTokenVault
    let withdrawCap = acct.capabilities.storage.issue<auth(FungibleToken.Withdraw) &{FungibleToken.Vault}>(storagePath)

    // Fee source must PROVIDE FlowToken vaults (per PriceOracle preconditions)
    let feeSource = FungibleTokenConnectors.VaultSource(
      min: 0.0,                   // keep at least 0.0 FLOW in the vault
      withdrawVault: withdrawCap, // auth withdraw capability
      uniqueID: nil
    )

    // unitOfAccount must be a mapped symbol in BandOracleConnectors.assetSymbols.
    // The contract's init already maps FlowToken -> "FLOW", so this is valid.
    let oracle = BandOracleConnectors.PriceOracle(
      unitOfAccount: Type<@FlowToken.Vault>(), // quote token (e.g. FLOW in BASE/FLOW)
      staleThreshold: 600,                     // seconds; nil to skip staleness checks
      feeSource: feeSource,
      uniqueID: nil
    )

    // Note: Logs are only visible in the emulator console
    log("Created PriceOracle; unit: ".concat(oracle.unitOfAccount().identifier))
    log("Price: ".concat(oracle.price(ofToken: Type<@aiSportsJuice.Vault>())!.toString()))

  }
}
