//
//  SmartScrollView.swift
//  AR tests
//
//  Created by Yu Wang on 3/9/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

class SmartScrollView: UIScrollView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl
            && !(view is UITextInput)
            && !(view is UISlider)
            && !(view is UISwitch) {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
    
}
