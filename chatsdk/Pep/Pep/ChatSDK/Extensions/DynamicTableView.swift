import UIKit

class DynamicTableView: UITableView {

    
    
    override var intrinsicContentSize: CGSize {
        return contentSize

    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadRows(at: indexPaths, with: animation)
        self.invalidateIntrinsicContentSize()

        
    }

}
