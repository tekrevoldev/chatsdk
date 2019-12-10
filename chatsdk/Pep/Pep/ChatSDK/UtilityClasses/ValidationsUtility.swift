//
//  ValidationsUtility.swift
//  Caristocrat
//
//  Created by Muhammad Muzammil on 8/6/18.
//  Copyright © 2018 Ingic. All rights reserved.
//

import Foundation
import UIKit

class ValidationsUtility {
    
    static func isNotEmpty(string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return !trimmed.isEmpty
    }
    
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    
    static func isValidPhone(phone: String) -> Bool {
        return phone.count >= 7 && phone.count <= 12
    }
    
    static func isValidName(name: String) -> Bool {
        return name.count >= 3
    }
    
//    static func isFieldsDataValid(fields: [CustomTextField]) -> Bool {
//        for field in fields.enumerated() {
//            if !field.element.isValid() {
//                return false
//            }
//        }
//        return true
//    }
    
    static func isFormDataValid(parent: UIView) -> (isValid: Bool,params: Parameters) {
        var parameter: Parameters = [:]
        if let fieldsView = parent.viewWithTag(Constants.FIELDS_TAG) {
            for v in fieldsView.subviews {
                if let customfield  = v as? CustomTextField {
                    if customfield.isValid() {
                        if !customfield.paramName.isEmpty {
                            parameter.updateValue(customfield.textField.text ?? "", forKey: customfield.paramName)
                        }
                        
                    } else {
                        return (false, parameter)
                    }
                } else if let field = v as? UITextField {
                    if !field.paramName.isEmpty {
                        parameter.updateValue(field.text ?? "", forKey: field.paramName)
                    }
                }
            }
        }
        return (true, parameter)
    }

}
