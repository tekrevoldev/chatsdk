//
//  GeneralViewController.swift
//  Caristocrat
//
//  Created by Muhammad Muzammil on 10/16/18.
//  Copyright © 2018 Ingic. All rights reserved.
//

import UIKit

class GeneralViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    var titleText = ""
    var descTitle = ""
    var desc = ""
    
    var delegate: PopupDelgates?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblTitle.text = titleText
        self.lblDescTitle.text = descTitle
        self.lblDesc.text = desc
    }
    
    @IBAction func tappedOnClose() {
        dismiss(animated: true, completion: {
            self.delegate?.didTapOnClose()
        })
    }
}

protocol PopupDelgates {
    func didTapOnClose()
}
