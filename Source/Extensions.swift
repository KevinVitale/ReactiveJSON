// MARK: - Extension, URL Escaped String -
//------------------------------------------------------------------------------
extension String {
    /// - parameter URLEscapedString: A valid, percent-encoded, URL string.
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

// MARK: - Typealias, KeyValuePair -
//------------------------------------------------------------------------------
/// - returns: A tuple with `key` and a `value`.
typealias KeyValuePair = (key: String, value: AnyObject)

// MARK: - Extension, Query Items -
//------------------------------------------------------------------------------
extension SequenceType where Generator.Element == KeyValuePair {
    func queryItems() -> [NSURLQueryItem] {
        return map { NSURLQueryItem(name: $0.key, value: $0.value.description.URLEscapedString) }
    }

    func queryString() -> String {
        return sort { $0.0.key < $0.1.key }
            .map { $0.key + "=" + ($0.value.description ?? "") }
            .joinWithSeparator("&")
    }
}

// MARK: - Extension, Query Items -
//------------------------------------------------------------------------------
extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    func queryItems() -> [NSURLQueryItem] {
        return enumerate()
            .map { $0.1 }
            .map { (key: $0.0 as! String, value: $0.1) }
            .queryItems()
    }
}
