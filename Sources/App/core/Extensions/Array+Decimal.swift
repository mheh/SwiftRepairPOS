import Foundation

// MARK: Sum array objects

extension Sequence where Element: AdditiveArithmetic {
    
    /// Returns the total sum of all elements in the sequence
    func sum() -> Element { reduce(.zero, +) }
}

extension Collection where Element == Decimal {
    
    /// Calculate the average of a collection of Decimal elements
    func average() -> Decimal {
        isEmpty ? .zero : sum() / Decimal(count)
    }
}



// MARK: Chunk array objects into higher level array

extension Array {
    
    /// Bulk items, greater than 20,000 records should be broken up
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}



// MARK: Mutate remove array object

extension Array where Element: Equatable {

    /// Remove first collection element that is equal to the given `object`:
  mutating func remove(object: Element) {
      guard let index = firstIndex(of: object) else { return }
      remove(at: index)
  }
}



// MARK: Decimal String Formatter

extension Decimal {
    
    /// Return copy of `self` as a `String` type.
    ///     - `places: Int - round this many places`
    func roundStr(to places: Int) throws -> String {
        guard let double = Double(String(self.description)) else {
            // I have no idea how to throw this error correctly.
            throw DecodingError.valueNotFound(String.self, .init(codingPath: [], debugDescription: "Could not convert Decimal type to Double type"))
        }
        return String(format: "%.\(places)f", double)
    }
}



#if(os(macOS))

// MARK: Round Decimal via NSDecimalNumber and powers of 10

extension Decimal {

    /// Round the decimal to total places
    /// Ex: `10.131121` to `to places: 2` results in `10.13`
    mutating func round(to places: Int = 2) throws {
        // self = 13.131121
        let powTen: Decimal = self * (pow(10.0, places))
        // powTen = 1313.1121
        let rounded = NSDecimalNumber(decimal: powTen)
            .doubleValue
            .rounded()
        // rounded = 1313.0
        self = Decimal(rounded) / (pow(10.0, places))
        // self = 13.13
    }
}
#endif

