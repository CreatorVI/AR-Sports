//
//  ShopButton.swift
//  
//
//  Created by Yu Wang on 1/27/19.
//

import UIKit

class ShopButton: RootWidgetButton {
    func setConstraints(){
        self.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.topAnchor.constraint(equalTo: (superview?.topAnchor)!, constant: 12).isActive = true
        self.rightAnchor.constraint(equalTo: (superview?.rightAnchor)!, constant: -12).isActive = true
    }
}
