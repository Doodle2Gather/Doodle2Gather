import UIKit
import DTFrontendLibrary

struct Room: DTRoom {
    var roomId: UUID
    var roomName: String
}

class GalleryViewController: UIViewController {

    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    private var rooms = [Room]()
    private var selectedCellIndex: Int?
    var count = 1

    private enum DefaultValues {
        static let username = UIDevice.current.name
        // For ease of development
        static let password = "goodpassword"
        static let roomName = "devRoom"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rooms.append(Room(roomId: UUID(), roomName: DefaultValues.roomName))

        if let user = DTAuth.user {
            welcomeLabel.text = "Welcome, \(user.displayName)!"
        } else {
            welcomeLabel.text = "Welcome"
        }
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueConstants.toNewDocument {
            guard let vc = segue.destination as? NewDocumentViewController else {
                return
            }
            vc.createDocumentCallback = { title in
                let match = self.rooms.first { room -> Bool in
                    room.roomName == title
                }
                if match != nil {
                    print("The name is already taken.")
                    return CreateDocumentStatus.duplicatedName
                } else {
                    self.rooms.append(Room(roomId: UUID(), roomName: title))
                    self.collectionView.reloadData()
                    return CreateDocumentStatus.success
                }
            }
        }
    }

    @IBAction private func didTapAdd(_ sender: Any) {
        rooms.append(Room(roomId: UUID(), roomName: "Room \(count)"))
        count += 1
        collectionView.reloadData()
    }

    @IBAction private func didTapEdit(_ sender: Any) {

    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let storyboard = UIStoryboard(name: "Doodle", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Doodle")
                as? DoodleViewController else {
            return
        }
        vc.username = DefaultValues.username
        vc.roomName = rooms[index].roomName
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .flipHorizontal
        self.present(vc, animated: true, completion: nil)
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rooms.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "documentCell",
                                                      for: indexPath) as? DocumentPreviewCell
        cell?.setName(rooms[indexPath.row].roomName)
        return cell!
    }
}

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
