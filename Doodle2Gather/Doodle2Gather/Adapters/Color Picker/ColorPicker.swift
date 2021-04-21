import UIKit

/// Controller that manages a color picker and width and opacity sliders.
protocol ColorPicker {
    
    /// Updates the color picker to the cached values for the given tool and
    /// returns the cached values.
    func setToolAndGetProperties(_ tool: DrawingTools) -> (width: CGFloat, color: UIColor)

    /// Hides the sliders for stroke editing mode.
    func enterEditStrokeMode(color: UIColor)

    /// Unhides the sliders for normal editing mode.
    func exitEditStrokeMode()

}
