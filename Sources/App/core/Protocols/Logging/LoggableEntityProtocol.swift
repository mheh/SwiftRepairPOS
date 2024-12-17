import Foundation
import Vapor
import Fluent

/// Required EntityLog children attribute for Loggable Entities
protocol LoggableEntityProtocol: Model {
    /// The pivot model to link to
    associatedtype EntityLogPivotModel: Model, EntityLogPivotModelProtocol
    /// The children attribute for links to the pivot model
    var pivot: [EntityLogPivotModel] { get }
    // ChildrenProperty<Self, EntityLogPivotModel>
    /// Siblings attribute for lookup in database
    var log: [EntityLog] { get }
    // SiblingsProperty<Self, EntityLog, EntityLogPivotModel>
}

/// Required pivot model for Loggable Entities
protocol EntityLogPivotModelProtocol {
    /// Parent model for this pivot class
    associatedtype EntityLogModel: Model
    
    /// The linked EntityLog ID
    var entityLogID: EntityLog { get }
    /// The parent model ID
    var modelID: EntityLogModel { get }
}
