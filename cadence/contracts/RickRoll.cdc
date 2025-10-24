access(all)
contract RickRoll {

    access(all) var messageNumber: UInt8

    init() {
        self.messageNumber = 0
    }

    // Reminder: Anyone can call these functions!
    access(all) fun message1() {
        log("Never gonna give you up")
        self.messageNumber = 1
    }

    access(all) fun message2() {
        log("Never gonna let you down")
        self.messageNumber = 2
    }

    access(all) fun message3() {
        log("Never gonna run around and desert you")
        self.messageNumber = 3
    }

    access(all) fun resetMessageNumber() {
        self.messageNumber = 0
    }
}
