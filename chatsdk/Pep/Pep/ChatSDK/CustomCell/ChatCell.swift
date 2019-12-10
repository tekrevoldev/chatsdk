//
//  ChatCell.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 12/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setData(thread: ThreadModel) {
        self.nameLabel.text = thread.details?.name ?? ""
        self.lastMessageLabel.text = thread.lastMessage?.getMessageBody()?.text ?? ""
        if let date = thread.lastMessage?.date {
            self.timeLabel.text = Utility.milliToDate(milliDate: thread.lastMessage?.date ?? 0, format: .Brief)
        }
                
        FirebaseThread.getThreadName(thread: thread) { (name) in
            self.nameLabel.text = name
        }
    }
    
    
}
