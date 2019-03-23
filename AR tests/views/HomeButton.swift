//
//  HomeButton.swift
//  AR tests
//
//  Created by Yu Wang on 1/27/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

class HomeButton: RootWidgetButton {

    func setConstraints(){
        self.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.topAnchor.constraint(equalTo: (superview?.topAnchor)!, constant: 12).isActive = true
        self.leftAnchor.constraint(equalTo: (superview?.leftAnchor)!, constant: 12).isActive = true
    }

}
