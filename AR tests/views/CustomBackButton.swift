//
//  CustomBackButton.swift
//  AR tests
//
//  Created by Yu Wang on 1/21/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

class CustomBackButton: RootWidgetButton {

    func setConstraints(){
        self.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.topAnchor.constraint(equalTo: (superview?.topAnchor)!, constant: 24).isActive = true
        self.leftAnchor.constraint(equalTo: (superview?.leftAnchor)!, constant: -76).isActive = true
    }
    
}
