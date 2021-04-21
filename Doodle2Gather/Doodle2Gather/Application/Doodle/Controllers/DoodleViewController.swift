import UIKit
import DTSharedLibrary

class DoodleViewController: UIViewController {

    // MARK: - Initialization + Navigation

    // Storyboard UI Elements
    @IBOutlet private var zoomScaleLabel: UILabel!
    @IBOutlet private var layerTableView: UIView!

    // Top Left Options
    @IBOutlet private var exitButton: UIButton!
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var separatorView: UIImageView!
    @IBOutlet private var inviteButton: UIButton!
    @IBOutlet private var exportButton: UIButton!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var redoButton: UIButton!

    // Profile Labels
    @IBOutlet private var userProfileLabel: UILabel!
    @IBOutlet private var separator: UIImageView!
    @IBOutlet private var otherProfileLabelOne: UILabel!
    @IBOutlet private var otherProfileLabelTwo: UILabel!
    @IBOutlet private var numberOfOtherUsersLabel: UILabel!

    // Subview Controllers
    var canvasController: CanvasController?
    var appWSController: DTWebSocketController?
    var roomWSController = DTRoomWebSocketController()
    var leftPanelsController: LeftPanelsController?
    var layerTable: DoodleLayerTable?
    var loadingSpinner: UIAlertController?

    // Delegates
    weak var invitationDelegate: InvitationDelegate?
    weak var galleryDelegate: GalleryDelegate?

    // State
    var room: DTAdaptedRoom?
    var doodles: [DTDoodleWrapper]?
    var didFetchDoodles = false
    var userAccesses: [DTAdaptedUserAccesses] = []
    var userStates: [UserState] = []
    var userIconColors: [UIColor] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let room = room,
              let roomId = room.roomId else {
            fatalError("Doodle VC has no injected room")
        }
        self.appWSController?.registerSubcontroller(self.roomWSController)
        self.roomWSController.roomId = roomId
        self.roomWSController.delegate = self
        self.roomWSController.joinRoom(roomId: roomId)

        fileNameLabel.text = room.name

        registerGestures()
        initialiseProfileIcons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didFetchDoodles {
            loadingSpinner = createSpinnerView(message: "Fetching Doodles...")
        }
    }

    deinit {
        roomWSController.exitRoom()
        self.appWSController?.removeSubcontroller(self.roomWSController)
    }

    private func registerGestures() {
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomScaleDidTap(_:)))
        zoomScaleLabel.addGestureRecognizer(zoomTap)
    }

    private func initialiseProfileIcons() {
        for _ in 0..<UIConstants.userIconColorCount {
            userIconColors.append(generateRandomColor())
        }

        numberOfOtherUsersLabel.layer.borderColor = UIConstants.stackGrey.cgColor
        userProfileLabel.layer.borderColor = UIConstants.white.cgColor
        otherProfileLabelOne.layer.borderColor = UIConstants.white.cgColor
        otherProfileLabelTwo.layer.borderColor = UIConstants.white.cgColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toCanvas, SegueConstants.toLeftPanels, SegueConstants.toConference:
            prepareForSubviews(for: segue, sender: sender)
        case SegueConstants.toLayerTable, SegueConstants.toInvitation:
            prepareForPopUps(for: segue, sender: sender)
        default:
            return
        }
    }

    /// Prepares for segues that has a nested subview/container view as destination.
    /// Generally, this is used for setting up references via the delegate pattern.
    /// The destination should also be abstracted away by a protocol, if possible.
    func prepareForSubviews(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toCanvas:
            guard let destination = segue.destination as? DTCanvasViewController else {
                return
            }
            destination.delegate = self
            if let doodles = self.doodles {
                destination.loadDoodles(doodles)
            }
            self.canvasController = destination
        case SegueConstants.toLeftPanels:
            guard let destination = segue.destination as? LeftPanelsViewController else {
                return
            }
            destination.delegate = self
            self.leftPanelsController = destination
        case SegueConstants.toConference:
            guard let destination = segue.destination as? ConferenceViewController else {
                return
            }
            guard let roomId = room?.roomId?.uuidString else {
                return
            }
            destination.roomId = roomId
            destination.roomWSController = self.roomWSController
        default:
            return
        }
    }

    /// Prepares for segues that has a popup as a destination.
    /// Generally, this is used for dependency injection.
    func prepareForPopUps(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstants.toLayerTable:
            guard let destination = segue.destination as? DoodleLayerTableViewController else {
                return
            }
            destination.delegate = self
            if let doodles = self.doodles {
                destination.loadDoodles(doodles)
            }
            self.layerTable = destination
        case SegueConstants.toInvitation:
            guard let destination = segue.destination as? InvitationViewController else {
                return
            }
            destination.modalPresentationStyle = .formSheet
            destination.userAccesses = userAccesses
            invitationDelegate = destination
            guard let room = room else {
                return
            }
            destination.room = room
            destination.roomWSController = roomWSController
        default:
            return
        }
    }

}

// MARK: - Top Right: Profile Icons

extension DoodleViewController {

    /// Updates the colour and label displayed on the user icons on the top right.
    func updateProfileIcons() {
        guard let user = DTAuth.user else {
            DTLogger.error("Attempted to join room without a user.")
            return
        }

        setProfileLabel(userProfileLabel, text: user.displayName)
        userProfileLabel.backgroundColor = userIconColors[0]

        let otherUserStates = userStates.filter({ state -> Bool in
            state.userId != user.uid
        })
        let labels: [UILabel?] = [otherProfileLabelOne, otherProfileLabelTwo, numberOfOtherUsersLabel]

        for i in 0..<labels.count {
            guard let label = labels[i] else {
                fatalError("Label is not loaded")
            }
            if i >= otherUserStates.count {
                label.isHidden = true
                continue
            }
            label.isHidden = false
            if i < labels.count - 1 {
                setProfileLabel(label, text: otherUserStates[i].displayName)
                label.backgroundColor = userIconColors[i + 1]
            }
        }

        separator.isHidden = otherUserStates.isEmpty
        if otherUserStates.count > 2 {
            numberOfOtherUsersLabel.text = "+\(userStates.count - 3)"
        }
    }

    /// Sets the first character of the text as the label content.
    private func setProfileLabel(_ label: UILabel, text: String) {
        if let firstChar = text.first(where: {
            !$0.isWhitespace
        }) {
            label.text = String(firstChar)
        } else {
            label.text = "-"
        }
    }

    private func generateRandomColor() -> UIColor {
        UIColor(
            red: .random(in: 0..<1),
            green: .random(in: 0..<1),
            blue: .random(in: 0..<1),
            alpha: 1.0
        )
    }

}

// MARK: - Top Left: Exit + Invitation + Export + Undo/Redo

extension DoodleViewController {

    /// Minimizes the top left panel to give more space for doodling.
    @IBAction private func topMinimizeButtonDidTap(_ sender: UIButton) {
        fileNameLabel.isHidden.toggle()
        separatorView.isHidden.toggle()
        inviteButton.isHidden.toggle()
        exportButton.isHidden.toggle()
        exitButton.isHidden.toggle()
        sender.isSelected.toggle()
    }

    /// Exports the doodle as a separate file.
    ///
    /// - Note: Currently, we only support saving as an image. In future extensions, we will
    ///   look into more formats.
    @IBAction private func exportButtonDidTap(_ sender: UIButton) {
        guard let currentDoodle = canvasController?.getCurrentDoodle() else {
            alert(title: "Notice",
                  message: "Unable to export at the moment. Please try again later.",
                  buttonStyle: .default)
            return
        }
        let imageToExport = DoodlePreview(of: currentDoodle.drawing).image
        UIImageWriteToSavedPhotosAlbum(imageToExport, self,
                                       #selector(export(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    /// Navigates to the previous gallery view screen.
    @IBAction private func exitButtonDidTap(_ sender: UIButton) {
        alert(title: AlertConstants.exit, message: AlertConstants.exitToMainMenu,
              buttonStyle: .default, handler: { _ in
                self.dismiss(animated: true, completion: {
                    self.galleryDelegate?.didExitRoom()
                })
              }
        )
    }

    @IBAction private func undoButtonDidTap(_ sender: Any) {
        guard let canvasController = canvasController, canvasController.canUndo else {
            return
        }
        canvasController.undo()
    }

    @IBAction private func redoButtonDidTap(_ sender: Any) {
        guard let canvasController = canvasController, canvasController.canRedo else {
            return
        }
        canvasController.redo()
    }

    /// Updates the status of the undo and redo buttons based on whether an undo or redo
    /// is possible.
    func updateUndoRedoButtons() {
        undoButton.isEnabled = canvasController?.canUndo ?? false
        redoButton.isEnabled = canvasController?.canRedo ?? false
    }

    func setZoomText(scalePercent: Int) {
        zoomScaleLabel.text = "\(scalePercent)%"
    }

    /// Exports the `UIImage` as a photo file.
    @objc
    func export(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            DTLogger.error(error.localizedDescription)
            alert(title: "Error",
                  message: "Unable to save the image to the device. Please try again later.",
                  buttonStyle: .default)
        } else {
            alert(title: "Saved!",
                  message: "Your doodle has been saved to your photos successfully!",
                  buttonStyle: .default)
        }
    }

}

// MARK: - Bottom Right: DoodleLayerTableDelegate + Layers + Zoom

extension DoodleViewController: DoodleLayerTableDelegate {

    func selectedDoodleDidChange(index: Int) {
        canvasController?.setSelectedDoodle(index: index)
    }

    @IBAction private func layerButtonDidTap(_ sender: UIButton) {
        if let doodles = canvasController?.getCurrentDoodles() {
            layerTable?.loadDoodles(doodles)
        }
        layerTableView.isHidden.toggle()
        sender.isSelected.toggle()
    }

    @IBAction private func addLayerButtonDidTap(_ sender: UIButton) {
        roomWSController.addDoodle()
    }

    @objc
    private func zoomScaleDidTap(_ gesture: UITapGestureRecognizer) {
        canvasController?.resetZoomScaleAndCenter()
    }

}
