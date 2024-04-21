protocol Read {
    mutating func read(into buffer: UnsafeMutableRawBufferPointer) throws -> Int
}
