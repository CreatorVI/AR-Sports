//
//  IAPProduct.swift
//  AR tests
//
//  Created by Yu Wang on 2/11/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation

enum IAPProduct:String {
    case pocketOfGems = "AR_Sports.APocketOfGems"
    case bagOfGems = "AR_Sports.BagOfGem"
    case newUserGift = "com.example.ARtests.newUserGift"
    case limitedTimeGem = "com.example.ARtests.limitedTimeGem"
    case weatherPack = "AR_Sports.newweatherPack"
    
    static let all = [IAPProduct.pocketOfGems,.bagOfGems,.newUserGift,.limitedTimeGem,.weatherPack]

}
