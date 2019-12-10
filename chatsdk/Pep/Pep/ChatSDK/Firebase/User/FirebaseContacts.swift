//
//  FirebaseContacts.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 12/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation

class FirebaseContacts : FirebaseUser {

    override init() {
        super.init(myUser: true)
        child = Nodes.Contacts.rawValue
    }

    func addContact(userObjectId: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        saveValue(data:  [userObjectId : ["type" : 0]] , completion: completion)
    }
    
    func getContacts(completion: @escaping (_ user: [ContactsModel]?) -> Void ) {
        getCollection(type: ContactsModel.self) { (isSuccess, contacts) in
            completion(contacts)
        }
    }


}
