//
//  RootGameController.swift
//  AR tests
//
//  Created by Yu Wang on 2/15/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import UIKit
import GameKit

enum ToturialProgess:String,Codable{
    case universal = "universal"
    case pongBasic = "pong basic"
    case basketballBasic = "basketball basic"
    case multiplayer = "multiplayer"
}

class Selections:Codable{
    var basketBallSelection:ShopItem = AllItemsAndMissions.basicItems[1]
    var basketBallEffect:ShopItem = AllItemsAndMissions.basicItems[3]
    var pongSelection:ShopItem = AllItemsAndMissions.basicItems[0]
    var pongEffect:ShopItem = AllItemsAndMissions.basicItems[4]
    var weather:ShopItem = AllItemsAndMissions.basicItems[2]
}

class RootGameController:Codable{
    var playerName:String{
        didSet{
            save()
        }
    }
    var ownedItems:[ShopItem]{
        didSet{
            save()
            var owned = 0
            
            AllItemsAndMissions.allItems.forEach { (item) in
                if self.ownedItems.contains(item){
                    owned += 1
                }
            }
            
            var achievements = [GKAchievement]()
            let fullAchievement = GKAchievement(identifier: Constants.gcLeaderAchievementBuyThemAll)
            fullAchievement.percentComplete = Double(100*(owned/AllItemsAndMissions.allItems.count))
            if fullAchievement.percentComplete == 100{
                fullAchievement.showsCompletionBanner = true
            }
            achievements.append(fullAchievement)
            GKAchievement.report(achievements)
        }
    }
    var unownedItems:[ShopItem]
    var selectedItems:Selections{
        didSet{
            save()
        }
    }
    var missionToday:[Mission]{
        didSet{
            save()
        }
    }
    var gems:Int {
        didSet{
            save()
        }
    }
    var rawGems = 5{
        didSet{
            save()
        }
    }
    var experience:Int{
        didSet{
            save()
        }
    }
    var level:Int{
        didSet{
            save()
        }
    }
    var winTimes:Int{
        didSet{
            save()
        }
    }
    var loseTimes:Int{
        didSet{
            save()
        }
    }
    var drawTimes:Int{
        didSet{
            save()
        }
    }
    var consumableItems:[ShopItem:Int]{
        didSet{
            save()
        }
    }
    
    
    var highScores:[GameToPresentOptions:Int]{
        didSet{
            save()
        }
    }
    var watchedVideos:[ShopItem:Int]{
        didSet{
            save()
        }
    }
    
    var timesOfGame:[ToturialProgess:Int]{
        didSet{
            save()
        }
    }
    
    var getGemsID:Int = 0{
        didSet{
            save()
        }
    }
    
    var timesOfPlayingGameNotTutorial = [GameToPresentOptions.archery : 0,.basketballBallLimited : 0,.basketballFree : 0,.basketballTimeLimited : 0,.pong : 0,.pongSinglePlayer : 0]
    
    var hasLoggedInFirstTime = false
    var hasLoggedIn = false
    var hasFollowedMe = false
    var hasFollowedGame = false
    var hasSharedVideo = false
    var hasSharedGame = false
    var hasRatedApp = false
    
    var hasPurchasedNewUserGift = false
    var hasPurchasedWeatherPack = false
    
    func save(){
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        guard let data = try? encoder.encode(self)
            else{fatalError("can't encode to PropertyList")}
        UserDefaults.standard.set(data, forKey: Constants.userDefaultSavingKeyForGameController)
    }
    
    init(playerName:String,ownedItems:[ShopItem],unownedItems:[ShopItem],missionToday:[Mission],gems:Int,highScores:[GameToPresentOptions:Int],watchedVideos:[ShopItem:Int], experience:Int, level:Int, winTimes:Int, loseTimes:Int, drawTimes:Int, consumableItems:[ShopItem:Int], selectedItems:Selections,timesOfGame:[ToturialProgess:Int]) {
        self.playerName = playerName
        self.ownedItems = ownedItems
        self.unownedItems = unownedItems
        self.missionToday = missionToday
        self.gems = gems
        self.highScores = highScores
        self.watchedVideos = watchedVideos
        self.experience = experience
        self.level = level
        self.winTimes = winTimes
        self.loseTimes = loseTimes
        self.drawTimes = drawTimes
        self.consumableItems = consumableItems
        self.selectedItems = selectedItems
        self.timesOfGame = timesOfGame
    }
    
    convenience init(wantDefault:Bool){
        self.init(
            playerName: UIDevice.current.name,
            ownedItems: AllItemsAndMissions.basicItems,
            unownedItems: AllItemsAndMissions.allItems,
            missionToday: AllItemsAndMissions.allMissions,
            gems: 5,
            highScores: [GameToPresentOptions.archery : 0,.basketballBallLimited : 0,.basketballFree : 0,.basketballTimeLimited : 0,.pong : 0,.pongSinglePlayer : 0],
            watchedVideos: [AllItemsAndMissions.allItems[0]:0,AllItemsAndMissions.allItems[1]:0,AllItemsAndMissions.allItems[2]:0,AllItemsAndMissions.allItems[3]:0,AllItemsAndMissions.allItems[4]:0,AllItemsAndMissions.allItems[5]:0,AllItemsAndMissions.allItems[6]:0,AllItemsAndMissions.allItems[7]:0,AllItemsAndMissions.allItems[8]:0,AllItemsAndMissions.allItems[9]:0,AllItemsAndMissions.allComsumableItems[0]:0,AllItemsAndMissions.allComsumableItems[1]:0,AllItemsAndMissions.allComsumableItems[2]:0,AllItemsAndMissions.allComsumableItems[3]:0,AllItemsAndMissions.allComsumableItems[4]:0,AllItemsAndMissions.allComsumableItems[5]:0,],
            experience: 0,
            level: 1,
            winTimes: 0,
            loseTimes: 0,
            drawTimes: 0,
            consumableItems: [AllItemsAndMissions.allComsumableItems[0]:3,AllItemsAndMissions.allComsumableItems[1]:3,AllItemsAndMissions.allComsumableItems[2]:3,AllItemsAndMissions.allComsumableItems[3]:3,AllItemsAndMissions.allComsumableItems[4]:3,AllItemsAndMissions.allComsumableItems[5]:3,],
            selectedItems: Selections(),
            timesOfGame:[ToturialProgess.universal : 0,.pongBasic : 0,.basketballBasic : 0,.multiplayer : 0]
        )
    }
}

class AllItemsAndMissions:NSObject{
    static let allItems = [
        ShopItem(name: ShopItemsName.basketballFireEffect, image: "", description: NSLocalizedString("Add Fire To Your Basketball And Scare Your Friends!", comment: ""), price: [PaymentOptions.gems : 20,PaymentOptions.watchingVideos : 15]),
        ShopItem(name: ShopItemsName.basketballGoldSkin, image: "", description: NSLocalizedString("Golden Basketball! Turn Everything Into Gold With It", comment: ""), price: [PaymentOptions.gems : 50]),
        ShopItem(name: ShopItemsName.basketballMagicEffect, image: "", description: NSLocalizedString("Like Magic...", comment: ""), price: [PaymentOptions.gems : 25,PaymentOptions.watchingVideos : 18]),
        ShopItem(name: ShopItemsName.basketballNBASkin, image: "", description: NSLocalizedString("Cool NBA Official Game Basketball", comment: ""), price: [PaymentOptions.gems : 40]),
        ShopItem(name: ShopItemsName.pingpongBallFireEffect, image: "", description: NSLocalizedString("Fire Your Ball!", comment: ""), price: [PaymentOptions.gems : 20,PaymentOptions.watchingVideos : 15]),
        ShopItem(name: ShopItemsName.rain, image: "", description: NSLocalizedString("Get Rainy When Playing If You Like Rainy Days", comment: ""), price: [PaymentOptions.gems : 100]),
        ShopItem(name: ShopItemsName.star, image: "", description: NSLocalizedString("Play In The Galaxy", comment: ""), price: [PaymentOptions.gems : 100]),
        ShopItem(name: ShopItemsName.pongDragonEffect, image: "", description: NSLocalizedString("A Drgon Will Occur When You Shoot The Ball", comment: ""), price: [PaymentOptions.gems : 200]),
        ShopItem(name: ShopItemsName.orangePingPong, image: "", description: NSLocalizedString("Maybe You'll Like This Orange One", comment: ""), price: [PaymentOptions.gems : 10,PaymentOptions.watchingVideos : 5]),
        ShopItem(name: ShopItemsName.pongLavaEffect, image: "", description: NSLocalizedString("\"Burn Them All\" With This Cool Effect", comment: ""), price: [PaymentOptions.gems : 40])
    ]
    
    static let allComsumableItems:[ShopItem] = [
        ShopItem(name: ShopItemsName.slowTime, image: "slowTime", description: "Slow the time to one half", price: [PaymentOptions.gems : 2,PaymentOptions.watchingVideos : 2]),
        ShopItem(name: ShopItemsName.love, image: "love", description: "Present A \"Love\" Model", price: [PaymentOptions.gems : 1,PaymentOptions.watchingVideos : 1]),
        ShopItem(name: ShopItemsName.whiteLight, image: "whiteLight", description: "Blind your friend for 5 seconds", price: [PaymentOptions.gems : 1,PaymentOptions.watchingVideos : 1]),
        ShopItem(name: ShopItemsName.manyLoves, image: "manyLoves", description: "Fill The Air With Loves", price: [PaymentOptions.gems : 3]),
        ShopItem(name: ShopItemsName.angry, image: "angry", description: "Show your anger", price: [PaymentOptions.gems : 1,PaymentOptions.watchingVideos : 1]),
        ShopItem(name: ShopItemsName.fire, image: "fire", description: "Fire the play area ground", price: [PaymentOptions.gems : 2,PaymentOptions.watchingVideos : 2]),
    ]
    
    //1 gem = 3 items,3 gems = 10 items, 5 gems = 20 items
    //2 gem = 3 items,6 gems = 10 items, 10 gems = 20 items
    //3 gem = 3 items,9 gems = 10 items, 15 gems = 20 items
    
    static let basicItems:[ShopItem] = [
        ShopItem(name: ShopItemsName.basicPingPong, image: "", description: NSLocalizedString("Got from a Chinese friend", comment: ""), price: [PaymentOptions : Int]()),
        ShopItem(name: ShopItemsName.basicBasketBallSkin, image: "", description: NSLocalizedString("Cheap but still beautiful basketball. Right?", comment: ""), price: [PaymentOptions : Int]()),
        ShopItem(name: ShopItemsName.basicWeather, image: "", description: NSLocalizedString("Your Weather Is Your Weather", comment: "") , price: [PaymentOptions : Int]()),
        ShopItem(name: ShopItemsName.basicBasketballEffect, image: "", description: "" , price: [PaymentOptions : Int]()),
        ShopItem(name: ShopItemsName.basicPongEffect, image: "", description: "" , price: [PaymentOptions : Int]())
    ]
    
    static let allMissions:[Mission] = [
        Mission(title: NSLocalizedString("Share Play Moments", comment: ""), description: NSLocalizedString("Try Recording Some Videos Either With The Record Button At Right Or With IOS Built-In Screen Recording And Share Them With Your Friends. You Get 3 Gems For Sharing The Fun!", comment: ""), awards: 2),
        Mission(title: NSLocalizedString("Share This Game", comment: ""), description: NSLocalizedString("Share This Super Amazing Game With Your Friends And Get 3 Gems!", comment: ""), awards: 3),
        Mission(title: NSLocalizedString("Play More", comment: ""), description: NSLocalizedString("Every Time You Finish A Game With A Score More Than 1, You get A 10% Chance To Find A Gem. You Get A 50% Chance When Play In Multiplayer Mode!", comment: ""), awards: 0),
        Mission(title: NSLocalizedString("Watch Some Videos", comment: ""), description: NSLocalizedString("Watch Some Fun Videos And Get A Gem For Every One Of Them", comment: ""), awards: 1),
        Mission(title: NSLocalizedString("Login", comment: ""), description: NSLocalizedString("Login In Your Info Page With Email, Facebook or Google And Get 3 Gems", comment: ""), awards: 2),
        Mission(title: NSLocalizedString("Follow Me On Instagram", comment: ""), description: NSLocalizedString("Simply Follow And Get 3 Gems!", comment: ""), awards: 3),
        Mission(title: NSLocalizedString("Follow The AR Sports Official Account On Instagram", comment: ""), description: NSLocalizedString("Simply Follow And Get 3 Gems!", comment: ""), awards: 3),
        Mission(title: NSLocalizedString("Rate The App", comment: ""), description: NSLocalizedString("It's an amazing app, isn't it?\nRate and get 3 gems", comment: ""), awards: 3)
    ]
    
    static let allHelpers:[Helper] = [
        Helper(snapShot: #imageLiteral(resourceName: "molecular-bond"), title: "Why Can't I Find A Surface", texts: ["AR technology uses your camera as a \"scanner\" to get information about your surroundings. It establishes a model after the scan and connect the model to a snapshot of the realworld.","Your camera can only see the color difference in the realworld and it analyzes the difference to check if there is a surface. So in order for the difference-telling system to work, you must provide a surface with lots of differences in color (carpets, newspapers, books, exam papers etc)","And AR also use depth which connect the virtual objects with real-world snapshots with accurate location information. Sometimes you have the illusion that somwthing far away is right in front of you and so does your camera. This illusion disappears when you look at the object from different angles so you should also rotate your phone with your camera facing the surface in order to quikly detect the surface."], images: [UIImage(named: "universal1")!,UIImage(named: "universal2")!,UIImage(named: "universal3")!]),
        Helper(snapShot: #imageLiteral(resourceName: "criminal-fighting-with-a-person"), title: "About Multiplayer", texts: [" "," "," "," "," "," "," "], images: [UIImage(named: "multiplayer1")!,UIImage(named: "multiplayer2")!,UIImage(named: "multiplayer3")!,UIImage(named: "multiplayer4")!,UIImage(named: "multiplayer5")!,UIImage(named: "multiplayer6")!,UIImage(named: "multiplayer7")!]),
        Helper(snapShot: #imageLiteral(resourceName: "limitedTimeGems"), title: "How To Use The Special Items", texts: ["The first one is slow time potion, it slows the game speed to one half for 3 seconds so you can better handle the game. For example, in table tennis game, you may want to use this to catch a ball.","The love potion presents a 3D lowpoly model of a red heart in front of both players.","The flashbang makes your friend's screen white for 3 seconds. You might use it to prevent your friend from catching a ball or you could simply surprise your friend.","The advanced love potion makes the play area romatic by surrounding the players with many \"hearts\". This effect will last till the end of this game","The angry potion presents a 3D angry emoji. You can use it to show your anger or just for fun.","The Molotov fires the play area. You should be careful because such effect might slow your phone down. You may want to end a game with this because normally, everything slows down after the fire is added"], images: [#imageLiteral(resourceName: "slowTime"),#imageLiteral(resourceName: "love"),#imageLiteral(resourceName: "whiteLight"),#imageLiteral(resourceName: "manyLoves"),#imageLiteral(resourceName: "angry"),#imageLiteral(resourceName: "fire")])
        ]
}

