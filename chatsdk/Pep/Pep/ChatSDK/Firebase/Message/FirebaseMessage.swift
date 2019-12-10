//
//  FirebaseMessage.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 11/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation

class FirebaseMessage : FirebaseThread {
    
    override init() {
        super.init()
        subPath = Nodes.Messages.rawValue
    }
    
    override init(threadId: String) {
        super.init(threadId: threadId)
        child = Nodes.Messages.rawValue
    }
    
    func send(textMessge: String, completion: @escaping (Bool) -> Void ) {
        let msg = MessageModel(date: Utility.getCurrentMilli(), text: textMessge, senderId: AppStateManager.sharedInstance.userId)
        do {
            _ = saveValue(data: try msg.asDictionary(), completion: completion, autoId: true)
            child = Nodes.LastMessage.rawValue
            _ = saveValue(data: try msg.asDictionary(), completion: completion)
        } catch {
            print("FirebaseMessage | send(textMessge:) => Error occure on parsing")
        }
    }
    
    func getMessages(completion: @escaping (Bool, [MessageModel]?) -> ()) {
        child = Nodes.Messages.rawValue
        
        getCollection(type: MessageModel.self, eventType: .childAdded, sortBy: NodeProperties.Date, completion: completion)
    }
    
    
    
}
