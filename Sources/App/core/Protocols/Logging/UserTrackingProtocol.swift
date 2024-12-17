import Fluent

/// Models that conform to this protocol will record who created the document and who is assigned to the document.
protocol UserTrackingProtocol: Model {
    
    /// Who created this document?
    var createdUserID: User? { get set }
    
    /// Who created this document? String if the user is ever removed
    var createdUserName: String { get set }
    
    /// Optionally who is assigned this document?
    var assignedUserID: User? { get set }
    
}
