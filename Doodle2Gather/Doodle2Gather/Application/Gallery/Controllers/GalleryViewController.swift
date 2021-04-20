import UIKit
import DTSharedLibrary

class GalleryViewController: UIViewController {

    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!

    private var rooms = [DTAdaptedRoom]()
    private var doodles = [DTAdaptedDoodle]()
    private var selectedCellIndex: Int?
    private var isInEditMode = false

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
        // Do any additional setup after loading the view.
    }

    deinit {
        self.appWSController?.removeSubcontroller(self.homeWSController)
    }

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
        vc.username = DTAuth.user?.displayName ?? "Unknown"
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .flipHorizontal
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
            guard let previewImage = DTDoodlePreview(doodle: topLayer).image else {
                return cell
            }
            DispatchQueue.main.async {
                cell.setImage(previewImage)
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
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
}

extension GalleryViewController: DTHomeWebSocketControllerDelegate {
    func didGetAccessibleRooms(newRooms: [DTAdaptedRoom]) {
        DTLogger.info { "Received rooms: \(newRooms.map { $0.name } )" }
        self.rooms = newRooms
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
