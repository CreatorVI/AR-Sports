//
//  ShareExtension.swift
//  AR tests
//
//  Created by Yu Wang on 2/18/19.
//  Copyright © 2019 Illumination. All rights reserved.
//
import Foundation
import UIKit

//let documentInteractionController = UIDocumentInteractionController()
class ShareExtension: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let documentInteractionController = UIDocumentInteractionController()
    private let kInstagramURL = "instagram://"
    private let kUTI = "com.instagram.exclusivegram"
    private let kfileNameExtension = "instagram.igo"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    // singleton manager
    private override init() {}
    static let sharedManager = ShareExtension()
    
    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIView) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kInstagramURL)
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            
            do {
                try imageInstagram.jpegData(compressionQuality: 0.75)?.write(to: URL(fileURLWithPath: jpgPath), options: .atomic)
            } catch {
                print(error)
            }
            
            let rect = CGRect.zero
            let fileURL = NSURL.fileURL(withPath: jpgPath)
            
            
            documentInteractionController.url = fileURL
            documentInteractionController.delegate = self
            documentInteractionController.uti = kUTI
            
            // adding caption for the image
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
        }
        else {
            let topVC = UIApplication.shared.keyWindow?.rootViewController
            if let vc = topVC?.presentedViewController{
                vc.showAlert(title: "Instagram not installed", message: "Please install instagram first")
            }
        }
    }
}

