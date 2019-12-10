//
//  SignupViewController.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 05/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var fieldName: UITextField!
    @IBOutlet var fieldEmail: UITextField!
    @IBOutlet var fieldPassword: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.cancelsTouchesInView = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    // MARK: - User actions
    @IBAction func actionRegister(_ sender: Any) {
        
        let name = (fieldName.text ?? "").lowercased()
        let email = (fieldEmail.text ?? "").lowercased()
        let password = fieldPassword.text ?? ""
        
        if !isValidData(name: name, email: email, password: password) {
            return
        }
        
        doSignUp(name: name, email: email, password: password)
    }
    
    func doSignUp(name: String, email: String, password: String) {
        Utility.startProgressLoading()
        
        FirebaseAuth.createUser(email: email, password: password) { user, error in
            Utility.stopProgressLoading()
            if (error == nil) {
                self.saveUserData(name: name, userId: user?.uid ?? "", email: user?.email ?? "")
                AppStateManager.sharedInstance.userId = user?.uid ?? ""
                Global.APP_DELEGATE.setupUX()
            } else {
                Utility.showErrorWith(message: error!.localizedDescription)
            }
        }

    }
    
    func saveUserData(name: String, userId: String, email: String) {
        FirebaseUser.init(userId: userId).saveUser(name: name, email: email, imageURL: "") { (isSuccess) in
            if isSuccess {
                print("Sign Up SuccessFull")
            } else {
                print("Error on Sign Up")
            }
            
        }
    }
    
    func isValidData(name: String, email: String, password: String) -> Bool {
        if name.count == 0 {
            Utility.showErrorWith(message: Errors.EnterName.rawValue)
            return false
        }
        else if (email.count == 0) {
            Utility.showErrorWith(message: Errors.EnterEmail.rawValue)
            return false
        } else if (password.count == 0)    {
            Utility.showErrorWith(message: Errors.EnterPassword.rawValue)
            return false
        }
        
        return true
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == fieldEmail) {
            fieldPassword.becomeFirstResponder()
        }
        
        if (textField == fieldPassword) {
            actionRegister(0)
        }
        return true
    }
    
    @IBAction func tappedOnSignIn() {
        self.navigationController?.popViewController(animated: true)
    }
}
