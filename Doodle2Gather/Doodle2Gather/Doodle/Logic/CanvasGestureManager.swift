import UIKit

/// Represents a low-level manager of the canvas that works with
/// gestures and permissions.
///
/// This gesture manager is in charge of translating tools selected by
/// users into specific gestures, and handle those gestures accordingly.
///
/// Upon detection of a gesture that results in a change that should be
/// propagated to other users, this gesture manager should update its
/// delegate of so.
protocol CanvasGestureManager: NSObject {

    /// Strokes with additional properties, especially the permissions.
    /// This allows for permission handling of the gestures.
    var strokeWrappers: [DTStrokeWrapper] { get set }

    /// Configures whether the canvas should respond to gestures from
    /// the user.
    var canEdit: Bool { get set }

    /// Delegate for this gesture manager.
    var delegate: CanvasGestureManagerDelegate? { get set }

    /// Sets the main tool that is being used on the canvas and the
    /// respective gestures.
    /// See `MainTools` for more information.
    func setMainTool(_ mainTool: MainTools)

    /// Sets the drawing tool that is being used on the canvas and the
    /// respective gestures.
    /// See `DrawingTools` for more information.
    func setDrawingTool(_ drawingTool: DrawingTools)

    /// Sets the shape tool that is being used on the canvas and the
    /// respective gestures.
    /// See `ShapeTools` for more information.
    func setShapeTool(_ shapeTool: ShapeTools)

    /// Sets the permission tool that is being used on the canvas and the
    /// respective gestures.
    /// See `SelectTools` for more information.
    func setSelectTool(_ selectTool: SelectTools)

    /// Sets the color of the stroke being drawn.
    /// This is only relevant if the tool being utilised currently results in a
    /// stroke being drawn.
    func setColor(_ color: UIColor)

    /// Sets the width of the stroke being drawn.
    /// This is only relevant if the tool being utilised currently results in a
    /// stroke being drawn.
    func setWidth(_ width: CGFloat)

    /// Toggles whether the stroke should have differing width based on
    /// the pressure exerted by the user when drawing.
    func setIsPressureSensitive(_ isPressureSensitive: Bool)

}
