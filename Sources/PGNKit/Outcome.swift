public enum Outcome: Hashable {
    case decisive(winner: Color)
    case draw
    case unknown
    
    public init?(from string: String) {
        switch string {
        case "1-0":
            self = .decisive(winner: .white)
        case "0-1":
            self = .decisive(winner: .black)
        case "1/2-1/2":
            self = .draw
        case "*":
            self = .unknown
        default:
            return nil
        }
    }
}
