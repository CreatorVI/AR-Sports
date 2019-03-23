//
//Delegates.swift
//  AR tests
//
//  Created by Yu Wang on 3/9/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import StoreKit
protocol TutorialViewControllerDelegate:AnyObject {
    func viewDidDismiss(tutorialVC:TutorialViewController)
}

protocol IAPServiceDelegate:AnyObject {
    func purchasing(service:IAPService)
    func purchaseSuccess(service:IAPService,product:SKProduct)
    func purchaseFailed(service:IAPService)
    func restorePurchase(service:IAPService)
    func restoreCompleted(service:IAPService,message:String)
    func restoreFailed(service:IAPService)
}


