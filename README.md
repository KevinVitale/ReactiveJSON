# Swift JSON requests, made flexible!
An extremely flexible (and, lightweight!) network library for JSON services.

```swift
SomeService.request(endpoint: "foo")
    .startWithNext {
        print($0)
}
```

The `request` function is defined as:
```swift
public static func request<T>(
    endpoint endpoint: String,                      // a valid service path 
    method: Network.RequestMethodType = default,    // defaults to `.Get`
    parameters: [String : AnyObject]? = default,    // defaults to `nil`
    token: Network.AuthToken = default)             // defaults to `.None` 
-> ReactiveCocoa.SignalProducer<T, Network.NetworkError>
```

## Introduction

> **Note**: The simplest way to add this library to your application is via **Carthage**. In your `Cartfile`, add the following line:
>
> `github "KevinVitale/Network" "master"`

### Example

Let's define a network client that consumes responses from [JSONPlaceholder](http://jsonplaceholder.typicode.com):

```swift
public struct JSONPlaceholder: JSONService, ServiceHostType {
    private static let _sharedInstance = InstanceType()
    //--------------------------------------------------------------------------
    // protocol: JSONService
    public typealias InstanceType = JSONPlaceholder
    public static func sharedInstance() -> InstanceType { 
        return _sharedInstance 
    }
    //--------------------------------------------------------------------------
    // protocol: ServiceHostType
    public static var scheme: String { return "http" }
    public static var host: String { return "jsonplaceholder.typicode.com" }
    public static var path: String? { return nil }
    //--------------------------------------------------------------------------
}
```

<hr/>
Now, make some `request`:

> **🚧**: Observe how _little_ is known about the response **structure** beforehand

```swift
// Prints out all users (as an array)
JSONPlaceholder
    .request(endpoint: "users")
    .startWithNext {
        print($0)
}

// Prints out each user (individually)
JSONPlaceholder
    .request(endpoint: "users")
    .collect()
    .startWithNext {
        $0.forEach {
            print($0)
        }
}

// Filters only those users that start with the letter 'L'
JSONPlaceholder
    .request(endpoint: "users")
    .attemptMap { (next: Any) -> Result<SignalProducer<[String:AnyObject], NoError>, NetworkError> in
        guard let array = next as? [[String:AnyObject]] else {
            return .Success(SignalProducer.empty)
        }
        return .Success(SignalProducer(values: array))
    }
    .flatten(.Merge)
    .filter { ($0["name"] as? String)?.hasPrefix("L") ?? false }
    .startWithNext {
        print($0)
}
//------------------------------------------------------------------------------
/* prints...
//------------------------------------------------------------------------------
["name": Leanne Graham, "address": {
    city = Gwenborough;
    geo =     {
        lat = "-37.3159";
        lng = "81.1496";
    };
    street = "Kulas Light";
    suite = "Apt. 556";
    zipcode = "92998-3874";
}, "id": 1, "phone": 1-770-736-8031 x56442, "company": {
    bs = "harness real-time e-markets";
    catchPhrase = "Multi-layered client-server neural-net";
    name = "Romaguera-Crona";
}, "website": hildegard.org, "email": Sincere@april.biz, "username": Bret]
 */
//------------------------------------------------------------------------------
```

## Framework Overview

Creating a client to talk to your JSON service is done in three steps:
>   1. Define a `ServiceHostType`;
>   2. Adopt `JSONService`;
>   3. ???
>   4. Make requests!

<hr/>

#### Step #1: Define a `ServiceHostType`
The _secret sauce_ of `Network` is the `ServiceHostType` protocol. It requires three static variables:

- `scheme`: a `String` 
    - This can be `http`, `https`, `file`, or any valid URL scheme
- `host`: a `String`
    - This defines the _root_ of your service (e.g., `api.guildwars2.com`)
- `path`: an `Optional<String>`
    - This is a globally appended path value (e.g., `v2`)

#### Step #2: Adopt `JSONService`
Adopting `JSONService` creates network client singleton, and associates a `ServiceHostType` with a shared instance:

- `InstanceType`: a `ServiceHostType`
    - To get moving quickly, assign this to your the same type as your `JSONService` adopter
- `public static func sharedInstance()`: a `JSONService.InstanceType` instance
    - An simple solution would be to return the value of `private static let _sharedInstance`

#### Step #3: ???
🍹

#### Step #4: Make requests!
Maybe you have a `sprocket` endpoint:
```swift
MyService.request(endpoint: "sprocket")
    .startWithNext {
        print($0)
}
```

## Wait, seriously? A SINGLETON!
Yes, supposedly [singletons are bad](https://www.dzombak.com/blog/2014/03/singletons.html). But `JSONService` is merely a singleton that defines its `ServiceHostType`.

As such, your `JSONService` is one which updates its backend service during runtime? Let's see it in action:

```swift
/// A mutable `JSONService` based on the value of `host`.
public struct Service {
    public static var host: Host = .Custom(scheme: "", host: "", path: nil)

    /**
     A single `enum` with the same associated values as `ServiceHostType`.
     */
    public enum Host: ServiceHostType {
        case Custom(scheme: String, host: String, path: String?)

        // Derives `scheme`
        public static var scheme: String {
            switch Service.host { case .Custom(let scheme, _, _): return scheme }
        }

        // Derives `host`
        public static var host: String {
            switch Service.host { case .Custom(_, let host, _): return host }
        }

        // Derives `path`
        public static var path: String? {
            switch Service.host { case .Custom(_, _, let path): return path }
        }
    }
}

/// Adopt `JSONService`
extension Service: JSONService {
    public typealias InstanceType = Service.Host
    public static func sharedInstance() -> InstanceType { return host }
}
```

Then make a `request`:
```swift
Service.host = .Custom(scheme: "https", host: "api.guildwars2.com", path: "v2")
Service.request(endpoint: "colors")
    .startWithNext {
        print($0) // prints `Array<Int>`
    }
```

> **Note**: A similar technique is used as [mock requests](https://github.com/KevinVitale/Network/blob/master/Tests/Fixtures/Fixture.swift).
<hr/>
