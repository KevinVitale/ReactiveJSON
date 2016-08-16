# ReactiveJSON
ReactiveJSON is a Swift network framework for JSON services, built using [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa). The framework is minimally designed, yet still highly flexibile.

Features includes:
  - Easy-to-create, and highly adatable JSON clients;
  - Support for the most common HTTP methods;
  - Parameter encoding;
  - OAuth2 token support;
  - Automatic JSON parsing;

## Usage
After a tiny bit of setup, requests look like this:

```swift
// Create a `SignalProducer` that will execute the network request when started.
MyJSONService
    .request(endpoint: "foo")
    .startWithResult {
        // `value` is inferred to be `Any`
        print($0.value)
    }
//------------------------------------------------------------------------------
// Bind a GET request to a `MutableProperty`
let users = MutableProperty<[[String:AnyObject]]>([])
users <~ MyJSONService
    .request(endpoint: "users")
    .ignoreError()
//------------------------------------------------------------------------------
// Send a POST request
MyJSONService
    .request(endpoint: "sprocket", method: .Post, parameters: ["foo":"bar"])
    .startWithCompleted {
        print("huzzah!")
    }
```

## Setup
Here is an example of creating a JSON client:
```swift
/// A JSON client for the Guild Wars 2 API
struct GW2API: Singleton, ServiceHost {
    // 'Singleton'
    private(set) static var shared = Instance()
    typealias Instance = GW2API

    // 'ServiceHost'
    static var scheme: String { return "https" }
    static var host: String { return "api.guildwars2.com" }
    static var path: String? { return "v2" }
}
```

Any `ServiceHost` can make a request. Therefore, a `Singleton` that is also a `ServiceHost` can, as well:
```swift
// Prints the name of all dyes returned by the "colors" endpoint
GW2API.request(endpoint: "colors", parameters: ["ids":"all"])
    .startWithResult {
        $0.value?.forEach {
            print($0["name"])
        }
    }
```

## Mocking Requests
[Benjamin Encz](https://twitter.com/benjaminencz/status/762449471963664384) sums up the philosophy behind ReactiveJSON rather well:

> _"One of my favorite aspects of Swift: Protocols allow you describe truths about types. Generic code can build on top of these truths."_

The `Singleton` protocol requires its `Instance` alias be a `ServiceHost`. Without the need to overload any `request` functions, we can create a client that loads its responses from a fixture file. The result might look something like this:

> _Note: For a complete example of this concept, see [`Fixture.swift`](https://github.com/KevinVitale/ReactiveJSON/blob/master/Tests/Fixtures/Fixture.swift)_

```swift
class ServiceHostTests: QuickSpec {
    override func spec() {
        describe("resource json") {
            it("handles conformance on assignment") {
                var users: [[String:AnyObject]] = []
                try! Fixture.request(fixture: "users") { users = $0 }

                expect { users.first?["username"] as? String
                    }.toEventually( equal("Bret") )

                expect { users.first?["id"] as? Int
                    }.toEventually( equal(1) )
            }
        }
    }
}
```
