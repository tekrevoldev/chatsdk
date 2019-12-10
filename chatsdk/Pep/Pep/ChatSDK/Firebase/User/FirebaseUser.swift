//
//  FirebaseUtility.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 05/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseUser : FirebaseCore {
    
    init() {
       super.init(path: .Users)
    }
    
    init (userId: String) {
        super.init(path: .Users, subPath: userId)
    }
    
    init (myUser: Bool) {
        super.init(path: .Users, subPath: AppStateManager.sharedInstance.userId)
    }
    
    func getUserThreads(completeHandler: @escaping (_ threads: [String: [String: String]]?) -> Void, observeForeEver: Bool = true) {
            child = Nodes.Threads.rawValue
            fetch(type: [String: [String: String]].self, eventsType: [.value], completion: { (isSuccess, result) in
                completeHandler(result)
            }, observeForeEver: observeForeEver)
    }
    
    func getUserById(completeHandler: @escaping (_ user: UserModel?) -> Void, observeUpdates: Bool = false ) {
        if observeUpdates {
            fetch(type: UserModel.self, eventsType: [.value], completion: { (isSuccess, result) in
                completeHandler(result)
            }, observeForeEver: true)
        } else {
            getSingleData(type: UserModel.self) { (success, result) in
                completeHandler(result)
            }
        }
        
    }
    
    func saveUser(name: String, email: String, imageURL: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        let userObj = ["email" : email,
                       "name"  : name,
                       "name-lowercase" : name.lowercased(),
                       "pictureURL" : imageURL]
        
        saveValue(data: ["meta": userObj], completion: completion)
    }
    
    class func threadLinking(threadId: String,usersId: [String]) {
        usersId.forEach { (item) in
            let fireabaseUser = FirebaseUser.init(userId: item)
            fireabaseUser.child = Nodes.Threads.rawValue
            fireabaseUser.saveValue(data: [threadId : ["invitedBy" : AppStateManager.sharedInstance.userId]] , completion: { (isSuccess) in
                print("threadLinking => Success")
            })
        }
    }
    
    class func threadUnLinking(threadId: String,usersId: String) {
        let fireabaseUser = FirebaseUser.init(userId: usersId)
        fireabaseUser.child = Nodes.Threads.rawValue
        fireabaseUser.subChild = threadId
        fireabaseUser.getRef().removeValue()
     }
    
    func getUsers(completion: @escaping (_ user: [UserModel]?) -> Void ) {
        getCollection(type: UserModel.self) { (isSuccess, users) in
            completion(users)
        }
    }
    
    func searchUsers(keyword: String, completion: @escaping (_ user: [UserModel]?) -> Void ) {
        searchData(keyword: keyword.lowercased(), node: Nodes.SearchUser , type: UserModel.self) { (isSuccess, users) in
            completion(users)
        }
    }
}
