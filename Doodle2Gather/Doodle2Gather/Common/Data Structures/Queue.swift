/// First-in first-out queue (FIFO).
/// New elements are added to the end of the queue. Dequeuing pulls elements from
/// the front of the queue.
///
/// Adapted from: https://github.com/raywenderlich/swift-algorithm-club/blob/master/Queue/Queue-Optimized.swift
///
/// - Complexity: Enqueuing and dequeuing are O(1) operations.
struct Queue<T> {
    fileprivate var array = [T?]()
    fileprivate var head = 0

    var isEmpty: Bool {
        // swiftlint:disable:next empty_count
        count == 0
    }

    var count: Int {
        array.count - head
    }

    mutating func enqueue(_ element: T) {
        array.append(element)
    }

    mutating func dequeue() -> T? {
        guard let element = array[guarded: head] else {
            return nil
        }

        array[head] = nil
        head += 1

        let percentage = Double(head) / Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }

        return element
    }

    mutating func clear() {
        array = [T?]()
        head = 0
    }

    var front: T? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
}

extension Array {

    subscript(guarded idx: Int) -> Element? {
        guard (startIndex..<endIndex).contains(idx) else {
            return nil
        }
        return self[idx]
    }

}
