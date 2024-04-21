public extension UInt8 {
    @inlinable
    func isWhitespace() -> Bool {
        switch self {
        case .space, .newLine, .carriageReturn, .tab:
            return true
        default:
            return false
        }
    }

    static let tab: UInt8 = 9
    static let newLine: UInt8 = 10 // \n
    static let carriageReturn: UInt8 = 13 // \r

    static let space: UInt8 = 32
    static let bang: UInt8 = 33 // !
    static let doubleQuote: UInt8 = 34
    static let hashTag: UInt8 = 35
    static let dollarSign: UInt8 = 36
    static let percentSign: UInt8 = 37
    static let parenOpen: UInt8 = 40 // (
    static let parenClose: UInt8 = 41 // )
    static let astericks: UInt8 = 42
    static let plus: UInt8 = 43
    static let minus: UInt8 = 45
    static let dot: UInt8 = 46
    static let slash: UInt8 = 47
    
    static let zero: UInt8 = 48
    static let one: UInt8 = 49
    static let two: UInt8 = 50
    static let nine: UInt8 = 57
    
    static let semiColon: UInt8 = 59
    static let questionMark: UInt8 = 63
    
    static let P: UInt8 = 80
    
    static let openBrace: UInt8 = 91 // [
    static let backSlash: UInt8 = 92
    static let closeBrace: UInt8 = 93 // ]
    
    static let openBracket: UInt8 = 123 // {
    static let closeBracket: UInt8 = 125 // }
    
    static let bom: [UInt8] = [0xef, 0xbb, 0xbf]
}
