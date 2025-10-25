import "aiSportsSwapper"

transaction() {
    prepare(signer: auth(BorrowValue, Storage) &Account) {
        // No-op: signing with the contract account satisfies access(account)
    }

    execute {
        aiSportsSwapper.swapToJuice()
    }
}