//
//  RootWidgetButton.swift
//  AR tests
//
//  Created by Yu Wang on 1/27/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

class RootWidgetButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        imageView?.contentMode = .scaleToFill
        clipsToBounds = true
    }
    
    convenience init(image:UIImage) {
        self.init()
        self.setImage(image, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
