import Quick
import Nimble
import ReactiveJSON
import ReactiveCocoa

class ResourceJSONTests: QuickSpec {
    override func spec() {
        describe("resource json") {
            it("handles conformance on assignment") {
                var resource: EndpointResource<Entity<Int>>! = []
                try! Fixture.request(fixture: "users") { (response: [[String:AnyObject]]) in
                    resource = EndpointResource(response)
                }

                expect { resource?.first?["username"] as? String
                    }.toEventually( equal("Bret") )

                expect { resource?.first?.id
                    }.toEventually( equal(1) )
            }

            it("handles conformance on bindings") {
                try! Fixture.set(file: "users")

                let resource = MutableProperty(JSONResource())
                resource <~ Fixture.request(endpoint: empty).ignoreError()
                resource <~ Fixture.request(endpoint: empty).ignoreError()
                resource <~ Fixture.request(endpoint: empty).ignoreError()
                resource <~ Fixture.request(endpoint: empty).ignoreError()
                resource <~ Fixture.request(endpoint: empty).ignoreError()
                resource <~ Fixture.request(endpoint: empty).ignoreError()

                resource.producer.startWithNext {
                    print($0)
                }
                resource.signal.observeNext {
                    print($0)
                }

                expect{ resource.value.json["username"] as? String
                    }.toEventually( equal("Moriah.Stanton") )
            }
        }
    }
}
