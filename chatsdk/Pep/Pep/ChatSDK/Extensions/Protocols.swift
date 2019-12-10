//
//  Protocols.swift
//  Caristocrat
//
//  Created by Muhammad Muzammil on 1/6/19.
//  Copyright © 2019 Ingic. All rights reserved.
//

import Foundation

protocol EventPerformDelegate {
    func didActionPerformed(eventName: EventName,data: Any)
}
