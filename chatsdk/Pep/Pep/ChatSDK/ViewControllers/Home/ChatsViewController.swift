import UIKit

class ChatsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var threads: [ThreadModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerCells()
        self.setNavigation()
        self.getThreads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setNavigation() {
        self.title = "Chats"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
    }
    
    @objc func actionAdd() {
        self.navigationToGroupCreateVC()
    }
    
    func navigationToGroupCreateVC() {
        let groupCreateVC = CreateGroupController.instantiate(fromAppStoryboard: .Home)
        self.navigationController?.pushViewController(groupCreateVC, animated: true)
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: Cell.ChatCell.rawValue, bundle: nil), forCellReuseIdentifier: Cell.ChatCell.rawValue)
    }
    
//    func getThreads() {
//        self.threads = []
//        FirebaseThread.init().getThreads { (isSuccess, threads) in
//            if let thread = threads?.first {
//                if let index = self.threads.firstIndex(where: {$0.key == thread.key ?? ""}) {
//                    self.threads[index] = thread
//                } else {
//                    self.threads += threads ?? []
//                }
//
//                self.applySorting()
//                self.tableView.reloadData()
//            }
//        }
//    }
    
    var isFirstTime = true
    var currentUserThreads: [String] = []
    func getThreads() {
        self.threads.removeAll()
        self.tableView.reloadData()
        
        FirebaseUser.init(myUser: true).getUserThreads(completeHandler: { (threads) in
            if let keys = threads?.keys {
                self.currentUserThreads = Array(keys)
            }
            
            threads?.forEach({ (key, value) in
                
                if !self.isFirstTime, let _ = self.threads.firstIndex(where: {$0.key == key}) {
                    
                    return
                }
                
                FirebaseThread.init(threadId: key).getThreadSingle(completion: { (isSuccess, thread) in
                    if self.currentUserThreads.filter({ $0 == thread?.key ?? ""  }).count <= 0 {
                        return
                    }
                    
                    if let thread = thread  {
                        if let index = self.threads.firstIndex(where: {$0.key == thread.key ?? ""}) {
                            self.threads[index] = thread
                        } else {
                            self.threads.append(thread)
                        }
                        self.applySorting()
                        self.tableView.reloadData()
                    }
                }, observeForeEver: true)
            })
            
            if !self.isFirstTime, let threads = threads {
                self.removeThreadIfNeeded(threads: threads)
            }
            self.isFirstTime = false
        })
    }
    
    func removeThreadIfNeeded(threads: [String: [String: String]]) {
        var index = 0
        self.threads.forEach { (item) in
            if threads.filter({$0.key == item.key}).count <= 0 {
                self.threads.remove(at: index)
                self.tableView.reloadData()
            }
            
            index += 1
        }
    }
    
    func hideTabBar() {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func applySorting() {
        self.threads = self.threads.sorted(by: { $0.lastMessage?.date ?? 0 > $1.lastMessage?.date ?? 0 })
        self.threads = self.threads.filter({$0.details?.type ?? -1 == 1 || $0.lastMessage != nil})
    }
    
    func navigateToMesssagesVC(thread: ThreadModel) {
        hideTabBar()
        
        let messsageVC = MessagesViewController.instantiate(fromAppStoryboard: .Home)
        messsageVC.thread = thread
        self.navigationController?.pushViewController(messsageVC, animated: true)
    }
}
extension ChatsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToMesssagesVC(thread: self.threads[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.threads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.ChatCell.rawValue, for: indexPath) as! ChatCell
        cell.setData(thread: self.threads[indexPath.row])
        return cell
    }
    
}
