
//
//  ChatsViewController.swift
//  BasicStructureUpdate
//
//  Created by Muzammil on 8/9/19.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseCore
import FirebaseDatabase


class ContactsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var users: [UserModel] = []
    var allUsers: [UserModel] = []
    
    private var sections: [[UserModel]] = []
    private let collation = UILocalizedIndexedCollation.current()


    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        setNavigation()
        setDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getContacts()
        self.tabBarController?.tabBar.isHidden = false
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

    func hideTabBar() {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setNavigation() {
        title = "Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
    }
    
    private func navigateToMesssagesVC(user: UserModel) {
        //TODO: Show Loader here
        if let result = user.threads?.filter({$0.value["invitedBy"] == user.key || $0.value["invitedBy"] == AppStateManager.sharedInstance.userId}).first {
            FirebaseThread.init(threadId: result.key).getThreadSingle(completion: { (isSuccess, thread) in
                if let thread = thread {
                    self.navigateToMesssagesVC(thread: thread)
                }
                
            })
        }
    }
    
    func navigateToMesssagesVC(thread: ThreadModel) {
        hideTabBar()
        let messsageVC = MessagesViewController.instantiate(fromAppStoryboard: .Home)
        messsageVC.thread = thread
        self.navigationController?.pushViewController(messsageVC, animated: true)
    }
    
    func getContacts() {
        self.allUsers.removeAll()
        
        FirebaseContacts.init().getContacts { (contacts) in
            if let contacts = contacts {
                let userIds = contacts.map({$0.key ?? ""})
                userIds.forEach({ (userId) in
                    FirebaseUser.init(userId: userId).getUserById(completeHandler: { (user) in
                        guard let user = user else {
                            return
                        }
                        self.allUsers.append(user)
                        self.users = self.allUsers
                        self.resetData()
                    })
                })
            }
        }
    }
    
    @objc func actionAdd() {
       self.navigateToAddFriendsVC()
    }
    
    func navigateToAddFriendsVC() {
        hideTabBar()
        
        let addContactVC = UsersViewController.instantiate(fromAppStoryboard: .Home)
        self.navigationController?.pushViewController(addContactVC, animated: true)
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
    
    func createThread(user: UserModel) {
        // TODO: Start Loader here
        FirebaseThread.init().createThread(userId: user.key ?? "", name: user.meta?.name ?? "") { (isSuccess) in
            // TODO: Hide loader here
            self.navigateToMesssagesVC(user: user)
        }
    }
    
    func refreshTableView() {
        
        tableView.reloadData()
    }
    
    func searchContact(keyword: String) {
        if keyword.trimmedString().isEmpty {
            Utility.showErrorWith(message: Messages.EnterKeywordForSearch.rawValue, presentationStyle: .top)
        } else {
            users = allUsers.filter({$0.meta?.namelowercase?.contains(keyword.lowercased()) ?? false})
            self.resetData()
            if users.count ?? 0 <= 0 {
                Utility.showAlert(title: "Not Found", message: "No results found")
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        dismissKeyboard()
    }
    
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
        
        cell.setData(userData: user, isAlreadyAdded: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = sections[indexPath.section][indexPath.row]

        self.navigateToMesssagesVC(user: user)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.users = self.allUsers
            self.resetData()
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
    }
    
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {
        searchBar.resignFirstResponder()
        searchContact(keyword: searchBar_.text ?? "")
    }
}
