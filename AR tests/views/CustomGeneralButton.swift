//
//  CustomGeneralButton.swift
//  AR tests
//
//  Created by Yu Wang on 1/21/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit

class BluredShadowView:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = UIColor.green
        addShadow(color: UIColor.black)
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = 16
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
        gestureRecognizers?.forEach({ (recog) in
            blurView.addGestureRecognizer(recog)
        })
        self.backgroundColor = UIColor.clear
//        blurView.isUserInteractionEnabled = false
    }
    
    convenience init(image:UIImage? = nil,title:String){
        self.init()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = title
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UIView {
    
    func addShadow(color: UIColor) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0.8, height: 1.5)
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.5
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor = backgroundCGColor
    }
}
