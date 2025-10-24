import "FlowToken"
import "FungibleToken" 
import "MetadataViews"
import "FungibleTokenMetadataViews"

transaction() {
  prepare(user: auth(Storage, Capabilities) &Account) {
    let vaultData = FlowToken.resolveContractView(
      resourceType: nil, 
      viewType: Type<FungibleTokenMetadataViews.FTVaultData>()
    ) as! FungibleTokenMetadataViews.FTVaultData

    if user.storage.borrow<&FlowToken.Vault>(from: vaultData.storagePath) == nil {
      user.storage.save(
        <- FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>()), 
        to: vaultData.storagePath
      )

      // Issue a capability with the correct interface
      let receiverCap = user.capabilities.storage.issue<&{FungibleToken.Receiver}>(vaultData.storagePath)

      user.capabilities.publish(receiverCap, at: vaultData.receiverPath)
    }
  }
}