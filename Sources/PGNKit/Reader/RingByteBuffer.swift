import Darwin
import Foundation
import RingBuffer

final class RingByteBuffer {
    let size: Int
    private var buffer: TPCircularBuffer
    
    init(size: Int) {
        self.size = size
        self.buffer = TPCircularBuffer()
        TPCircularBufferInit(&self.buffer, Int32(size))
    }
    
    deinit {
        TPCircularBufferCleanup(&self.buffer)
    }
    
    func enqueue(data: Data) -> Bool {
        return data.withUnsafeBytes { buffer -> Bool in
            guard let bytes = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return false
            }
            return TPCircularBufferProduceBytes(&self.buffer, UnsafeRawPointer(bytes), Int32(data.count))
        }
    }
    
    func enqueue(_ bytes: UnsafeRawPointer, count: Int) -> Bool {
        return TPCircularBufferProduceBytes(&self.buffer, bytes, Int32(count))
    }
    
    func withMutableHeadBytes(_ f: (UnsafeMutableRawPointer, Int) -> Int) {
        var availableBytes: Int32 = 0
        let bytes = TPCircularBufferHead(&self.buffer, &availableBytes)
        let enqueuedBytes = f(bytes!, Int(availableBytes))
        TPCircularBufferProduce(&self.buffer, Int32(enqueuedBytes))
    }
    
    func space() -> (UnsafeMutableRawPointer, Int) {
        var availableBytes: Int32 = 0
        let bytes = TPCircularBufferHead(&self.buffer, &availableBytes)
        return (bytes!, Int(availableBytes))
    }
    
    func fill(_ count: Int) {
        TPCircularBufferProduce(&self.buffer, Int32(count))
    }
    
    func dequeue(_ bytes: UnsafeMutableRawPointer, count: Int) -> Int {
        var availableBytes: Int32 = 0
        let tail = TPCircularBufferTail(&self.buffer, &availableBytes)
        
        let copiedCount = min(count, Int(availableBytes))
        memcpy(bytes, tail, copiedCount)
        
        TPCircularBufferConsume(&self.buffer, Int32(copiedCount))
        
        return copiedCount
    }
    
    func dequeue(count: Int) -> Data {
        var availableBytes: Int32 = 0
        let tail = TPCircularBufferTail(&self.buffer, &availableBytes)
        
        let copiedCount = min(count, Int(availableBytes))
        let bytes = malloc(copiedCount)!
        memcpy(bytes, tail, copiedCount)
        
        TPCircularBufferConsume(&self.buffer, Int32(copiedCount))
        
        return Data(bytesNoCopy: bytes.assumingMemoryBound(to: UInt8.self), count: copiedCount, deallocator: .free)
    }
    
    func clear() {
        TPCircularBufferClear(&self.buffer)
    }
    
    var availableBytes: Int {
        var count: Int32 = 0
        TPCircularBufferTail(&self.buffer, &count)
        return Int(count)
    }
    
    var data: [UInt8] {
        var availableBytes: Int32 = 0
        guard let tail = TPCircularBufferTail(&self.buffer, &availableBytes) else { return [] }
        let pointer = tail.bindMemory(to: UInt8.self, capacity: Int(availableBytes))
        return Array(UnsafeBufferPointer(start: pointer, count: Int(availableBytes)))
    }
}
