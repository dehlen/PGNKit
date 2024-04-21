@testable import PGNKit

final class TestableVisitor: Visitor {
    typealias VisitorResult = Void

    var events: [VisitorEvent] = []
    
    var nags: [Nag] {
        var result = [Nag]()
        for event in events {
            if case let .nag(nag) = event {
                result.append(nag)
            }
        }
        return result
    }
    
    var sans: [String] {
        var result = [String]()
        for event in events {
            if case let .san(san) = event {
                result.append(san)
            }
        }
        return result
    }
    
    func beginGame() {
        events.append(.beginGame)
    }
    
    func beginHeaders() {
        events.append(.beginHeaders)
    }
    
    func header(key: String, value: String) {
        events.append(.header(key: key, value: value))
    }
    
    func endHeaders() {
        events.append(.endHeaders)
    }
    
    func san(_ san: String) {
        events.append(.san(san))
    }
    
    func nag(_ nag: PGNKit.Nag) {
        events.append(.nag(nag))
    }
    
    func comment(_ comment: String) {
        events.append(.comment(comment))
    }
    
    func beginVariation() {
        events.append(.beginVariation)
    }
    
    func endVariation() {
        events.append(.endVariation)
    }
    
    func outcome(_ outcome: PGNKit.Outcome) {
        events.append(.outcome(outcome))
    }
    
    func endGame() {
        events.append(.endGame)
    }
}

enum VisitorEvent: Hashable {
    case beginGame
    case beginHeaders
    case header(key: String, value: String)
    case endHeaders
    case san(String)
    case nag(Nag)
    case comment(String)
    case beginVariation
    case endVariation
    case outcome(Outcome)
    case endGame
}
