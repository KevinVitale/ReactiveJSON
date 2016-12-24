import Quick
import Nimble
@testable import ReactiveJSON

class QueryParametersTests: QuickSpec {
    override func spec() {
        describe("query parameters") {
            it("handles 'nil' parameters") {
                let params: [String:AnyObject] = [:]
                expect(params).to(beEmpty())
            }

            it("handles 'ids' parameter (comma-separated)") {
                let params: [String:AnyObject] = [ "ids" : "1,2,3,4,5" as AnyObject ]
                expect(params.percentEncodedQuery).to(equal("ids=1,2,3,4,5"))
            }

            it("handles url-encoding (special characters)") {
                let params: [String:AnyObject] = [
                    "email": "this+thing1@someplace.com" as AnyObject,
                    "name": "Thing 1" as AnyObject,
                    "password": "A12345!" as AnyObject,
                    "username": "thing1" as AnyObject,
                ]

                expect(params.percentEncodedQuery).to(equal("email=this+thing1@someplace.com&name=Thing%201&password=A12345!&username=thing1"))
            }
        }
    }
}
