extension String {
    
    /// Remove characters except numbers
    /// withDec: FALSE
    func onlyNum(withDec: Bool = false) -> String {
        withDec ? self.filter("0123456789.".contains) : self.filter("0123456789".contains)
    }
    
}
