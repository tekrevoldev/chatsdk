//
//  TableViewCell.swift
//  SideMenuTemplate
//
//  Created by JamilKhan on 05/01/2018.
//  Copyright © 2018 Ingic. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell
{
    static func dequeueReusableCell(tableView: UITableView, ofType: Any) -> UITableViewCell
    {
        tableView.register(UINib(nibName: String(describing: ofType), bundle: nil), forCellReuseIdentifier: String(describing: ofType))
        return tableView.dequeueReusableCell(withIdentifier: String(describing: ofType))!
        
    }
}
