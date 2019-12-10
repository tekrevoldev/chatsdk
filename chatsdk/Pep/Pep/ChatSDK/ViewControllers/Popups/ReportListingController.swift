//
//  ReportListingController.swift
//  Caristocrat
//
//  Created by Muhammad Muzammil on 10/25/18.
//  Copyright © 2018 Ingic. All rights reserved.
//

import UIKit

class ReportListingController: UIViewController {
    
    @IBOutlet weak var reasonField: UITextField!
    @IBOutlet weak var spamButton: UIButton!
    @IBOutlet weak var fakeButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    var reason = ""
    var carId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tappedOnSpam(_ sender: UIButton) {
        spamButton.isSelected = !sender.isSelected
        fakeButton.isSelected = false
        otherButton.isSelected = false

        reasonField.isHidden = true
    }
    
    @IBAction func tappedOnFake(_ sender: UIButton) {
        spamButton.isSelected = false
        fakeButton.isSelected = !sender.isSelected
        otherButton.isSelected = false

        reasonField.isHidden = true
    }
    
    @IBAction func tappedOnOther(_ sender: UIButton) {
        spamButton.isSelected = false
        fakeButton.isSelected = false
        otherButton.isSelected = !sender.isSelected

        reasonField.isHidden = false
    }
    
    @IBAction func tappedOnSubmit(_ sender: UIButton) {
        self.submitReport()
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func submitReport() {
        if otherButton.isSelected {
            if reasonField.text?.isEmpty ?? true {
                Utility.showErrorWith(message: Errors.EnterReason.rawValue)
                return
            }
            reason = reasonField.text ?? ""
        } else if fakeButton.isSelected {
            reason = "Fake Details"
        } else if spamButton.isSelected {
            reason = "Spam or misleading"
        } else {
            Utility.showErrorWith(message: Errors.EnterReason.rawValue)
            return
        }
        
        
       
    }
    
}
