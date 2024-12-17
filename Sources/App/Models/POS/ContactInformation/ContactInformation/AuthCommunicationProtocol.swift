/// The protocol to follow for
protocol AuthCommunicationProtocol {
    var authed: Bool { get }
    var authComms: Bool { get }
    var authMarketing: Bool { get }
}

extension AuthCommunicationProtocol {
    /// Confirm we can send an update message (NOT MARKETING)
    func canSendUpdate() -> Bool {
        if self.authed && self.authComms {
            return true
        } else {
            return false
        }
    }
    
    /// Confirm we can send a marketing message
    func canSendMarketing() -> Bool {
        if self.authed && self.authMarketing {
            return true
        } else {
            return false
        }
    }
}
