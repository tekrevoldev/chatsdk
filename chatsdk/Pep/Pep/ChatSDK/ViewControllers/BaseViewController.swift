
import UIKit
import SwiftMessages

protocol ACBaseViewControllerSearchDelegate {
    
    func searchWith(term: String)
    
    func cancelSearch()
}


class BaseViewController: UIViewController {
    
    
    var isColorBar = false
    
    var searchButton: UIBarButtonItem!
    
    var searchDelegate: ACBaseViewControllerSearchDelegate?
    
    var searchBar = UISearchBar()
    
    var leftSearchBarButtonItem : UIBarButtonItem?
    
    var rightSearchBarButtonItem : UIBarButtonItem?
    
    var cancelSearchBarButtonItem: UIBarButtonItem?
    
    var logoImageView : UIImageView!
    
    var transparentNavBar = false
    var hideNavBar = false
    var navTitle: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = hideNavBar
        navigationItem.setHidesBackButton(true, animated: false)
        
        if transparentNavBar {
            setupTransparentNavBar()
        }
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            addBackButtonToNavigationBar()
        }
        
        setNavTitle(title: navTitle)
        setNavTitleFont()
    }
    
    func setNavTitleFont() {
        if let font = UIFont(name: FontsType.Bold.rawValue, size: 16){
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
    }
    
    func setNavTitle(title: String) {
        if (!title.isEmpty) {
            self.title = title
        }
    }
    
    func setupColorNavBar(){
        if let font = UIFont(name: "Raleway-Medium", size: 18){
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:UIColor.white]
            self.navigationController?.navigationBar.barStyle = .black
        }
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        self.navigationController?.navigationBar.barTintColor =  UIColor(red: 199.0/255.0, green: 16.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //    UIColor(red: 189.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    
    
    func setupTransparentNavBar(){
        if let font = UIFont(name: "Raleway-Medium", size: 18){
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:UIColor.black]
            self.navigationController?.navigationBar.barStyle = .default
        }
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //        self.navigationController?.navigationBar.barTintColor = UIColor.red //UIColor(red: 189.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        //    UIColor(red: 189.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = hideNavBar
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = hideNavBar
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addBackButtonToNavigationBar(){
        self.leftSearchBarButtonItem =  UIBarButtonItem(image: UIImage.init(named: "backarrow"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
        
        self.navigationItem.leftBarButtonItem = self.leftSearchBarButtonItem;
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
    }
    
    @objc func goBack(){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    @available(*, deprecated, message: "Use stopSkeletonAnimation() instead.")
    func stopLoading(){
    }

    
    func showErrorWith(message: String){
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        let error = MessageView.viewFromNib(layout: .tabView)
        error.configureTheme(.error)
        error.configureContent(title: "", body: message)
        //error.button?.setTitle("Stop", for: .normal)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
    }

}
