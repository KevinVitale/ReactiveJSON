import Quick
import Nimble
import ReactiveJSON
import ReactiveCocoa

class ResourceJSONTests: QuickSpec {
    override func spec() {
        describe("resource json") {
            it("handles conformance on assignment") {
                var resource = JSONResource()
                try! Fixture.request(fixture: "user") { resource = $0 }

                expect { resource.json["username"] as? String
                    }.toEventually( equal("kevinvitale") )
            }

            it("handles conformance on bindings") {
                try! Fixture.set(file: "user")

                let resource = MutableProperty(JSONResource())
                resource <~ Fixture.request(endpoint: empty)
                    .ignoreError()

                expect{ resource.value.json["username"] as? String
                    }.toEventually( equal("kevinvitale") )
            }
        }
    }
}
