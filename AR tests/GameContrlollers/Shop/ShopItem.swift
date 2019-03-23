//
//  ShopItem.swift
//  AR tests
//
//  Created by Yu Wang on 2/15/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import UIKit

enum PaymentOptions:String,Codable{
    case cash = "cash"
    case watchingVideos = "watchingVideos"
    case gems = "gems"
}

enum ShopItemsName:String,Codable{
    
    //pong ball
    case basicPingPong = "Basic PingPong Ball"
    case orangePingPong = "Orange Ball"
    
    //basketball skin
    case basicBasketBallSkin = "Basic basketball skin"
    case basketballNBASkin = "NBA Official Game Ball"
    case basketballGoldSkin = "Golden Ball"
    
    //basketball effevts
    case basicBasketballEffect = "No Effect"
    case basketballFireEffect = "Fire Effect"
    case basketballMagicEffect = "Magic Effect"
    
    //pong effects
    case basicPongEffect = "No Effects"
    case pongLavaEffect = "Lava On Your Ball"
    case pingpongBallFireEffect = "Fire Effect  "
    case pongDragonEffect = "Chinese Gragon Effect"
    
    //items
    case slowTime = "Slow Time Potion"
    case whiteLight = "flashbang"
    case fire = "Molotov"
    case love = "Love Potion"
    case manyLoves = "Advanced Love Potion"
    case angry = "Angry Potion"
    //weather
    case basicWeather = "No Weather"
    case rain = "Rain"
    case star = "The Galaxy"
}

class ShopItem:Hashable,Equatable,Codable{
    static func == (lhs: ShopItem, rhs: ShopItem) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name:ShopItemsName
    var image:String
    var description:String
    var price:[PaymentOptions:Int]
    
    init(name:ShopItemsName,image:String,description:String,price:[PaymentOptions:Int]) {
        self.name = name
        self.image = image
        self.description = description
        self.price = price
    }
}
