import Test

access(all) let account = Test.createAccount()

access(all) fun testContract() {
    let err = Test.deployContract(
        name: "RickRoll",
        path: "../contracts/RickRoll.cdc",
        arguments: [],
    )

    Test.expect(err, Test.beNil())
}