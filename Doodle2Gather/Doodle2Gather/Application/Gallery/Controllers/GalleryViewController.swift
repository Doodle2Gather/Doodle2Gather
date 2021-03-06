import UIKit
import DTSharedLibrary

class GalleryViewController: UIViewController {

    // Storyboard UI Elements
    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!

    // States
    private var rooms = [DTAdaptedRoom]()
    private var doodles = [DTAdaptedDoodle]()
    private var didFetchRooms = false
    private var selectedCellIndex: Int?
    private var isInEditMode = false
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    private var loadingSpinner: UIAlertController?

    // WebSocket Controllers
    var appWSController: DTWebSocketController?
    let homeWSController = DTHomeWebSocketController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appWSController?.registerSubcontroller(self.homeWSController)

        self.homeWSController.delegate = self
        if let user = DTAuth.user {
            welcomeLabel.text = "Welcome, \(user.displayName)!"
            homeWSController.getAccessibleRooms()
        } else {
            welcomeLabel.text = "Welcome"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didFetchRooms {
            loadingSpinner = createSpinnerView(message: "Loading...")
        }
    }

    deinit {
        self.appWSController?.removeSubcontroller(self.homeWSController)
    }

    /// Prepares for segues that have nested subview/container view as destination.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.toNewDocument {
            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            guard let vc = nav.topViewController as? NewDocumentViewController else {
                return
            }
            vc.homeWSController = self.homeWSController
            vc.checkDocumentNameCallback = { title in
                let match = self.rooms.first { room -> Bool in
                    room.name == title
                }
                if match != nil {
                    DTLogger.error("The name is already taken.")
                    return CreateDocumentStatus.duplicatedName
                } else {
                    return CreateDocumentStatus.success
                }
            }
            vc.didCreateDocumentCallback = { room in
                self.rooms.append(room)
                self.collectionView.reloadData()
            }
            vc.joinDocumentCallback = { room in
                self.rooms.append(room)
                self.collectionView.reloadData()
            }
        }
    }

}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let storyboard = UIStoryboard(name: "Doodle", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Doodle")
                as? DoodleViewController else {
            return
        }
        vc.appWSController = self.appWSController
        vc.room = self.rooms[index]
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .flipHorizontal
        vc.galleryDelegate = self
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rooms.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "documentCell",
                                                            for: indexPath) as? DocumentPreviewCell else {
            fatalError("Incorrect cell type")
        }
        cell.setName(rooms[indexPath.row].name)
        if rooms.count > indexPath.row {
            guard let topLayer = rooms[indexPath.row].doodles.first else {
                return cell
            }
            let previewImage = DoodlePreview(of: topLayer).image
            DispatchQueue.main.async {
                cell.setImage(previewImage)
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {

    /// Computes the optimal layout from the offered frame.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calculateWidth()
        return CGSize(width: width, height: width)
    }

    private func calculateWidth() -> CGFloat {
        let defaultWidth: CGFloat = 240
        let columnCount = floor(CGFloat(view.frame.size.width) / defaultWidth)

        let margin: CGFloat = 20
        let width = (view.frame.size.width - margin * (columnCount - 1) - margin * 2) / columnCount

        return width
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }

}

// MARK: - DTHomeWebSocketControllerDelegate

extension GalleryViewController: DTHomeWebSocketControllerDelegate {

    /// Updates the collection view when a message is received from the WebSocket Controller.
    func didGetAccessibleRooms(newRooms: [DTAdaptedRoom]) {
        DTLogger.info { "Received rooms: \(newRooms.map { $0.name })" }
        self.rooms = newRooms
        self.didFetchRooms = true
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if let loadingSpinner = self.loadingSpinner {
                self.removeSpinnerView(loadingSpinner)
            }
        }
    }
}

// MARK: - GalleryDelegate

extension GalleryViewController: GalleryDelegate {

    /// Calls the WebSocket Controller to refetch rooms when user exits one room.
    func didExitRoom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.homeWSController.getAccessibleRooms()
        }
    }

}
