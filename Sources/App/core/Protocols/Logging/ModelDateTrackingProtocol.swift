import Foundation
import Fluent

/// For keeping track of dates throughout model lifecycle
public protocol ModelDateTrackingProtocol: Model {
    /// The date this model was created
    var createdAt: Date? { get }
    /// The date this model was last updated
    var updatedAt: Date? { get }
    /// When this model was deleted
    var deletedAt: Date? { get }
}

// TODO: PropertyWrapper protocol implementation
public protocol DateTrackingProtocolV2: Model {
    var createdAt: Timestamp<DefaultTimestampFormat> { get }

}
