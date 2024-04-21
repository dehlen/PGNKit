public struct Nag: RawRepresentable, Hashable, Sendable {
    public let rawValue: Int

    public static let goodMove: Nag = .init(rawValue: 1)!
    public static let mistake: Nag = .init(rawValue: 2)!
    public static let brilliantMove: Nag = .init(rawValue: 3)!
    public static let blunder: Nag = .init(rawValue: 4)!
    public static let speculativeMove: Nag = .init(rawValue: 5)!
    public static let dubiousMove: Nag = .init(rawValue: 6)!
    
    public init?(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init?(from string: String) {
        switch string {
        case "?!":
            self = .dubiousMove
        case "?":
            self = .mistake
        case "??":
            self = .blunder
        case "!":
            self = .goodMove
        case "!!":
            self = .brilliantMove
        case "!?":
            self = .speculativeMove
        default:
            if string.first == "$", string.count > 1, let number = Int(string.dropFirst()) {
                self.init(rawValue: number)
                return
            }
            return nil
        }
    }
}
