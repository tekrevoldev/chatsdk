//
//  Contacts.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 11/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation

class ContactsModel : FirebaseBaseModel, Codable {
    
    let type : Int?
    
    enum CodingKeys: String, CodingKey {
        case type = "last-type"
       
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decodeIfPresent(Int.self, forKey: .type)
        super.init()
    }
}
