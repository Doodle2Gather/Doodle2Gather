import AVFoundation

/// Singleton audio player class that helps with SFX and BGM.
///
/// The below implementation is adapted from:
/// https://stackoverflow.com/a/50445279 and
/// https://www.zerotoappstore.com/how-to-add-background-music-in-swift.html
class AudioPlayer: NSObject {

    /// Shared instance.
    static let shared = AudioPlayer()
    var players: [URL: AVAudioPlayer] = [:]
    var duplicatePlayers: [AVAudioPlayer] = []

    override private init() {}

    /// Plays the sound specified by the filename.
    ///
    /// If the sound is not found, this method will fail silently (literally).
    ///
    /// - Parameter filename: The name of the audio file without
    ///   the extension. The extension is required to be `.mp3`.
    func playSound(fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
            return
        }
        let soundFileURL = URL(fileURLWithPath: path)
        var hasPlayer = false

        if let player = players[soundFileURL] {
            if !player.isPlaying {
                player.prepareToPlay()
                player.play()
                return
            }
            hasPlayer = true
        }

        guard let player = try? AVAudioPlayer(contentsOf: soundFileURL) else {
            // Fail silently
            return
        }

        if hasPlayer {
            player.delegate = self
            duplicatePlayers.append(player)
        } else {
            players[soundFileURL] = player
        }
        player.prepareToPlay()
        player.play()
    }

}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayer: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = duplicatePlayers.firstIndex(of: player) {
            duplicatePlayers.remove(at: index)
        }
    }

}
