import UIKit
import DTSharedLibrary

class DoodlePageTableViewController: UITableViewController {

    var doodles = [DTDoodleWrapper]()
    var selectedDoodleIndex = 0
    weak var delegate: DoodleLayerTableDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        doodles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PageTableViewCell",
                                                       for: indexPath) as? DoodlePageTableViewCell else {
            fatalError("Unknown table cell type being dequeued")
        }

        let doodle = doodles[indexPath.row]
        cell.setName("Page \(indexPath.row + 1)")
        cell.setImage(DoodlePreview(of: doodle.drawing).image)
        cell.index = indexPath.row
        cell.isSelected = selectedDoodleIndex == indexPath.row
        cell.delegate = self

        return cell
    }

}

extension DoodlePageTableViewController: DoodlePageCellDelegate {

    func buttonDidTap(index: Int) {
        delegate?.selectedDoodleDidChange(index: index)
        selectedDoodleIndex = index
        tableView.reloadData()
    }

}

extension DoodlePageTableViewController: DoodleLayerTable {

    func loadDoodles(_ doodles: [DTDoodleWrapper]) {
        self.doodles = doodles
        if selectedDoodleIndex >= self.doodles.count {
            selectedDoodleIndex = 0
            delegate?.selectedDoodleDidChange(index: 0)
        }
        tableView.reloadData()
    }

}
