//
//  BluredShadowView.swift
//  AR tests
//
//  Created by Yu Wang on 1/21/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import StoreKit

class BluredShadowView:UIView{
    
    var label:UILabel?
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    
    var cornerR:CGFloat = 16
    
    var imageViewForButton:UIImageView?
    
    var whiteMask:UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = cornerR
        layer.masksToBounds = true
        backgroundColor = UIColor.green
        addShadow(color: UIColor.black)
        
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = cornerR
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
        self.backgroundColor = UIColor.clear
        blurView.isUserInteractionEnabled = false
    }
    
    @objc func cancel(){
        self.removeFromSuperview()
    }
    
    var action:(() -> Void)?
    
    @objc func alertAction(){
        if let action = self.action{
            action()
        }
        cancel()
    }
    
    var textSize: CGRect?
    
    convenience init(title: String, message: String, buttonTitle: String = NSLocalizedString("OK", comment: ""), showCancel: Bool = false, buttonHandler: (() -> Void)? = nil){
        self.init()
        
        self.action = buttonHandler
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "\(title)\n\n\(message)"
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        label.font = getFont(withSize: 18)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 336
        label.textAlignment = .center
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            ]
        )
        self.label = label
        
        self.textSize = estimateTrameForText(text:"\(title)\n\n\(message)",fontSize:18)
        
        let line = UIView()
        line.backgroundColor = UIColor.black
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        NSLayoutConstraint.activate([
            line.leftAnchor.constraint(equalTo: leftAnchor),
            line.rightAnchor.constraint(equalTo: rightAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.topAnchor.constraint(equalTo: topAnchor, constant: textSize!.height+24)
            ]
        )
        
        let okButton = UIButton(type: .system)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.backgroundColor = UIColor.clear
        okButton.setTitle(buttonTitle, for: .normal)
        okButton.titleLabel?.font = getFont(withSize: 22)
        okButton.setTitleColor(UIColor.blue, for: .normal)
        okButton.addTarget(self, action: #selector(alertAction), for: .touchUpInside)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.titleLabel?.font = getFont(withSize: 22)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        if showCancel{
            let verticleLine = UIView()
            verticleLine.backgroundColor = UIColor.black
            verticleLine.translatesAutoresizingMaskIntoConstraints = false
            addSubview(verticleLine)
            NSLayoutConstraint.activate([
                verticleLine.centerXAnchor.constraint(equalTo: centerXAnchor),
                verticleLine.widthAnchor.constraint(equalToConstant: 1),
                verticleLine.bottomAnchor.constraint(equalTo: bottomAnchor),
                verticleLine.topAnchor.constraint(equalTo: line.bottomAnchor)
                ]
            )
            
            addSubview(okButton)
            NSLayoutConstraint.activate([
                okButton.leftAnchor.constraint(equalTo: verticleLine.rightAnchor),
                okButton.rightAnchor.constraint(equalTo: rightAnchor),
                okButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                okButton.topAnchor.constraint(equalTo: line.bottomAnchor)
                ]
            )
            
            addSubview(cancelButton)
            NSLayoutConstraint.activate([
                cancelButton.leftAnchor.constraint(equalTo: leftAnchor),
                cancelButton.rightAnchor.constraint(equalTo: verticleLine.leftAnchor),
                cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                cancelButton.topAnchor.constraint(equalTo: line.bottomAnchor)
                ]
            )
            
        }else{
            addSubview(okButton)
            NSLayoutConstraint.activate([
                okButton.leftAnchor.constraint(equalTo: leftAnchor),
                okButton.rightAnchor.constraint(equalTo: rightAnchor),
                okButton.bottomAnchor.constraint(equalTo: bottomAnchor),
                okButton.topAnchor.constraint(equalTo: line.bottomAnchor)
                ]
            )
        }
        
    }
    
    //used for buy views
    var sectionOneRect:CGRect?
    var sectionOneAction:(() -> Void)?
    @objc func buyWithGems(){
        sectionOneAction!()
        cancel()
    }
    
    var sectionTwoRect: CGRect?
    var sectionTwoAction:(() -> Void)?
    @objc func buyWithVideos(){
        sectionTwoAction!()
        cancel()
    }
    
    convenience init(paymentOptions:[PaymentOptions : Int], buyWithGemsAction sectionOneAction:@escaping () -> Void, watchedVideos:Int = 0, buyWithVideosAction sectionTwoAction:(() -> Void)? = nil) {
        self.init()
        self.sectionOneAction = sectionOneAction
        let sectionOneText = "Buy With Gems\n\nYou can get it with \(paymentOptions[PaymentOptions.gems]!) gems"
        sectionOneRect = estimateTrameForText(text: sectionOneText, fontSize:30)
        let sectionOne = UIView()
        sectionOne.translatesAutoresizingMaskIntoConstraints = false
        sectionOne.backgroundColor = UIColor.clear
        addSubview(sectionOne)
        NSLayoutConstraint.activate([
            sectionOne.leftAnchor.constraint(equalTo: leftAnchor),
            sectionOne.rightAnchor.constraint(equalTo: rightAnchor),
            sectionOne.topAnchor.constraint(equalTo: topAnchor),
            sectionOne.heightAnchor.constraint(equalToConstant: sectionOneRect!.height + 96)
            ]
        )
        sectionOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyWithGems)))
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = sectionOneText
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        label.font = getFont(withSize: 30)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 336
        label.textAlignment = .center
        label.textColor = UIColor.purple
        sectionOne.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            ]
        )
        if paymentOptions.count == 1{
            sectionTwoRect = nil
        }else{
            let line = UIView()
            line.backgroundColor = UIColor.black
            line.translatesAutoresizingMaskIntoConstraints = false
            addSubview(line)
            NSLayoutConstraint.activate([
                line.leftAnchor.constraint(equalTo: leftAnchor),
                line.rightAnchor.constraint(equalTo: rightAnchor),
                line.heightAnchor.constraint(equalToConstant: 1),
                line.topAnchor.constraint(equalTo: sectionOne.bottomAnchor)
                ]
            )
            
            self.sectionTwoAction = sectionTwoAction
            let sectionTwoText = "Buy With Video Watches\n\nYou also can get it buy watching videos for free\n    \(watchedVideos)/\(paymentOptions[PaymentOptions.watchingVideos]!)"
            sectionTwoRect = estimateTrameForText(text: sectionTwoText, fontSize:30)
            let sectionTwo = UIView()
            sectionTwo.translatesAutoresizingMaskIntoConstraints = false
            sectionTwo.backgroundColor = UIColor.clear
            addSubview(sectionTwo)
            NSLayoutConstraint.activate([
                sectionTwo.leftAnchor.constraint(equalTo: leftAnchor),
                sectionTwo.rightAnchor.constraint(equalTo: rightAnchor),
                sectionTwo.topAnchor.constraint(equalTo: line.bottomAnchor),
                sectionTwo.heightAnchor.constraint(equalToConstant: sectionTwoRect!.height + 96)
                ]
            )
            sectionTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyWithVideos)))
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.text = sectionTwoText
            label.sizeToFit()
            label.isUserInteractionEnabled = false
            label.font = getFont(withSize: 30)
            label.adjustsFontForContentSizeCategory = true
            label.preferredMaxLayoutWidth = 336
            label.textAlignment = .center
            label.textColor = UIColor.orange
            sectionTwo.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.topAnchor.constraint(equalTo: topAnchor, constant: sectionOneRect!.height+144),
                ]
            )
        }
    }
    
    
    
    private func estimateTrameForText(text:String,fontSize:Int = 30,width:CGFloat = 336) -> CGRect{
        let size = CGSize(width: width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:getFont(withSize: fontSize)], context: nil)
    }
    
    func setUpConstrantsIfIsUsedAsAlertView(){
        widthAnchor.constraint(equalToConstant: 360).isActive = true
        if let textSize = textSize{
            heightAnchor.constraint(equalToConstant: textSize.height+84).isActive = true
        }else if let sectionTwoRect = sectionTwoRect{
            heightAnchor.constraint(equalToConstant: sectionTwoRect.height+sectionOneRect!.height + 193).isActive = true
        }else if let sectionOneRect = sectionOneRect{
            heightAnchor.constraint(equalToConstant: sectionOneRect.height+96).isActive = true
        }else if let productPageHeight = productPageHeight{
            heightAnchor.constraint(equalToConstant: productPageHeight+120).isActive = true
        }else{
            heightAnchor.constraint(equalToConstant: 180).isActive = true
        }
        centerXAnchor.constraint(equalTo: (superview?.centerXAnchor)!).isActive = true
        centerYAnchor.constraint(equalTo: (superview?.centerYAnchor)!).isActive = true
    }
    
    init(products:[SKProduct],buyAction:@escaping (SKProduct) -> Void,restoreAction:@escaping (() -> ())){
        self.init()
        self.products = products
        self.buy = buyAction
        self.restore = restoreAction
        
        self.blurView.layer.cornerRadius = 0
        
        self.productPageHeight = 0
        
        var needBroadSection = false
        if products.count % 2 == 0{
            needBroadSection = false
        }else{
            needBroadSection = true
        }

        let restorePurchaseButton = UIButton(type: .system)
        restorePurchaseButton.translatesAutoresizingMaskIntoConstraints = false
        restorePurchaseButton.backgroundColor = UIColor.clear
        restorePurchaseButton.setTitle("Restore Purchase", for: .normal)
        restorePurchaseButton.titleLabel?.font = getFont(withSize: 22)
        restorePurchaseButton.setTitleColor(UIColor.black, for: .normal)
        restorePurchaseButton.addTarget(self, action: #selector(restorePurchase), for: .touchUpInside)
        restorePurchaseButton.layer.borderColor = UIColor.orange.cgColor
        restorePurchaseButton.layer.borderWidth = 1
        addSubview(restorePurchaseButton)
        NSLayoutConstraint.activate([
            restorePurchaseButton.leftAnchor.constraint(equalTo: leftAnchor),
            restorePurchaseButton.rightAnchor.constraint(equalTo: rightAnchor),
            restorePurchaseButton.topAnchor.constraint(equalTo: topAnchor),
            restorePurchaseButton.heightAnchor.constraint(equalToConstant: 60)
            ]
        )
        
        if needBroadSection{
            let text = "\(products[0].localizedTitle)\n\(products[0].localizedDescription)\n\nPrice: \(products[0].price)"
            let sectionOne = UIView()
            sectionOne.translatesAutoresizingMaskIntoConstraints = false
            sectionOne.backgroundColor = UIColor.clear
            sectionOne.layer.borderColor = UIColor.orange.cgColor
            sectionOne.layer.borderWidth = 1
            addSubview(sectionOne)
            NSLayoutConstraint.activate([
                sectionOne.leftAnchor.constraint(equalTo: leftAnchor),
                sectionOne.rightAnchor.constraint(equalTo: rightAnchor),
                sectionOne.topAnchor.constraint(equalTo: topAnchor, constant: 60),
                sectionOne.heightAnchor.constraint(equalToConstant: estimateTrameForText(text: text, fontSize: 20,width: 300).height+24)
                ]
            )
            sectionOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyProduct(_:))))
            self.sections.append(sectionOne)
//            
//            let imageview = UIImageView(image: #imageLiteral(resourceName: "limitedTimeGems"))
//            imageview.contentMode = .scaleAspectFill
//            imageview.backgroundColor = UIColor.clear
//            imageview.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(imageview)
//            NSLayoutConstraint.activate([
//                imageview.topAnchor.constraint(equalTo: , constant: 12),
//                imageview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
//                imageview.heightAnchor.constraint(equalToConstant: 60),
//                imageview.widthAnchor.constraint(equalToConstant: 60)
//                ]
//            )
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.text = text
            label.sizeToFit()
            label.isUserInteractionEnabled = false
            label.font = getFont(withSize: 20)
            label.adjustsFontForContentSizeCategory = true
            label.preferredMaxLayoutWidth = 300
            label.textAlignment = .center
            label.textColor = UIColor.purple
            sectionOne.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.topAnchor.constraint(equalTo: sectionOne.topAnchor, constant: 12),
                ]
            )
            productPageHeight = estimateTrameForText(text: text, fontSize: 20,width: 300).height + productPageHeight! + 24
        }
        var leftHeight = CGFloat()
        var rightHeight = CGFloat()
        var leftHeightConstraint = NSLayoutConstraint()
        for index in needBroadSection ? 1..<products.count : 0..<products.count{
            let indexUnderBroadSection = index - (needBroadSection ? 1 : 0)
            if indexUnderBroadSection % 2 == 0{
                let text = "\(products[index].localizedTitle)\n\n\(products[index].localizedDescription)\n\nPrice: \(products[index].price)"
                let sectionOne = UIView()
                sectionOne.translatesAutoresizingMaskIntoConstraints = false
                sectionOne.backgroundColor = UIColor.clear
                sectionOne.layer.borderColor = UIColor.orange.cgColor
                sectionOne.layer.borderWidth = 1
                addSubview(sectionOne)
                NSLayoutConstraint.activate([
                    sectionOne.leftAnchor.constraint(equalTo: leftAnchor),
                    sectionOne.rightAnchor.constraint(equalTo: centerXAnchor),
                    sectionOne.topAnchor.constraint(equalTo: restorePurchaseButton.bottomAnchor, constant: productPageHeight!),
                    ]
                )
                leftHeightConstraint = sectionOne.heightAnchor.constraint(equalToConstant: estimateTrameForText(text: text, fontSize: 16, width: 150).height+24)
                leftHeightConstraint.isActive = true
                leftHeight = estimateTrameForText(text: text, fontSize: 16, width: 150).height
                sectionOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyProduct(_:))))
                self.sections.append(sectionOne)
                
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 0
                label.text = text
                label.sizeToFit()
                label.isUserInteractionEnabled = false
                label.font = getFont(withSize: 16)
                label.adjustsFontForContentSizeCategory = true
                label.preferredMaxLayoutWidth = 150
                label.textAlignment = .center
                //random color
                label.textColor = UIColor.purple
                sectionOne.addSubview(label)
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: sectionOne.centerXAnchor),
                    label.topAnchor.constraint(equalTo: sectionOne.topAnchor, constant: 12),
                    ]
                )
            }else{
                let text = "\(products[index].localizedTitle)\n\n\(products[index].localizedDescription)\n\nPrice: \(products[index].price)"
                let sectionTwo = UIView()
                sectionTwo.translatesAutoresizingMaskIntoConstraints = false
                sectionTwo.backgroundColor = UIColor.clear
                sectionTwo.layer.borderColor = UIColor.orange.cgColor
                sectionTwo.layer.borderWidth = 1
                addSubview(sectionTwo)
                rightHeight = estimateTrameForText(text: text, fontSize: 16,width: 150).height
                NSLayoutConstraint.activate([
                    sectionTwo.leftAnchor.constraint(equalTo: centerXAnchor),
                    sectionTwo.rightAnchor.constraint(equalTo: rightAnchor),
                    sectionTwo.topAnchor.constraint(equalTo: restorePurchaseButton.bottomAnchor, constant: productPageHeight!),
                    sectionTwo.heightAnchor.constraint(equalToConstant: leftHeight > rightHeight ? leftHeight+24 : rightHeight+24)
                    ]
                )
                if rightHeight > leftHeight{
                    leftHeightConstraint.constant = rightHeight+24
                    productPageHeight = productPageHeight! + rightHeight + 24
                }else{
                    productPageHeight = productPageHeight! + leftHeight + 24
                }
                sectionTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyProduct(_:))))
                self.sections.append(sectionTwo)
                
                let sectionTwolabel = UILabel()
                sectionTwolabel.translatesAutoresizingMaskIntoConstraints = false
                sectionTwolabel.numberOfLines = 0
                sectionTwolabel.text = text
                sectionTwolabel.sizeToFit()
                sectionTwolabel.isUserInteractionEnabled = false
                sectionTwolabel.font = getFont(withSize: 16)
                sectionTwolabel.adjustsFontForContentSizeCategory = true
                sectionTwolabel.preferredMaxLayoutWidth = 150
                sectionTwolabel.textAlignment = .center
                sectionTwolabel.textColor = UIColor.purple
                sectionTwo.addSubview(sectionTwolabel)
                NSLayoutConstraint.activate([
                    sectionTwolabel.centerXAnchor.constraint(equalTo: sectionTwo.centerXAnchor),
                    sectionTwolabel.topAnchor.constraint(equalTo: sectionTwo.topAnchor, constant: 12),
                    ]
                )
            }
        }
        
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = getFont(withSize: 22)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.layer.borderColor = UIColor.orange.cgColor
        cancelButton.layer.borderWidth = 1
        addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.leftAnchor.constraint(equalTo: leftAnchor),
            cancelButton.rightAnchor.constraint(equalTo: rightAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
            ]
        )
    }
    
    var sections = [UIView]()
    
    var productPageHeight:CGFloat?
    
    var buy: ((SKProduct) -> Void)?
    
    var products:[SKProduct]?
    
    @objc func buyProduct(_ recog:UITapGestureRecognizer){
        var sectionIndex = 0
        for s in self.sections{
            if s.frame.contains(recog.location(in: self)){
                break
            }else{
                sectionIndex += 1
            }
        }
        buy!(products![sectionIndex])
        cancel()
    }
    
    var restore: (() -> Void)?
    
    
    @objc func restorePurchase(){
        restore!()
        cancel()
    }
    
    init(title:String,corner:CGFloat = 16,fontSize:Int = 24){
        self.init()
        cornerR = corner
        layer.cornerRadius = cornerR
        blurView.layer.cornerRadius = cornerR
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = title
        label.sizeToFit()
        label.isUserInteractionEnabled = false
        label.font = getFont(withSize: fontSize)
        label.adjustsFontForContentSizeCategory = true
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ]
        )
        self.label = label
    }
    
    /// For constructing a home menu button
    ///
    /// - Parameters:
    ///   - title: text that appears on the button
    ///   - image:
    convenience init(title:String,image:UIImage){
        self.init(title: title)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 45),
            imageView.widthAnchor.constraint(equalToConstant: 45)
            ]
        )
        
        
        let rightImageView = UIImageView(image: image.withHorizontallyFlippedOrientation())
        rightImageView.contentMode = .scaleAspectFill
        rightImageView.backgroundColor = UIColor.clear
        rightImageView.isUserInteractionEnabled = false
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rightImageView)
        NSLayoutConstraint.activate([
            rightImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            rightImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightImageView.heightAnchor.constraint(equalToConstant: 45),
            rightImageView.widthAnchor.constraint(equalToConstant: 45)
            ]
        )
        
    }
    
    convenience init(image:UIImage,corner:Int = 16,imageMultplier:CGFloat = 0.8){
        self.init()
        cornerR = CGFloat(corner)
        layer.cornerRadius = cornerR
        blurView.layer.cornerRadius = cornerR
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: imageMultplier),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: imageMultplier)
            ]
        )
        
        self.imageViewForButton = imageView
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.alpha = 0
        view.layer.cornerRadius = CGFloat(corner)
        view.layer.masksToBounds = true
        imageView.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor)
            ]
        )
        
        self.whiteMask = view
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        whiteMask?.alpha = 0.5
        whiteMask?.backgroundColor = UIColor.white
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.5) {
            self.whiteMask?.alpha = 0
        }
        whiteMask?.backgroundColor = UIColor.white
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.5) {
            self.whiteMask?.alpha = 0
        }
        whiteMask?.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UIView {
    
    func addShadow(color: UIColor,offsetBy:CGSize = CGSize(width: 0.8, height: 1.5),opacity:Float = 0.5) {
        layer.masksToBounds = false
        layer.shadowOffset = offsetBy
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor = backgroundCGColor
    }
}


class ShimmerViewForWidgetButton:UIView{
    
    var cornerR:CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = CGFloat(cornerR)
        view.layer.masksToBounds = true
        addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor)
            ]
        )
    }
    
    convenience init(corner:CGFloat){
        self.init()
        cornerR = corner
        layer.cornerRadius = cornerR
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
