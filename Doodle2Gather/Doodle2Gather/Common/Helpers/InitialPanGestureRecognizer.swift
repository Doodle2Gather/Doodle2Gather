import UIKit.UIGestureRecognizerSubclass

/// Subclass of UIPanGestureRecogniser that gives us the iniital touch point.
/// Adapted from:
/// https://stackoverflow.com/a/31225084
class InitialPanGestureRecognizer: UIPanGestureRecognizer {
    var initialTouchLocation: CGPoint!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first!.location(in: view)
    }
}
