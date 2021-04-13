import Foundation

struct DTActionQueue {

    var queue = Queue<DTAction>()
    weak var delegate: DTActionQueueDelegate?

    var isEmpty: Bool {
        queue.isEmpty
    }

    mutating func enqueueAction(_ action: DTAction) {
        queue.enqueue(action)
        guard let delegate = delegate else {
            return
        }
        while delegate.canDispatchAction(), let action = queue.dequeue() {
            delegate.dispatchActionQuietly(action)
        }
    }

    mutating func dequeueAction() -> DTAction? {
        queue.dequeue()
    }

    mutating func clear() {
        queue.clear()
    }

}
