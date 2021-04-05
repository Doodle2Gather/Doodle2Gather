struct DTActionQueue {

    var queue = Queue<DTNewAction>()
    weak var delegate: DTActionQueueDelegate?

    var isEmpty: Bool {
        queue.isEmpty
    }

    mutating func enqueueAction(_ action: DTNewAction) {
        queue.enqueue(action)
        guard let delegate = delegate else {
            return
        }
        while delegate.canDispatchAction(), let action = queue.dequeue() {
            delegate.dispatchActionQuietly(action)
        }
    }

    mutating func dequeueAction() -> DTNewAction? {
        queue.dequeue()
    }

    mutating func clear() {
        queue.clear()
    }

}
