
import UIKit

class GroupDetailController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var threadModel: ThreadModel?
    var threadParticipants: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.getThreadDetails()
    }
    
    func getThreadUser() {
        self.threadParticipants.removeAll()
        
        if let thread = self.threadModel {
            FirebaseThread.getThreadParticipants(threadId: thread.key ?? "") { (user) in
                self.threadParticipants.append(user)
                self.tableView.reloadData()
            }
        }
    }
    
    func getThreadDetails() {
        FirebaseThread.init(threadId: threadModel?.key ?? "").getThreadSingle(completion: { (isSuccess, thread) in
             self.threadModel = thread
             self.getThreadUser()
             self.setNavigationBar()
        })
    }
    
    func showRemoveParticipantPopup(userModel: UserModel) {
        Utility.showAlert(title: "Remove Member", message: "Are you sure you want to remove \(userModel.meta?.name ?? "") from group.", positiveText: "Yes", positiveClosure: { (action) in
            FirebaseThread.init(threadId: self.threadModel?.key ?? "").removeParticipantFromGroup(threadId: self.threadModel?.key ?? "", participantId: userModel.key ?? "")
            self.threadParticipants.removeAll(where: {$0.key == userModel.key ?? ""})
            self.threadModel?.users?.removeValue(forKey: userModel.key ?? "")
            self.tableView.reloadData()
        }, navgativeText: "No")
    }
    
    func showLeaveParticipantPopup() {
        Utility.showAlert(title: "Leave Group", message: "Are you sure you want to leave group.", positiveText: "Yes", positiveClosure: { (action) in
            self.threadParticipants.removeAll(where: {$0.key == AppStateManager.sharedInstance.userId})
            FirebaseThread.init(threadId: self.threadModel?.key ?? "").removeParticipantFromGroup(threadId: self.threadModel?.key ?? "", participantId: AppStateManager.sharedInstance.userId)

            if self.threadModel?.isAmIAdmin() ?? false {
                FirebaseThread.init(threadId: self.threadModel?.key ?? "").makeAdmin(userId: self.threadParticipants.first?.key ?? "")
            }

            self.navigationController?.popToRootViewController(animated: true)
        }, navgativeText: "No")
    }
    
    func showMakeAdmin(userModel: UserModel) {
        Utility.showAlert(title: "Grant Admin Access", message: "Are you sure you want to grant \(userModel.meta?.name ?? "") admin access.", positiveText: "Yes", positiveClosure: { (action) in
            if self.threadModel?.isAmIAdmin() ?? false {
                FirebaseThread.init(threadId: self.threadModel?.key ?? "").makeAdmin(userId: userModel.key ?? "")
            }
        }, navgativeText: "No")
    }
    
    func showActions(userModel: UserModel) {
        let alert = UIAlertController(title: "Group Actions", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.default, handler: { action in
            self.showRemoveParticipantPopup(userModel: userModel)
        }))
        alert.addAction(UIAlertAction(title: "Make Admin", style: UIAlertAction.Style.default, handler: { action in
            self.showMakeAdmin(userModel: userModel)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setNavigationBar() {
        self.title = "Participants"
        
        if self.threadModel?.isAmIAdmin() ?? false {
           navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
        }
        
    }
    
    @objc func actionAdd() {
        self.navigateToAddParticipants()
    }
    
    func navigateToAddParticipants() {
        let groupAddMemberVC = GroupAddMemberController.instantiate(fromAppStoryboard: .Home)
        groupAddMemberVC.forCreatingGroup = false
        groupAddMemberVC.groupTitle = threadModel?.details?.name ?? ""
        groupAddMemberVC.alreadyAddedMembers = threadModel?.users ?? [:]
        groupAddMemberVC.threadId = self.threadModel?.key ?? ""
        Utility().topViewController()?.navigationController?.pushViewController(groupAddMemberVC, animated: true)
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: "AddFriendsCell", bundle: nil), forCellReuseIdentifier: "AddFriendsCell")
    }
    
    @IBAction func tappedOnLeave() {
       self.showLeaveParticipantPopup()
    }
    
}

extension GroupDetailController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let user = threadParticipants[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsCell", for: indexPath) as! AddFriendsCell
        cell.setData(userData: user, isAlreadyAdded: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.threadModel?.isAmIAdmin() ?? false {
            let user = threadParticipants[indexPath.row]

            if !user.isCurrentUser() {
                self.showActions(userModel: user)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threadParticipants.count
    }
    
    
}
