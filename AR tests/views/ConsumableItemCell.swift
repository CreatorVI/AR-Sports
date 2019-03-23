//
//  ConsumableItemCell.swift
//  AR tests
//
//  Created by Yu Wang on 3/6/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import UIKit

class ConsumableItemCell: UICollectionViewCell {
    
    var cornerR:CGFloat = 30
    
    var addItem = BluredShadowView(image: #imageLiteral(resourceName: "25304"))
    
    var imageView = BluredShadowView(image: #imageLiteral(resourceName: "manyLoves"), corner: 30, imageMultplier: 0.8)
    
    lazy var slowCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = getFont(withSize: 20)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = frame.width - 12
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60)
            ]
        )
        
        
        addSubview(slowCountLabel)
        NSLayoutConstraint.activate([
            slowCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            slowCountLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            ]
        )
        
        
        addSubview(addItem)
        addItem.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addItem.widthAnchor.constraint(equalToConstant: 30).isActive = true
        addItem.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addItem.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
//        addItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddItem)))
    }

//    
//    @objc func handleAddItem(){
//        
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
