//
//  ImageAndVideoHandlingView.swift
//  AR tests
//
//  Created by Yu Wang on 2/18/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import UIKit
import ReplayKit
import Photos

class ImageAndVideoHandlingView:UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    var scrollView:UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentSize = CGSize(width: 276, height: 1200)
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = false
        return view
    }()
    
    let okButton = BluredShadowView(title: "OK")
    
    var okAction = {
        return
    }
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    
    var videoThumbnails = [UIImage](){
        didSet{
            videoCollectionView.reloadData()
        }
    }
    
    var previewControllers = [RPPreviewViewController](){
        didSet{
            videoCollectionView.reloadData()
        }
    }
    
    var images = [UIImage](){
        didSet{
            imageCollectionView.reloadData()
            imageCollectionView.layoutIfNeeded()
        }
    }
    
    var selectedImages:[Int]?
    
    var videoCollectionVeiwID = "videoCollectionVeiwID"
    
    var imageCollectionVeiwID = "imageCollectionVeiwID"
    
    var videoCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var defaultShareButton = BluredShadowView(image: #imageLiteral(resourceName: "share"))
    var instagramSharingButton = BluredShadowView(image: #imageLiteral(resourceName: "instagram"))
    
    var imageCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()

    
    lazy var buttonStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [instagramSharingButton,defaultShareButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 60
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = UIColor.green
        //        isUserInteractionEnabled = false
        addShadow(color: UIColor.black)
        
        blurView.frame = self.bounds
        blurView.layer.cornerRadius = 8
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(blurView)
        self.backgroundColor = UIColor.clear
        blurView.isUserInteractionEnabled = false
        
        
        
    }
    
    convenience init(videoThumbnails:[UIImage],previewControllers:[RPPreviewViewController],images:[UIImage],okAction:@escaping ()->(),shareSuccessAction:@escaping () -> ()){
        self.init()
        self.videoThumbnails = videoThumbnails
        self.previewControllers = previewControllers
        self.images = images
        self.okAction = okAction
        self.handleShareSuccess = shareSuccessAction
        
        imageCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: imageCollectionVeiwID)
        videoCollectionView.register(VideoCell.self, forCellWithReuseIdentifier: videoCollectionVeiwID)
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            scrollView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 12)
            ]
        )
        
        if videoThumbnails.count > 0{
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Tap To View And Save"
            label.font = getFont(withSize: 18)
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.preferredMaxLayoutWidth = 276
            scrollView.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: scrollView.topAnchor),
                label.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
                ]
            )
            
            scrollView.addSubview(videoCollectionView)
            NSLayoutConstraint.activate([
                videoCollectionView.heightAnchor.constraint(equalToConstant: 150),
                videoCollectionView.leftAnchor.constraint(equalTo: label.leftAnchor),
                videoCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
                videoCollectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12)
                ]
            )
        }
        if images.count > 0{
            let imageLabel = UILabel()
            imageLabel.translatesAutoresizingMaskIntoConstraints = false
            imageLabel.text = videoThumbnails.count > 0 ? "You Have Also Captured Some Amazing Moments With Snapshot\nShare Them And Get Awards (These Images Have Been Saved, Select The Ones You Want To Share)" : "You Have Captured Some Amazing Moments With Snapshot\nShare Them And Get Awards (These Images Have Been Saved, Select The Ones You Want To Share)"
            imageLabel.font = getFont(withSize: 18)
            imageLabel.adjustsFontForContentSizeCategory = true
            imageLabel.numberOfLines = 0
            imageLabel.preferredMaxLayoutWidth = 276
            scrollView.addSubview(imageLabel)
            NSLayoutConstraint.activate([
                imageLabel.topAnchor.constraint(equalTo: videoThumbnails.count > 0 ?videoCollectionView.bottomAnchor : scrollView.topAnchor, constant: 12),
                imageLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
                ]
            )
            
            scrollView.addSubview(imageCollectionView)
            NSLayoutConstraint.activate([
                imageCollectionView.heightAnchor.constraint(equalToConstant: 150),
                imageCollectionView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
                imageCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
                imageCollectionView.topAnchor.constraint(equalTo: images.count > 0 ? imageLabel.bottomAnchor : videoCollectionView.bottomAnchor, constant: 12)
                ]
            )
            
            scrollView.addSubview(buttonStack)
            NSLayoutConstraint.activate([
                buttonStack.heightAnchor.constraint(equalToConstant: 64),
                buttonStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                buttonStack.widthAnchor.constraint(equalToConstant: 188),
                buttonStack.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 12)
                ]
            )
            
            defaultShareButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
            defaultShareButton.isHidden = true
            instagramSharingButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareToIns)))
            instagramSharingButton.isHidden = true
        }

        self.okAction = okAction
        
        scrollView.addSubview(okButton)
        NSLayoutConstraint.activate([
            okButton.topAnchor.constraint(equalTo: images.count > 0 ? imageCollectionView.bottomAnchor : videoCollectionView.bottomAnchor, constant: images.count > 0 ? 112 : 24),
            okButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            okButton.heightAnchor.constraint(equalToConstant: 50),
            okButton.widthAnchor.constraint(equalToConstant: 80)
            ]
        )
        okButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ok)))
    }
    
    @objc func share(){
        let firstActivityItem = "Check out this AR game"
        // If you want to put an image
        
        var activityItems = [Any]()
        activityItems.append(firstActivityItem)
        for i in 0..<selectedImages!.count{
            activityItems.append(images[i])
        }
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: activityItems, applicationActivities: nil)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [.addToReadingList,.assignToContact,.copyToPasteboard,.markupAsPDF,.openInIBooks,.saveToCameraRoll,.print]
        
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if !success{
                return
            }else{
                self.shareSuccess()
            }
        }
        
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        if let vc = topVC?.presentedViewController{
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceView = self
            }
            vc.present(activityViewController, animated: true)
        }
    }
    
    var handleShareSuccess = {
        return
    }
    
    func shareSuccess(){
        if !hasShared{
            handleShareSuccess()
            hasShared = true
        }
    }
    
    @objc func shareToIns(){
        ShareExtension.sharedManager.postImageToInstagramWithCaption(imageInstagram: images[selectedImages!.first!], instagramCaption: "", view: self)
    }
    
    var hasShared = false
    
    @objc func ok(){
        okAction()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == videoCollectionView{
            return videoThumbnails.count
        }else{
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == videoCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoCollectionVeiwID, for: indexPath) as! VideoCell
            cell.imageView.image = videoThumbnails[indexPath.row]
            cell.previewController = previewControllers[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCollectionVeiwID, for: indexPath) as! ImageCell
            cell.imageView.image = images[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == imageCollectionView{
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell{
                if self.selectedImages != nil{
                    if self.selectedImages!.contains(indexPath.row){
                        self.selectedImages!.removeAll { (number) -> Bool in
                            return number == indexPath.row
                        }
                        cell.layer.borderWidth = 0
                    }else{
                        self.selectedImages!.append(indexPath.row)
                        cell.layer.borderWidth = 3
                        cell.layer.borderColor = UIColor.yellow.cgColor
                    }
                }else{
                    selectedImages = [Int]()
                    selectedImages!.append(indexPath.row)
                    cell.layer.borderWidth = 3
                    cell.layer.borderColor = UIColor.yellow.cgColor
                }
                
                if selectedImages?.count == 0{
                    instagramSharingButton.isHidden = true
                    defaultShareButton.isHidden = true
                }else{
                    instagramSharingButton.isHidden = false
                    defaultShareButton.isHidden = false
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollectionView{
            let image = images[indexPath.row]
            return CGSize(width: image.size.width/image.size.height*150, height: 150)
        }else{
            let image = videoThumbnails[indexPath.row]
            return CGSize(width: image.size.width/image.size.height*150, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class VideoCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    var previewController = RPPreviewViewController()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor)
            ]
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        if let vc = topVC?.presentedViewController{
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                previewController.modalPresentationStyle = .fullScreen
                previewController.popoverPresentationController?.sourceView = self
            }
            vc.present(previewController, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImageCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
//    var selectionIndicator = UIImageView(image: #imageLiteral(resourceName: "selectionIndicator"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 12
        layer.masksToBounds = true
//        selectionIndicator.frame = frame
//        selectionIndicator.contentMode = .scaleToFill
//        selectionIndicator.isHidden = false
//        addSubview(selectionIndicator)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor)
            ]
        )
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
