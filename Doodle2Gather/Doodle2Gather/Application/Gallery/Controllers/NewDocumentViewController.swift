//
//  NewDocumentViewController.swift
//  Doodle2Gather
//
//  Created by Wang on 3/4/21.
//

import UIKit

enum CreateDocumentStatus {
    case success
    case duplicatedName
}

class NewDocumentViewController: UIViewController {

    @IBOutlet private var titleTextField: UITextField!

    var createDocumentCallback: ((String) -> CreateDocumentStatus)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction private func didTapCreate(_ sender: Any) {
        guard let callback = createDocumentCallback else {
            return
        }
        guard let title = titleTextField.text else {
            return
        }
        guard !title.isEmpty else {
            return
        }
        if callback(title) == .duplicatedName {
            return
        }
        dismiss(animated: true, completion: nil)
    }
}
