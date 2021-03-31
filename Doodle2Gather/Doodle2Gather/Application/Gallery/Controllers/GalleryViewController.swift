//
//  GalleryViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 31/3/21.
//

import UIKit

class GalleryViewController: UIViewController {

    enum Segues {
        static let toDoodle = "goToDoodle"
        static let toGallery = "toGallery"
    }

    private enum DefaultValues {
        static let username = UIDevice.current.name
        // For ease of development
        static let password = "goodpassword"
        static let roomName = "devRoom"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toDoodle {
            guard let vc = segue.destination as? DoodleViewController else {
                fatalError("Unable to get DoodleViewController")
            }
            vc.username = DefaultValues.username
            vc.roomName = DefaultValues.roomName
        }
    }
}
