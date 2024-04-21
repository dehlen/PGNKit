public protocol Visitor {
    associatedtype VisitorResult

    func beginGame()
    
    func beginHeaders()
    func header(key: String, value: String)
    func endHeaders()
    
    func san(_ san: String)
    func nag(_ nag: Nag)
    func comment(_ comment: String)
    
    func beginVariation()
    func endVariation()
    
    func outcome(_ outcome: Outcome)
    
    func endGame() -> VisitorResult
}
