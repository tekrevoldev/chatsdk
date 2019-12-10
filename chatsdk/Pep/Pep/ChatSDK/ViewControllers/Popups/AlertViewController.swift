//
//  AlertViewController.swift
//  Caristocrat
//
//  Created by syed Hassan Shah  on 1/4/19.
//  Copyright © 2019 Ingic. All rights reserved.
//

import Foundation
import UIKit

protocol AlertViewDelegates {
    func didTapOnRightButton()
    func didTapOnLeftButton()
}

class AlertViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblLeftButton: UIButton!
    @IBOutlet weak var lblRightButton: UIButton!
    var delegate: AlertViewDelegates?
    var tapClouser: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func showAlert(title: String,description: String,rightButtonText: String = "Yes", leftButtonText: String = "No", delegate: AlertViewDelegates) {
        let alertViewController = AlertViewController.instantiate(fromAppStoryboard: .Popups)
        alertViewController.delegate = delegate
        alertViewController.modalPresentationStyle = .overCurrentContext
        alertViewController.modalTransitionStyle = .crossDissolve
        Utility().topViewController()?.present(alertViewController, animated: false, completion: {
        })
        alertViewController.lblTitle.text = title
        alertViewController.lblDescription.text = description
        alertViewController.lblLeftButton.setTitle(leftButtonText, for: .normal)
        alertViewController.lblRightButton.setTitle(rightButtonText, for: .normal)

    }
    
    static func showAlert(title: String,description: String,rightButtonText: String = "Yes", leftButtonText: String = "No",  positiveTapClouser: @escaping () -> Void) {
        let alertViewController = AlertViewController.instantiate(fromAppStoryboard: .Popups)
        alertViewController.tapClouser = positiveTapClouser
        alertViewController.modalPresentationStyle = .overCurrentContext
        alertViewController.modalTransitionStyle = .crossDissolve
        Utility().topViewController()?.present(alertViewController, animated: false, completion: {
        })
        alertViewController.lblTitle.text = title
        alertViewController.lblDescription.text = description
        alertViewController.lblLeftButton.setTitle(leftButtonText, for: .normal)
        alertViewController.lblRightButton.setTitle(rightButtonText, for: .normal)
        
    }
    
    @IBAction func tappedOnRightButton() {
        self.dismiss(animated: false, completion: {
            if self.tapClouser != nil {
                self.tapClouser!()
            }
            self.delegate?.didTapOnRightButton()
        })
    }
    
    @IBAction func tappedOnLeftButton() {
        self.dismiss(animated: false, completion: {
            self.delegate?.didTapOnLeftButton()
        })
    }
    
    @IBAction func tappedOnClose() {
        dismiss(animated: false, completion: nil)
    }

}
