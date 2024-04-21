struct Buffer {
    let size: Int
    var inner: RingByteBuffer

    init(size: Int) {
        self.size = size
        self.inner = RingByteBuffer(size: size * 2)
    }
}
