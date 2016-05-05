// MARK: -
// MARK: Extension, URL Escaped String
// MARK: -
extension String {
    internal var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}
