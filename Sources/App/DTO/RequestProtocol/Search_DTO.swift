//
//  Search_DTO.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/16/24.
//

//
//  File.swift
//
//
//  Created by Milo Hehmsoth on 9/4/23.
//

import Foundation
import Fluent

// MARK: - Search Terms
/// For a Get All request in which we can decode search terms, this is the supplied object
/// These are all URLQueryEncoded Objects
public protocol DTOSearchURLQueryTermsProtocol: Codable {
    /// The text to search for
    var searchText: String { get set }
    /// Whether to ascend or descend the results
    var ascending: Bool { get set }
    /// Date to start querying results
    /// `ISO 8601` Encoded and Decoded
    var startDate: Date? { get set }
    /// Date to stop querying results
    /// `ISO 8601` Encoded and Decoded
    var endDate: Date? { get set }
    /// Custom fields that match DTO model query fields
    var fields: [String: String] { get set }
}

extension DTOSearchURLQueryTermsProtocol {
    /// Generate a set of URL query items for searching
    public func generateURLQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(.init(name: "searchText", value: self.searchText))
        queryItems.append(.init(name: "ascending", value: "\(self.ascending)"))
        
        if let startDate = self.startDate {
            queryItems.append(.init(name: "startDate", value: "\(startDate.iso8601FormattedString()))"))
        }
        if let endDate = self.endDate {
            queryItems.append(.init(name: "endDate", value: "\(endDate.iso8601FormattedString()))"))
        }
        for field in fields {
            queryItems.append(.init(name: field.key, value: field.value))
        }
        
        return queryItems
    }
    
    /// Generate a dictionary of string items from `self`
    public func generateStringDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]
        
        dictionary["searchText"] = self.searchText
        dictionary["ascending"] = "\(self.ascending)"
        
        if let startDate =  self.startDate  { 
            dictionary["startDate"] = "\(startDate.iso8601FormattedString())"
        }
        if let endDate =    self.endDate    {
            dictionary["endDate"] = "\(endDate.iso8601FormattedString())"
        }
        for field in fields {
            dictionary[field.key] = field.value
        }
        
        return dictionary
    }
}

/// For paginated responses, this is used to query the server
public struct DTOSearchURLQueryTerms: DTOSearchURLQueryTermsProtocol {
    public var searchText: String
    public var ascending: Bool
    public var startDate: Date?
    public var endDate: Date?
    public var fields: [String : String]
    
    public init(searchText: String = "", ascending: Bool = true, startDate: Date? = nil, endDate: Date? = nil, fields: [String : String] = [:]) {
        self.searchText = searchText
        self.ascending = ascending
        self.startDate = startDate
        self.endDate = endDate
        self.fields = fields
    }
}

extension PageMetadata {
    /// Generates a string dictionary for URL queries
    /// Returns a partial of this struct:
    ///     `page`
    ///     `per`
    public func generateStringDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]
        dictionary["page"] = String(self.page)
        dictionary["per"] = String(self.per)
        return dictionary
    }
}
