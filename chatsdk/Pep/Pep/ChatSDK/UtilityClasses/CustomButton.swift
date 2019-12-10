//
//  CustomButton.swift
//  ARMInterior
//
//  Created by Muzammil on 09/03/2019.
//  Copyright © 2019 Ingic. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override var isSelected: Bool {
        didSet (newValue) {
            if newValue {
                self.backgroundColor = Constants.APP_PRIMARY_COlOR
                self.titleLabel?.textColor = UIColor.white
                self.setTitleColor(UIColor.white, for: .normal)
            } else {
                self.backgroundColor = UIColor.white
                self.titleLabel?.textColor = Constants.APP_PRIMARY_COlOR
                self.setTitleColor(Constants.APP_PRIMARY_COlOR, for: .normal)
            }
            
        }
    }

}
