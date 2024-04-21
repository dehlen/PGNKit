import Foundation

struct Cursor<T: DataProtocol>: Read where T.Index == Int {
    private var input: T
    private var position: Int

    init(input: T) {
        self.input = input
        self.position = 0
    }

    mutating func read(into buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        let bytesToRead = min(buffer.count, input.count - position)
        guard bytesToRead > 0 else { return 0 }
        input.copyBytes(to: buffer.bindMemory(to: UInt8.self), from: position..<(position + bytesToRead))
        position += bytesToRead
        return bytesToRead
    }
}
