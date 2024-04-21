protocol ReadPGN {
    mutating func fillBufferAndPeek() -> UInt8?

    func data() -> [UInt8]
    func remaining() -> Int
    
    mutating func consume(_ n: Int)
    mutating func consumeAll()

    func peek() -> UInt8?
    mutating func bump() -> UInt8?
}
