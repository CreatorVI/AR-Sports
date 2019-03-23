//
//  TutorialViewController.swift
//  AR tests
//
//  Created by Yu Wang on 2/24/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import Each

class TutorialViewController: UIViewController {
    
    weak var delegate:TutorialViewControllerDelegate?
    
    let eachTimer = Each.init(1).seconds
    
    var timer = 0{
        didSet{
            self.block.label!.text = String(3-self.timer)
        }
    }
    
    lazy var viewStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: tutorialViews)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    var viewStackLeftAnchor = NSLayoutConstraint()
    
    lazy var tutorialViews:[UIImageView] = {
        var views = [UIImageView]()
        for index in firstImageIndex...imageEndIndex{
            let view = UIImageView(image: UIImage(named: "\(self.imagePrefixName)\(index)"))
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFill
            view.backgroundColor = UIColor.lightGray
            views.append(view)
        }
        return views
    }()
    
    let block = BluredShadowView(title: "3", corner: 40, fontSize: 24)
    
    var blockBottomAnchor = NSLayoutConstraint()
    
    var imagePrefixName:String
    
    var imageEndIndex:Int
    
    var firstImageIndex:Int
    
    var lockForward = true
    
    lazy var currentImageIndex = firstImageIndex
    
    init(imagePrefixName:String,imageEndIndex:Int,firstImageIndex:Int = 1,lockForward:Bool = true){
        self.imageEndIndex = imageEndIndex
        self.imagePrefixName = imagePrefixName
        self.firstImageIndex = firstImageIndex
        self.lockForward = lockForward
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        setUpStack()
        setUpForward()
        setUpSkip()
        if lockForward{
            setUpTimer()
        }
    }
    
    func setUpTimer(){
        eachTimer.perform { () -> NextStep in
            if self.timer >= 3{
                self.timer = 0
                self.transitionBlock()
                return .stop
            }else{
                self.timer += 1
                return .continue
            }
            
        }
    }
    
    func setUpStack(){
        let screenHeight = view.frame.height
        let screenWidth = view.frame.width
        view.addSubview(viewStack)
        if screenHeight > screenWidth{
            NSLayoutConstraint.activate([
                viewStack.topAnchor.constraint(equalTo: view.topAnchor),
                viewStack.heightAnchor.constraint(equalToConstant: CGFloat(screenWidth/0.462)),
                viewStack.widthAnchor.constraint(equalToConstant: CGFloat(tutorialViews.count)*screenWidth+CGFloat((tutorialViews.count-1)*20)),
                ]
            )
        }else{
            NSLayoutConstraint.activate([
                viewStack.topAnchor.constraint(equalTo: view.topAnchor),
                viewStack.heightAnchor.constraint(equalToConstant: screenHeight),
                viewStack.widthAnchor.constraint(equalToConstant: CGFloat(tutorialViews.count)*screenHeight*CGFloat(0.462)+CGFloat((tutorialViews.count-1)*20)),
                ]
            )
        }
        viewStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewStackLeftAnchor = viewStack.leftAnchor.constraint(equalTo: view.leftAnchor)
        viewStackLeftAnchor.isActive = true
    }
    
    func setUpSkip(){
        let skipButton = UILabel()
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.numberOfLines = 1
        skipButton.text = "Skip"
        skipButton.font = getFont()
        skipButton.sizeToFit()
        skipButton.adjustsFontForContentSizeCategory = true
        skipButton.backgroundColor = UIColor.lightGray
        skipButton.isUserInteractionEnabled = true
        skipButton.layer.cornerRadius = 8
        skipButton.clipsToBounds = true
        view.addSubview(skipButton)
        NSLayoutConstraint.activate([
            skipButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: CGFloat(-12)),
            skipButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12)
            ]
        )
        skipButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skip)))
    }
    
    func setUpForward(){
        let forward = UIImageView(image: #imageLiteral(resourceName: "forward"))
        forward.translatesAutoresizingMaskIntoConstraints = false
        forward.contentMode = .scaleAspectFill
        forward.backgroundColor = UIColor.clear
        forward.isUserInteractionEnabled = true
        view.addSubview(forward)
        NSLayoutConstraint.activate([
            forward.heightAnchor.constraint(equalToConstant: 60),
            forward.rightAnchor.constraint(equalTo: view.rightAnchor, constant: CGFloat(-12)),
            forward.widthAnchor.constraint(equalToConstant: 60),
            forward.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
            ]
        )
        forward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forwardViewStack)))
        
        if lockForward{
            block.isUserInteractionEnabled = false
            view.addSubview(block)
            NSLayoutConstraint.activate([
                block.heightAnchor.constraint(equalToConstant: 80),
                block.rightAnchor.constraint(equalTo: view.rightAnchor, constant: CGFloat(-6)),
                block.widthAnchor.constraint(equalToConstant: 80),
                ]
            )
            blockBottomAnchor = block.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
            blockBottomAnchor.isActive = true
        }
    }
    
    func transitionBlock(up:Bool = false){
        if up{
            self.blockBottomAnchor.constant -= 100
            self.block.alpha = 1
            self.view.layoutIfNeeded()
        }else{
            self.blockBottomAnchor.constant += 100
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.block.alpha = 0
            })
        }
        
    }
    
    @objc func skip(){
        self.showAlert(title: "Skipping Tutorials May Result In Bad Experience Later", message: "The Tutorial shows you how to detect surfaces and if you can't detect surfaces, you can't play game", buttonTitle: "Skip", showCancel: true) { (_) in
            self.delegate?.viewDidDismiss(tutorialVC: self)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func forwardViewStack(){
        if self.block.alpha == 0 || !lockForward{
            if currentImageIndex >= imageEndIndex{
                self.dismiss(animated: true, completion: nil)
                delegate?.viewDidDismiss(tutorialVC:self)
                return
            }
            currentImageIndex += 1
            
            let screenHeight = self.view.frame.height
            let screenWidth = self.view.frame.width
            if screenWidth > screenHeight{
                self.viewStackLeftAnchor.constant -= (screenHeight*CGFloat(0.462)+CGFloat(20))
            }else{
                self.viewStackLeftAnchor.constant -= (screenWidth+CGFloat(20))
            }
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            },completion:{ (_) in
                if self.lockForward{
                    self.eachTimer.restart()
                }
            })
            if self.lockForward{
                self.transitionBlock(up: true)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eachTimer.stop()
    }
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }

}
