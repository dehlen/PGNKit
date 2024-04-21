import Foundation

struct BufferedReader {
    var inner: any Read
    var buffer: Buffer
    
    init(url: URL, bufferSize: Int = 1024 * 8) throws {
        let fileHandle = try FileHandle(forReadingFrom: url)
        let fileHandleReader = FileHandleReader(fileHandle: fileHandle)
        let buffer = Buffer(size: bufferSize)
        self.inner = fileHandleReader
        self.buffer = buffer
    }
    
    init(string: String, bufferSize: Int = 1024 * 8) {
        let cursor = Cursor(input: Data(string.utf8))
        let buffer = Buffer(size: bufferSize)
        self.inner = cursor
        self.buffer = buffer
    }
}

extension BufferedReader: ReadPGN {
    mutating func fillBufferAndPeek() -> UInt8? {
        while buffer.inner.availableBytes < buffer.size {
            do {
                let (ptr, count) = buffer.inner.space()
                let remainder = UnsafeMutableRawBufferPointer(start: ptr, count: count)
                let size = try inner.read(into: remainder)
                if size == 0 { break }
                buffer.inner.fill(size)
            } catch {
                break
            }
        }

        return buffer.inner.data.first
    }

    func data() -> [UInt8] {
        return buffer.inner.data
    }

    mutating func consume(_ n: Int) {
        _ = buffer.inner.dequeue(count: n)
    }

    func peek() -> UInt8? {
        return buffer.inner.data.first
    }

    mutating func bump() -> UInt8? {
        let head = peek()
        if head != nil {
            consume(1)
        }
        return head
    }

    func remaining() -> Int {
        return buffer.inner.availableBytes
    }

    mutating func consumeAll() {
        let remaining = buffer.inner.availableBytes
        consume(remaining)
    }
}
