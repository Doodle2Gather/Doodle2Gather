import UIKit

/**
 Custom cell for video stream collection view.
 */
class VideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var videoView: VideoCollectionViewCell!

    func getVideoView() -> VideoCollectionViewCell {
        videoView
    }

}
