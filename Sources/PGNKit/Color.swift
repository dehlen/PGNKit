public enum Color: Int, Hashable {
    case black = 0
    case white = 1
    
    public init?(char: Character) {
        switch char {
        case "b":
            self = .black
        case "w":
            self = .white
        default:
            return nil
        }
    }
    
    public var char: Character {
        switch self {
        case .black:
            return "b"
        case .white:
            return "w"
        }
    }
    
    public func toggle() -> Self {
        switch self {
        case .black:
            return .white
        case .white:
            return .black
        }
    }
}
