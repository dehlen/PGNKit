import XCTest
@testable import PGNKit

class ColorTests: XCTestCase {
    func testInitWithCharacter() {
        XCTAssertEqual(Color(char: "b"), .black)
        XCTAssertEqual(Color(char: "w"), .white)
        XCTAssertNil(Color(char: "x"))
    }
    
    func testCharacterRepresentation() {
        XCTAssertEqual(Color.black.char, "b")
        XCTAssertEqual(Color.white.char, "w")
    }
    
    func testToggle() {
        XCTAssertEqual(Color.black.toggle(), .white)
        XCTAssertEqual(Color.white.toggle(), .black)
    }
}
