
import Foundation
import UIKit

class CreateGroupController: UIViewController {

    @IBOutlet weak var groupTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigation()
    }
    
    @IBAction func tappedOnCreateGroup() {
        self.navigateToUsersVC()
    }
    
    func setNavigation() {
        title = "Group Creation"
    }
    
    func navigateToUsersVC() {
        
        if groupTitle.text?.isEmpty ?? false {
            Utility.showErrorWith(message: Errors.EnterGroupTitle.rawValue)
            return
        }
        
        let groupAddMemberVC = GroupAddMemberController.instantiate(fromAppStoryboard: .Home)
        groupAddMemberVC.forCreatingGroup = true
        groupAddMemberVC.groupTitle = groupTitle.text ?? ""
        Utility().topViewController()?.navigationController?.pushViewController(groupAddMemberVC, animated: true)
    }
}
