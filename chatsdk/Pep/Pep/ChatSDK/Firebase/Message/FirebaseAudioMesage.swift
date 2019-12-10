//
//  FirebaseAudioMesage.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 19/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
class FirebaseAudioMesage : FirebaseMessage {
    
     init(threadId: String, messageId: String? = nil) {
       super.init(threadId: threadId)
       super.subChild = messageId
    }
    
    func sendMessage(audioPath: String, messageId: String) {
        let msg = MessageModel(date: Utility.getCurrentMilli(), audioURL:  audioPath, senderId: AppStateManager.sharedInstance.userId)
        do {
            _ = saveValue(data: try msg.asDictionary(), completion: { (isSucces) in
                
            }, autoId: false)
            child = Nodes.LastMessage.rawValue
            _ = saveValue(data: try msg.asDictionary(), completion: { (isSucces) in
                
            }, autoId: false)
        } catch {
            print("FirebaseMessage | send(textMessge:) => Error occure on parsing")
        }
    }
}
