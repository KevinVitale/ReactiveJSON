// MARK: -
// MARK: Typealias, KeyValuePair
// MARK: -
/// - returns: A tuple with `key` and a `value`.
typealias KeyValuePair = (key: String, value: AnyObject)

// MARK: -
// MARK: Extension, Query Items
// MARK: -
extension SequenceType where Generator.Element == KeyValuePair {
    internal func queryItems() -> [NSURLQueryItem] {
        return map { NSURLQueryItem(name: $0.key, value: $0.value.description.URLEscapedString) }
    }

    internal func queryString() -> String {
        return sort { $0.0.key < $0.1.key }
            .map { $0.key + "=" + ($0.value.description ?? "") }
            .joinWithSeparator("&")
    }
}

// MARK: -
// MARK: Extension, Query Items
// MARK: -
extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    internal func queryItems() -> [NSURLQueryItem] {
        return enumerate()
            .map { $0.1 }
            .map { (key: $0.0 as! String, value: $0.1) }
            .queryItems()
    }
}
