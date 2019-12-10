//
//  FirebaseMessage.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 11/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseThread : FirebaseCore {
    
    init() {
        super.init(path: Nodes.Threads)
    }
    
    init (threadId: String) {
        super.init(path: .Threads, subPath: threadId)
    }
    
    func getThreads(completion: @escaping (Bool, [ThreadModel]?) -> ()) {
        fetchByQueryOrderd(childPath: AppStateManager.sharedInstance.userId, type: ThreadModel.self, eventsType: [.value
             ,.childChanged, .childAdded] , completion: completion)
    }
    
    func getThreadsSingle(completion: @escaping (Bool, [ThreadModel]?) -> ()) {
        fetchByQueryOrderd(childPath: AppStateManager.sharedInstance.userId, type: ThreadModel.self, eventsType: [.value] , completion: completion)
    }
    
    func getThread(completion: @escaping (Bool, ThreadModel?) -> ()) {
        fetch(type: ThreadModel.self, eventsType: [.value, .childChanged, .childAdded] , completion: completion)
    }
    
    func getThreadSingle(completion: @escaping (Bool, ThreadModel?) -> (), observeForeEver: Bool = false) {
        fetch(type: ThreadModel.self, eventsType: [.value] , completion: completion, observeForeEver: observeForeEver)
    }

    func createThread(userId: String, name: String, completion: @escaping (Bool) -> Void) {
        
       var threadDetail = ThreadDetailModel()
       threadDetail.creatorEntityId = AppStateManager.sharedInstance.userId
       threadDetail.type = 0
       threadDetail.type_v4 = 2
        // TODO: Need to add proper date => threadDetail.creationDate
       let thread = ThreadModel()
       thread.details = threadDetail
       thread.users  = [userId: ["status": ThreadUserRole.Member.rawValue], AppStateManager.sharedInstance.userId: ["status": ThreadUserRole.Member.rawValue]]
       let threadId  = saveValue(data: try! thread.asDictionary(), completion: completion, autoId: true)
        
        
       let users = thread.users?.map({$0.key}) ?? [""]
       FirebaseUser.threadLinking(threadId: threadId, usersId: users)
    }
    
    func createGroupThread(Id: String,userIds: [String], name: String, completion: @escaping (Bool) -> Void) {
        
        var threadDetail = ThreadDetailModel()
        threadDetail.creatorEntityId = AppStateManager.sharedInstance.userId
        threadDetail.name = name
        threadDetail.type = 1
        threadDetail.type_v4 = 4
        // TODO: Need to add proper date => threadDetail.creationDate
        let thread = ThreadModel()
        thread.details = threadDetail
        thread.meta?.name = name
        
        var users: [String: [String: String]] = [AppStateManager.sharedInstance.userId : ["status": ThreadUserRole.Admin.rawValue]]
        userIds.forEach { (item) in
            users[item] = ["status": ThreadUserRole.Member.rawValue]
        }

        thread.users = users
        
        var threadId = Id
        if threadId.isEmpty {
            threadId = saveValue(data: try! thread.asDictionary(), completion: completion, autoId: true)
        } else {
            subPath = threadId
            saveValue(data: try! thread.asDictionary(), completion: completion, autoId: false)
        }

        FirebaseUser.threadLinking(threadId: threadId, usersId: thread.users?.map({$0.key}) ?? [""])

    }
    
    func removeParticipantFromGroup(threadId: String, participantId: String) {
        child = Nodes.Users.rawValue
        subChild = participantId
        
        getRef().removeValue()
        FirebaseUser.threadUnLinking(threadId: threadId, usersId: participantId)
    }
    
    func makeAdmin(userId: String) {
        child = Nodes.Users.rawValue
        subChild = userId
        getRef().updateChildValues(["status": ThreadUserRole.Admin.rawValue])
    }
    
    static func getThreadParticipants(threadId: String, completions: @escaping (UserModel) -> Void) {
        
        FirebaseThread.init(threadId: threadId).getThreadSingle(completion: { (isSuccess, thread) in
            if let thread = thread {
                thread.users?.forEach({ (key, value) in
                    FirebaseUser.init(userId: key).getUserById(completeHandler: { (user) in
                        if let user = user {
                            completions(user)
                        }
                    })
                })
            }
        })
    }
    
    static func getThreadName(thread: ThreadModel, completions: @escaping (String) -> Void) {
        completions(thread.details?.name ?? "")

        if thread.isGroup() {
            return
        }
        
        thread.users?.forEach({ (key, value) in
            if !key.isMe() {
                FirebaseUser.init(userId: key).getUserById(completeHandler: { (user) in
                    completions(user?.meta?.name ?? "")
                })
                return
            }
        })
    }
}
