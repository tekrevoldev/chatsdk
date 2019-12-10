import UIKit
import ProgressHUD


class UsersViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var users: [UserModel] = []
    private var sections: [[UserModel]] = []
    private let collation = UILocalizedIndexedCollation.current()
    var logginUserContacts: [ContactsModel]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setNavigation()
        getLogginUserContacts()
        getUsers()
        setDelegates()
    }
    
    private func getLogginUserContacts() {
        FirebaseContacts.init().getContacts { (contacts) in
            self.logginUserContacts = contacts
            self.tableView.reloadData()
        }
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
        title = "Add Friends"
    }
    
    func getUsers() {
        FirebaseUser.init().getUsers { (users) in
            self.users = users ?? []
            self.resetData()
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
                self.resetData()

            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        dismissKeyboard()
    }

    func addContact(user: UserModel) {
        if self.logginUserContacts?.filter({$0.key ?? "" == user.key ?? ""}).count ?? 0 > 0 {
            ProgressHUD.showSuccess("Contact already added")
            return
        }
        
        if (!user.isCurrentUser()) {
                FirebaseContacts.init().addContact(userObjectId: user.key ?? "") { (isSuccess) in
                FirebaseThread.init().createThread(userId: user.key ?? "", name: user.meta?.name ?? "") { (isSuccess) in
                    ProgressHUD.showSuccess("Contact Added successfully")
                }
                self.getLogginUserContacts()
            }
        } else {
            ProgressHUD.showSuccess("This is you.")
        }
    }
    
   
}

// MARK: TableView Delegates
extension UsersViewController : UITableViewDataSource, UITableViewDelegate  {
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
        
        cell.setData(userData: user, isAlreadyAdded: self.logginUserContacts?.filter({$0.key ?? "" == user.key ?? ""}).count ?? 0 > 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = sections[indexPath.section][indexPath.row]

        addContact(user: user)
    }
}
// MARK: Search Bar Delegates
extension UsersViewController : UISearchBarDelegate {
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
