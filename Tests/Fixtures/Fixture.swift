import ReactiveJSON
import ReactiveCocoa

/// - parameter empty: This empty string can prevent requests from
///   generating invalid file fixture paths.
public let empty = ""

/**
 A `JSONService` which loads responses from a fixture file in the test bundle.
 */
public struct Fixture {
    private static var file = File()
    public struct File: ServiceHostType {
        public static var scheme: String = "file"
        public static var host: String = ""
        public static var path: String? = nil
    }
}

// MARK: -
// MARK: Extension, JSON Service
// MARK: -
extension Fixture: JSONService {
    public typealias InstanceType = Fixture.File
    public static func sharedInstance() -> InstanceType {
        return file
    }
}

// MARK: -
// MARK:
// MARK: -
public enum FixtureError: ErrorType, CustomStringConvertible {
    case FileNotFound(String)

    /// - parameter description: The error's description.
    public var description: String {
        switch self {
        case .FileNotFound(let name):
            if name.hasSuffix(".json") {
                return "Please omit the file extension '.json' when referencing fixtures."
            }
            return "Unable to locate JSON fixture named: \(name)"
        }
    }
}

// MARK: -
// MARK: Extension, Set / Load Fixture File
// MARK: -
extension Fixture {
    public static func set(file name: String) throws {
        guard let url = NSBundle.testOrMainBundle().URLForResource(name, withExtension: "json")
            , let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
            , let scheme = components.scheme where scheme == "file"
            , let path = components.path else {
                throw FixtureError.FileNotFound(name)
        }
        File.host = path
    }

    public static func request<R: ResourceJSON>(fixture name: String, failed: (NetworkError -> Void)? = nil, completed: (() -> Void)? = nil, interrupted: (() -> Void)? = nil, next: (R -> Void)? = nil) throws {
        try set(file: name)

        let request: SignalProducer<R, NetworkError> = Fixture.request(endpoint: empty)
        let observer = Observer<R, NetworkError>(
            failed: failed,
            completed: { File.host = ""; completed?() },
            interrupted:
            interrupted,
            next: next
        )

        request.start(observer)
    }

    public static func request<R: Resourceable>(fixture name: String, failed: (NetworkError -> Void)? = nil, completed: (() -> Void)? = nil, interrupted: (() -> Void)? = nil, next: (EndpointResource<R>? -> Void)? = nil) throws {
        try set(file: name)

        let request: SignalProducer<EndpointResource<R>?, NetworkError> = Fixture.request(endpoint: empty)
        let observer = Observer<EndpointResource<R>?, NetworkError>(
            failed: failed,
            completed: { File.host = ""; completed?() },
            interrupted:
            interrupted,
            next: next
        )

        request.start(observer)
    }
}

// MARK: -
// MARK: Extension, NSBundle
// MARK: -
extension NSBundle {
    private final class _DummyClass { }

    /**
     Produces `testBundle` when called from unit tests. Produces `mainBundle`
     when called from an application target.
     
     - returns: `Test` or `Main` bundle.
     */
    private class func testOrMainBundle() -> NSBundle {
        let bundles = NSBundle
            .allBundles()
            .filter {
                return ($0.bundlePath as NSString).pathExtension == "xctest"
        }
        return bundles.first ?? self.mainBundle()
    }
}

