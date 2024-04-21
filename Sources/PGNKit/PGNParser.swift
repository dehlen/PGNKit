import Foundation

public struct PGNParser {
    var reader: BufferedReader
    
    public init(string: String) {
        let bufferedReader = BufferedReader(string: string)
        self.reader = bufferedReader
    }
    
    public init(url: URL) throws {
        let bufferedReader = try BufferedReader(url: url)
        self.reader = bufferedReader
    }
    
    public mutating func readGame<V: Visitor>(visitor: V) throws -> V.VisitorResult? {
        reader.skipBom()
        reader.skipWhitespace()
        
        guard let _ = reader.fillBufferAndPeek() else {
            return nil
        }
        
        visitor.beginGame()
        visitor.beginHeaders()
        try self.readHeaders(visitor: visitor)
        visitor.endHeaders()
        try self.readMoveText(visitor: visitor)

        reader.skipWhitespace()
        return visitor.endGame()
    }
    
    public func readGames<V: Visitor>(visitor: V) throws {
        var iterator = makeIterator(visitor: visitor)
        while let _ = iterator.next() {}
    }
    
    public func makeIterator<V: Visitor>(visitor: V) -> PGNParserIterator<V> {
        PGNParserIterator(visitor: visitor, parser: self)
    }
    
    private mutating func readHeaders<V: Visitor>(visitor: V) throws {
        outer: while let token = reader.fillBufferAndPeek() {
            switch token {
            case .openBrace:
                _ = reader.bump()
                
                let leftQuote: Int
                if let match = reader.data().firstIndex(where: {
                    $0 == .doubleQuote || $0 == .newLine || $0 == .closeBrace
                }) {
                    if reader.data()[match] == .doubleQuote {
                        leftQuote = match
                    } else {
                        reader.consume(match + 1)
                        reader.skipKet()
                        continue outer
                    }
                } else {
                    reader.consumeAll()
                    reader.skipLine()
                    throw PGNParserError.invalidData
                }
                
                let space = leftQuote > 0 && reader.data()[leftQuote - 1] == .space ? (leftQuote - 1) : leftQuote
                let valueStart = leftQuote + 1
                var rightQuote = valueStart
                var consumed = 0
                // firstIndex returns index in original data not in the slice
                // therefore the index does not need to be shifted by rightQuote
                loop: while true {
                    let match = reader.data()[rightQuote...].firstIndex(where: {
                        $0 == .backSlash || $0 == .doubleQuote || $0 == .newLine
                    })
                    switch match {
                    case let .some(delta) where reader.data()[rightQuote...][delta] == .doubleQuote:
                        rightQuote = delta
                        consumed = rightQuote + 1
                        break loop
                    case let .some(delta) where reader.data()[rightQuote...][delta] == .newLine:
                        rightQuote = delta
                        consumed = rightQuote
                        break loop
                    case let .some(delta):
                        rightQuote = min(delta + 2, reader.remaining())
                    case .none:
                        reader.consumeAll()
                        reader.skipLine()
                        throw PGNParserError.invalidData                   
                    }
                }

                let key = String(decoding: reader.data()[..<space], as: UTF8.self)
                let value = String(decoding: reader.data()[valueStart..<rightQuote], as: UTF8.self)
                visitor.header(
                    key: key,
                    value: value
                )

                reader.consume(consumed)
                reader.skipKet()
            case .percentSign:
                reader.skipLine()
            default:
                return
            }
        }
    }
    
    private mutating func readMoveText<V: Visitor>(visitor: V) throws {
        loop: while let token = reader.fillBufferAndPeek() {
            switch token {
            case .openBracket:
                _ = reader.bump()
                guard let rightBracket = reader.data().firstIndex(of: .closeBracket) else {
                    reader.consumeAll()
                    reader.skip(until: .closeBracket)
                    _ = reader.bump()
                    throw PGNParserError.invalidData
                }
                let comment = String(decoding: reader.data()[..<rightBracket], as: UTF8.self)
                visitor.comment(comment)
                reader.consume(rightBracket + 1)
            
            case .newLine:
                _ = reader.bump()
                switch reader.peek() {
                case .some(.percentSign):
                    _ = reader.bump()
                    reader.skipLine()
                case .some(.openBrace), .some(.newLine):
                    break loop
                case .some(.carriageReturn):
                    _ = reader.bump()
                    if reader.peek() == .newLine {
                        break loop
                    }
                default:
                    continue loop
                }
                
            case .semiColon:
                _ = reader.bump()
                reader.skip(until: .newLine)
    
            case .one:
                _ = reader.bump()
                if reader.data().starts(with: [.slash, .two, .minus, .one, .slash, .two]) {
                    reader.consume(6)
                    visitor.outcome(.draw)
                } else if reader.data().starts(with: [.minus, .zero]) {
                    reader.consume(2)
                    visitor.outcome(.decisive(winner: .white))
                } else {
                    let tokenEnd = findTokenEnd(startingAt: 0)
                    reader.consume(tokenEnd)
                }
                
            case .zero:
                _ = reader.bump()
                if reader.data().starts(with: [.minus, .one]) {
                    reader.consume(2)
                    visitor.outcome(.decisive(winner: .black))
                } else if reader.data().starts(with: [.minus, .zero]) {
                    var san = "0-0"
                    // Castling notation with zeros.
                    reader.consume(2)
                    if reader.data().starts(with: [.minus, .zero]) {
                        reader.consume(2)
                        san += "-0"
                    }
                    
                    switch reader.peek() {
                    case .some(.plus):
                        san += "+"
                    case .some(.hashTag):
                        san += "#"
                    default:
                        ()
                    }
                    visitor.san(san)
                } else {
                    let tokenEnd = findTokenEnd(startingAt: 0)
                    reader.consume(tokenEnd)
                }
                
            case .parenOpen:
                _ = reader.bump()
                visitor.beginVariation()
            
            case .parenClose:
                _ = reader.bump()
                visitor.endVariation()
            
            case .bang:
                _ = reader.bump()
                            
                switch reader.peek() {
                case .some(.bang):
                    _ = reader.bump()
                    visitor.nag(.brilliantMove)
                case .some(.questionMark):
                    _ = reader.bump()
                    visitor.nag(.speculativeMove)
                default:
                    visitor.nag(.goodMove)
                }
                
            case .questionMark:
                _ = reader.bump()
                            
                switch reader.peek() {
                case .some(.bang):
                    _ = reader.bump()
                    visitor.nag(.dubiousMove)
                case .some(.questionMark):
                    _ = reader.bump()
                    visitor.nag(.blunder)
                default:
                    visitor.nag(.mistake)
                }

            case .dollarSign:
                _ = reader.bump()
                
                let tokenEnd = findTokenEnd(startingAt: 0)

                if let number = Int(String(decoding: reader.data()[..<tokenEnd], as: UTF8.self)),
                   let nag = Nag(rawValue: number) {
                    visitor.nag(nag)
                }
                
                reader.consume(tokenEnd)
                            
            case .astericks:
                visitor.outcome(.unknown)
                _ = reader.bump()
            
            case .space, .tab, .carriageReturn, .P, .dot:
                _ = reader.bump()
                
            default: 
                let tokenEnd = findTokenEnd(startingAt: 1)
                if token > .nine || token == .minus {
                    let san = String(decoding: reader.data()[..<tokenEnd], as: UTF8.self)
                    visitor.san(san)
                }
                reader.consume(tokenEnd)
            }
        }
    }
    
    private func findTokenEnd(startingAt start: Int) -> Int {
        // firstIndex returns index in original data not in the slice
        // therefore the index does not need to be shifted to account for start
        let stopPoints: [UInt8] = [
            .space,
            .tab,
            .newLine,
            .carriageReturn,
            .openBracket,
            .closeBracket,
            .parenOpen,
            .parenClose,
            .bang,
            .questionMark,
            .dollarSign,
            .semiColon,
            .dot
        ]
        
        return reader.data()[start...].firstIndex(where: {
            stopPoints.contains($0)
        }) ?? reader.data().endIndex
    }
}

public struct PGNParserIterator<V: Visitor>: IteratorProtocol {
    var parser: PGNParser
    let visitor: V
    
    public init(visitor: V, parser: PGNParser) {
        self.visitor = visitor
        self.parser = parser
    }
    
    public mutating func next() -> V.VisitorResult? {
        do {
            return try parser.readGame(visitor: visitor)
        } catch {
            return nil
        }
    }
    
    public typealias Element = V.VisitorResult
}

extension BufferedReader {
    mutating func skip(until needle: UInt8) {
        loop: while let _ = fillBufferAndPeek() {
            if let match = data().firstIndex(of: needle) {
                consume(match)
                break loop
            } else {
                consumeAll()
            }
        }
    }

    mutating func skipLine() {
        skip(until: .newLine)
        _ = bump()
    }
    
    mutating func skipWhitespace() {
        loop: while let byte = fillBufferAndPeek() {
            switch byte {
            case .space, .newLine, .carriageReturn, .tab:
                _ = bump()
            case .percentSign:
                _ = bump()
                skipLine()
            default:
                break loop
            }
        }
    }
    
    mutating func skipKet() {
        loop: while let byte = fillBufferAndPeek() {
            switch byte {
            case .space, .carriageReturn, .tab, .closeBrace:
                _ = bump()
            case .percentSign:
                _ = bump()
                skipLine()
                break loop
            case .newLine:
                _ = bump()
                break loop
            default:
                break loop
            }
        }
    }
    
    mutating func skipBom() {
        _ = fillBufferAndPeek()
        if self.data().starts(with: UInt8.bom) {
            consume(UInt8.bom.count)
        }
    }
}

public enum PGNParserError: Error {
    case invalidData
}
