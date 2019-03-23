//
//  IAPService.swift
//  AR tests
//
//  Created by Yu Wang on 2/11/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import StoreKit

class IAPService:NSObject{
    
    weak var delegate:IAPServiceDelegate?
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    var productsAvailable = false
    
    func getProduct(){
        let products:Set = [IAPProduct.pocketOfGems.rawValue,IAPProduct.bagOfGems.rawValue,IAPProduct.limitedTimeGem.rawValue,IAPProduct.newUserGift.rawValue,IAPProduct.weatherPack.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product:IAPProduct){
        guard let productToPurcahse = products.filter({ $0.productIdentifier == product.rawValue}).first else { return }
        let payment = SKPayment(product: productToPurcahse)
        paymentQueue.add(payment)
    }
    
    func restorePurchases(){
        paymentQueue.restoreCompletedTransactions()
        delegate?.restorePurchase(service: self)
    }
}

extension IAPService:SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: today)
        self.products = self.products.filter { $0.productIdentifier != IAPProduct.limitedTimeGem.rawValue }
        let newUserGift = response.products.filter { $0.productIdentifier == IAPProduct.newUserGift.rawValue }.first
        if let newUserGift = newUserGift{
            self.products.removeAll { (product) -> Bool in
                product.productIdentifier == IAPProduct.newUserGift.rawValue
            }
            self.products.insert(newUserGift, at: 0)
        }
        if components.weekday == 7 {
            let limitedGemSell = response.products.filter { $0.productIdentifier == IAPProduct.limitedTimeGem.rawValue }.first
            if let limitedGemSell = limitedGemSell{
                self.products.insert(limitedGemSell, at: 0)
            }
        }
    
        self.productsAvailable = true
    }
}

extension IAPService:SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(error.localizedDescription)
        delegate?.restoreFailed(service: self)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.count == 0 {
            delegate?.restoreCompleted(service:self,message:"no")
        }else{
            print(queue.transactions.count)
            delegate?.restoreCompleted(service:self,message:"")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState {
            case .purchasing:
                delegate?.purchasing(service: self)
            case .purchased,.restored:
                let id = transaction.payment.productIdentifier
                if let productPurchased = self.products.filter({ $0.productIdentifier == id}).first{
                    delegate?.purchaseSuccess(service: self, product: productPurchased)
                }
                queue.finishTransaction(transaction)
            case .failed:
                delegate?.purchaseFailed(service: self)
                queue.finishTransaction(transaction)
            case .deferred:
                print("deferred")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
//
//extension SKPaymentTransactionState {
//    func status() -> String{
//        switch self {
//        case .deferred:
//            return "deferred"
//        case .purchasing:
//            return "purchasing"
//        case .purchased:
//            return "purchased"
//        case .failed:
//            return "failed"
//        case .restored:
//            return "restored"
//        }
//    }
//}
