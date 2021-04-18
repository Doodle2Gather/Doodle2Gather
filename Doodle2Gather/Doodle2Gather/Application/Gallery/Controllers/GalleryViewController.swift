import UIKit
import DTSharedLibrary

class GalleryViewController: UIViewController {

    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!

    private var rooms = [Room]()
    private var doodles = [DTAdaptedDoodle]()
    private var selectedCellIndex: Int?
    private var isInEditMode = false
    var count = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = DTAuth.user {
            welcomeLabel.text = "Welcome, \(user.displayName)!"
            DTApi.getUserAccessibleRooms(userId: user.uid) { result in
                switch result {
                case .failure(let error):
                    DTLogger.error(error.localizedDescription)
                case .success(.some(let rooms)):
                    self.rooms = rooms.map { guard let room = Room(room: $0) else {
                        fatalError("Cannot parse room")
                    }
                    return room
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                case .success(.none):
                    break
                }
            }
        } else {
            welcomeLabel.text = "Welcome"
        }
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.toNewDocument {
            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            guard let vc = nav.topViewController as? NewDocumentViewController else {
                return
            }
            vc.checkDocumentNameCallback = { title in
                let match = self.rooms.first { room -> Bool in
                    room.roomName == title
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

    @IBAction private func didTapEdit(_ sender: Any) {
        isInEditMode.toggle()
        if isInEditMode {
            for index in 0..<(rooms.count) {
                guard let cell = collectionView.cellForItem(at: IndexPath(row: index,
                                                                          section: 0)) as? DocumentPreviewCell else {
                    return
                }
                cell.setIsEditing(true)
            }
        } else {
            for index in 0..<(rooms.count) {
                guard let cell = collectionView.cellForItem(at: IndexPath(row: index,
                                                                          section: 0)) as? DocumentPreviewCell else {
                    return
                }
                cell.setIsEditing(false)
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

        DTApi.getRoomsDoodles(roomId: rooms[index].roomId) { result in
            switch result {
            case .failure(let error):
                DTLogger.error(error.localizedDescription)
            case .success(.some(let doodles)):
              DispatchQueue.main.async {
                vc.doodles = doodles
                vc.username = DTAuth.user?.displayName ?? "Unknown"
                vc.roomName = self.rooms[index].roomName
                vc.roomId = self.rooms[index].roomId
                vc.inviteCode = self.rooms[index].inviteCode
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .flipHorizontal
                self.present(vc, animated: true, completion: nil)
              }
            case .success(.none):
                break
            }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "documentCell",
                                                      for: indexPath) as? DocumentPreviewCell
        cell?.setName(rooms[indexPath.row].roomName)
        cell?.setIsEditing(false)
        return cell!
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
