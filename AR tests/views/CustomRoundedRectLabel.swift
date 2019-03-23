//
//  CustomRoundedRectLabel.swift
//  AR tests
//
//  Created by Yu Wang on 1/20/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

class CustomRoundedRectLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        
    }
    
    func setUp(){
        sizeToFit()
        numberOfLines = 0
        textColor = UIColor.black
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        layer.masksToBounds = true
        contentMode = .scaleToFill
        textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
