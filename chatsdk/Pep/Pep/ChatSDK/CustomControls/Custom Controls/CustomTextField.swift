//
//  Testing.swift
//  Caristocrat
//
//  Created by Muhammad Muzammil on 8/6/18.
//  Copyright © 2018 Ingic. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var underLine: UIView!
    var fieldName: String = ""
    var isPasswordField = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        let customTextField = UINib(nibName: "CustomTextField", bundle: Bundle.init(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        customTextField.frame = self.bounds
        addSubview(customTextField)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setupView() {
//       textField.underlineColor = self.underlineColor
        fieldName = (self.placeholder ?? "")
        self.textField.tag = 10
        self.textField.delegate = self
        self.textField.placeholder = fieldName
        if Constants.DEBUG_MODE {
            self.textField.text = self.text
        }
        self.placeholder = ""
        self.isPasswordField = self.isSecureTextEntry
        self.textField.isSecureTextEntry = self.isSecureTextEntry
        if isPasswordField {
           self.configurePasswordField()
        }
    }
    
    func configurePasswordField() {
        if isPasswordField {
            rightIconImageView.image = UIImage(named: "hide_pass")
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnRightIcon))
            rightIconImageView.addGestureRecognizer(tap)
        }
    }
    
    @objc func tappedOnRightIcon(_ sender: UITapGestureRecognizer) {
        if self.textField.isSecureTextEntry {
            rightIconImageView.image = UIImage(named: "show_pass")
        } else {
            rightIconImageView.image = UIImage(named: "hide_pass")
        }

        self.textField.isSecureTextEntry = !self.textField.isSecureTextEntry
    }
    
    @IBInspectable var leftIcon: UIImage? {
        didSet {
            self.leftIconImageView.image = leftIcon
        }
    }
    
    @IBInspectable var rightIcon: UIImage? {
        didSet {
            self.rightIconImageView.image = rightIcon
        }
    }
    
    @IBInspectable var maxTextLength: Int = 100 {
        didSet {
        }
    }

    @IBInspectable var errorText: String?
    
    private func showError(isEmpty: Bool) {
        if isEmpty {
            self.errorLabel.text = errorText ?? Errors.EmptyField.rawValue + (fieldName.lowercased())
        } else {
            self.errorLabel.text = errorText ?? Errors.InvalidData.rawValue + (fieldName.lowercased())
        }
    }
    
    func showError(error: String) {
        self.errorLabel.text = error
    }
    
    
    private func resetError() {
        self.errorLabel.text = " "
    }
    
    func isValid() -> Bool {
        resetError()
        var isValid = false
        if ValidationsUtility.isNotEmpty(string: textField.text ?? "") {
            if self.textContentType == UITextContentType.emailAddress {
                isValid = ValidationsUtility.isValidEmail(email: textField.text ?? "")
            } else if self.textContentType == UITextContentType.telephoneNumber {
                isValid = ValidationsUtility.isValidPhone(phone: textField.text ?? "")
            } else if self.textContentType == UITextContentType.name {
                isValid = ValidationsUtility.isValidName(name: textField.text ?? "")
                if !isValid {
                    self.showError(error: (fieldName) + " " + Errors.MinimumLength.rawValue)
                    return false
                }
            } else {
                isValid = true
            }
        }
        
        if !isValid {
            showError(isEmpty: !ValidationsUtility.isNotEmpty(string: textField.text ?? ""))
        }
        
        return isValid
    }
}

extension CustomTextField : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textField.tag == 10
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= maxTextLength
    }
}
