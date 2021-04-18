import UIKit

// Taken from: https://stackoverflow.com/a/62835708

/// `ActionSheetAlertController` is custom class that presents
/// an action sheet without constraint errors. These constraint errors
/// occur during the animation and is an unfixed bug from Apple.
class ActionSheetAlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tweakProblemWidthConstraints()
    }

    func tweakProblemWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints {
                // Identify the problem constraint
                // Check that it's priority 1000 - which is the cause of the conflict.
                if constraint.firstAttribute == .width &&
                    constraint.constant == -16 &&
                    constraint.priority.rawValue == 1_000 {
                    // Let the framework know it's okay to break this constraint
                    constraint.priority = UILayoutPriority(rawValue: 999)
                }
            }
        }
    }
}
