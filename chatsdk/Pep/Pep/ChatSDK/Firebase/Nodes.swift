//
//  Nodes.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 05/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation

enum Nodes: String {
    case Base = "19_88"
    case Users = "users"
    case Threads = "threads"
    case Contacts = "contacts"
    case SearchUser = "meta/name-lowercase"
    case Messages = "messages"
    case LastMessage = "lastMessage"
}

enum NodeProperties: String {
    case Date = "date"
    case AudioURL = "audio-url"
}

enum MessageTypes: Int {
    case Text = 0 
    case Audio = 3
}
