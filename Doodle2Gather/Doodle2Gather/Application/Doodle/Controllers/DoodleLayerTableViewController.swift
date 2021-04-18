import UIKit
import DTSharedLibrary

class DoodleLayerTableViewController: UITableViewController {

    var doodles = [DTAdaptedDoodle]()
    var selectedDoodleIndex = 0
    weak var delegate: DoodleLayerTableDelegate?

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        doodles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LayerTableViewCell",
                                                       for: indexPath) as? DoodleLayerTableViewCell else {
            fatalError("Unknown table cell type being dequeued")
        }

        let doodle = doodles[indexPath.row]
        cell.setName("Layer \(indexPath.row + 1)")
        cell.setImageView(DTDoodlePreview(doodle: doodle))
        cell.index = indexPath.row
        cell.isSelected = selectedDoodleIndex == indexPath.row
        cell.delegate = self

        return cell
    }

}

extension DoodleLayerTableViewController: DoodleLayerCellDelegate {

    func buttonDidTap(index: Int) {
        delegate?.selectedDoodleDidChange(index: index)
        selectedDoodleIndex = index
        tableView.reloadData()
    }

}

extension DoodleLayerTableViewController: DoodleLayerTable {

    func loadDoodles(_ doodles: [DTAdaptedDoodle]) {
        self.doodles = doodles
        selectedDoodleIndex = 0
        tableView.reloadData()
    }

}
