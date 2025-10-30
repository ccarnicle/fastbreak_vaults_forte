import "BandOracleConnectors"

access(all) fun main() : &{Type: String} {
  return BandOracleConnectors.assetSymbols
}