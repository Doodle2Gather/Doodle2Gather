protocol DoodlePageTableDelegate: AnyObject {

    /// Informs the delegate that another layer was selected.
    func selectedDoodleDidChange(index: Int)

}
