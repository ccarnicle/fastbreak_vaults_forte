import Test

access(all) let account = Test.createAccount()

access(all) fun testContract() {
    let err = Test.deployContract(
        name: "FastbreakVaultsCloser",
        path: "../contracts/FastbreakVaultsCloser.cdc",
        arguments: [],
    )

    Test.expect(err, Test.beNil())
}