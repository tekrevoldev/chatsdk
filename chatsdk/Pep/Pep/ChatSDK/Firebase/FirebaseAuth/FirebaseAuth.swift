//
//  FAuth.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 05/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuth {
    
    class func signIn(email: String, password: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if (error == nil) {
                let firuser = authResult!.user
                completion(firuser, error)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func createUser(email: String, password: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if (error == nil) {
                let firuser = authResult!.user
                completion(firuser, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
