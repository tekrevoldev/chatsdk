//
//  SelectionController.swift
//  Caristocrat
//
//  Created by Muhammad Muzammil on 10/16/18.
//  Copyright © 2018 Ingic. All rights reserved.
//

import Foundation
import UIKit

class SelectionController: UIViewController {
    
    @IBOutlet weak var popUpHeight: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var delegate: ItemSelectionDelegate?
    var items: [String] = []
    var titleText: String?
    var tapClouser: ((_ position: Int, _ tag: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customizeAppearance()
    }

    func customizeAppearance() {
        self.prepareTableview()
        lblTitle.text = titleText
        
        if items.count < 5{
            self.popUpHeight.constant = 34.0 + (CGFloat(items.count) * 44.0)
        }
        else{
            self.popUpHeight.constant = 34.0 + (8.0 * 44.0)
        }
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func prepareTableview() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
}

extension SelectionController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectionCell.identifier)
        
        if let selectionCell = cell as? SelectionCell {
            selectionCell.setData(text: items[indexPath.row])
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss()
        tapClouser?(indexPath.row, titleText ?? "")
        delegate?.didItemSelect(position: indexPath.row, tag: titleText ?? "")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

protocol ItemSelectionDelegate {
    func didItemSelect(position: Int, tag: String)
}

class SelectionCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    func setData(text: String) {
        lblTitle.text = text
    }
    
}
