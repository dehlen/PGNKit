import XCTest
@testable import PGNKit

class NagTests: XCTestCase {
    func testInitFromString() {
        XCTAssertEqual(Nag(from: "?!"), .dubiousMove)
        XCTAssertEqual(Nag(from: "?"), .mistake)
        XCTAssertEqual(Nag(from: "??"), .blunder)
        XCTAssertEqual(Nag(from: "!"), .goodMove)
        XCTAssertEqual(Nag(from: "!!"), .brilliantMove)
        XCTAssertEqual(Nag(from: "!?"), .speculativeMove)
        
        XCTAssertEqual(Nag(from: "$71"), Nag(rawValue: 71))
        XCTAssertEqual(Nag(from: "$1"), .goodMove)
        
        XCTAssertNil(Nag(from: "invalid"))
    }
}
