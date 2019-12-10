import UIKit
import ProgressHUD
import Foundation


class GroupAddMemberController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var users: [UserModel] = []
    private var sections: [[UserModel]] = []
    private let collation = UILocalizedIndexedCollation.current()
    
    // MARK: GROUP INITIALS
    var forCreatingGroup = false
    var groupTitle = ""
    var selectedMembers: [String : Bool] = [:]
    var alreadyAddedMembers: [String : [String : String]] = [:]
    var threadId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setNavigation()
        getUsers()
        setDelegates()
        enableSelectionIfNeeded()
    
    }
    
    private func enableSelectionIfNeeded() {
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.isEditing = true
    }
    
    private func setDelegates() {
        searchBar.delegate = self
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: "AddFriendsCell", bundle: nil), forCellReuseIdentifier: "AddFriendsCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    
    func setNavigation() {
        title = "Add Participants"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionCreate))
        
    }
    
    func getUsers() {
        FirebaseUser.init().getUsers { (users) in
            self.users = users ?? []
            self.resetData()
        }
    }
    
    @objc func actionCreate() {
        // TODO: Show loader here
        FirebaseThread.init().createGroupThread(Id: threadId ?? "" ,userIds: self.selectedMembers.map({$0.key}), name: groupTitle) { (isSuccess) in
            // TODO: Hide loader here
            if self.forCreatingGroup {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func resetData() {
        
        sections.removeAll()
        
        sections = Array(repeating: [], count: collation.sectionTitles.count)
        
        let sorted = users.sorted(by: { $0.meta?.name ?? "" < $1.meta?.name ?? "" })
        for user in sorted {
            let fullname = user.meta?.name ?? ""
            
            if  let firstChar = fullname.first?.uppercased(), let index = collation.sectionTitles.index(of: firstChar) {
                sections[index].append(user)
            } else {
                sections[collation.sectionTitles.endIndex-1].append(user)
            }
        }
        
        refreshTableView()
    }
    
    func refreshTableView() {
        
        tableView.reloadData()
    }
    
    func searchContact(keyword: String) {
        if keyword.trimmedString().isEmpty {
            Utility.showErrorWith(message: Messages.EnterKeywordForSearch.rawValue, presentationStyle: .top)
        } else {
            FirebaseUser.init().searchUsers(keyword: keyword) { (users) in
                if users?.count ?? 0 <= 0 {
                    Utility.showAlert(title: "Not Found", message: "No results found")
                }
                
                self.users = users ?? []
                self.users = self.users.filter({$0.key != AppStateManager.sharedInstance.userId})
                self.resetData()
                
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}

// MARK: TableView Delegates
extension GroupAddMemberController : UITableViewDataSource, UITableViewDelegate  {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return (sections[section].count != 0) ? collation.sectionTitles[section] : nil
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return collation.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return collation.section(forSectionIndexTitle: index)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsCell", for: indexPath) as! AddFriendsCell
        
        let user = sections[indexPath.section][indexPath.row]
        
        cell.setData(userData: user, isAlreadyAdded: alreadyAddedMembers[user.key ?? ""] != nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = sections[indexPath.section][indexPath.row]
        
        if alreadyAddedMembers[user.key ?? ""] == nil {
            selectedMembers[user.key ?? ""] = true
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if forCreatingGroup {
            let user = sections[indexPath.section][indexPath.row]
            selectedMembers.removeValue(forKey: user.key ?? "")
        }
    }
}
// MARK: Search Bar Delegates
extension GroupAddMemberController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.getUsers()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.getUsers()
    }
    
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        searchContact(keyword: searchBar_.text ?? "")
    }
}
