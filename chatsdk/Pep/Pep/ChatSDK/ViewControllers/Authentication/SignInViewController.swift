import Foundation
import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var fieldEmail: UITextField!
    @IBOutlet var fieldPassword: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setGestures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.cancelsTouchesInView = false
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        
        let email = (fieldEmail.text ?? "").lowercased()
        let password = fieldPassword.text ?? ""
        
        if !isValidData(email: email, password: password) {
            return
        }
        
        self.doSignIn(email: email, password: password)
    }
    
    func doSignIn(email: String, password: String) {
        Utility.startProgressLoading()
        
        FirebaseAuth.signIn(email: email, password: password) { (userData, error) in
            Utility.stopProgressLoading()
            if error == nil {
                AppStateManager.sharedInstance.userId = userData?.uid ?? ""
                Global.APP_DELEGATE.setupUX()
            } else {
                Utility.showErrorWith(message: error!.localizedDescription)
            }
        }
    }
    
    func isValidData(email: String, password: String) -> Bool {
        if (email.count == 0) {
            Utility.showErrorWith(message: Errors.EnterEmail.rawValue)
            return false
        } else if (password.count == 0)    {
            Utility.showErrorWith(message: Errors.EnterPassword.rawValue)
            return false
        }
        
        return true
    }
    
    @IBAction func actionDismiss(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func tappedOnSignup(_ sender: Any) {
      let signUpVC = SignupViewController.instantiate(fromAppStoryboard: .Authetication)
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == fieldEmail) {
            fieldPassword.becomeFirstResponder()
        }
        if (textField == fieldPassword) {
            actionLogin(0)
        }
        return true
    }
}
