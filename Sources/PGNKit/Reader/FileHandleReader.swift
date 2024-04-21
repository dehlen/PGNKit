import Foundation

struct FileHandleReader: Read {
    let fileHandle: FileHandle

    init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
    
    func read(into buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        guard let data = try fileHandle.read(upToCount: buffer.count) else { return 0 }
        return data.copyBytes(to: buffer.bindMemory(to: UInt8.self))
    }
}
