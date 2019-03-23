//
//  Constants.swift
//  AR tests
//
//  Created by Yu Wang on 2/19/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import Darwin

struct Constants {
    
    static let userDefaultSavingKeyForGameController = "we need alita: battle angle sequel and prequel"
    
//    static let AUTHURL = "https://www.instagram.com/oauth/authorize/"
//    static let APIURL = "https://www.instagram.com/v1/users/"
//    static let CLIENTID = "629835d4d79d4426ba165cec418ef445"
//    static let CLIENTSECRET = "304f4ec65b35402c93094c4a10011b81"
//    static let REDIRECTURL = "http://illuminationgamestudio.com"
//    static let ACCESSTOKEN = "access_token"
//    static let SCOPE = "likes+comments+relationships"
    
    static let adMobAppID = "ca-app-pub-5866367507207379~5316046646"
    static let rewardedAdID = "ca-app-pub-5866367507207379/6245984935"
    static let rewardedAdTestID = "ca-app-pub-3940256099942544/1712485313"
//    static let interstitialAdID = "ca-app-pub-4840363647629056/3778239314"
//    static let interstitialTestVideoID = "ca-app-pub-3940256099942544/5135589807"
    
    static let gcLeaderboardHighLevel = "AR_SPORTS_MULTIPLAYER_LEADERBOARD_HIGHLEVEL"
    static let gcLeaderboardBF = "AR_SPORTS_MULTIPLAYER_LEADERBOARD_BASKETBALL_FREE"
    static let gcLeaderboardBT = "AR_SPORTS_MULTIPLAYER_LEADERBOARD_BASKETBALL_TIME"
    static let gcLeaderboardBB = "AR_SPORTS_MULTIPLAYER_LEADERBOARD_BASKETBALL_BALL"
    static let gcLeaderboardPong = "AR_SPORTS_MULTIPLAYER_LEADERBOARD_PONG"
    static let gcLeaderBoardWin = "AR_SPORTS_MULTIPLAYER_LEADERBOARD_WINTIMES"
    
    static let gcLeaderAchievementBuyThemAll = "AR_SPORTS_MULTIPLAYER_ACHIEVEMENT_BUYEVERYTHING"
    static let gcLeaderAchievementBuyGoldenBall = "AR_SPORTS_MULTIPLAYER_ACHIEVEMENT_BUYGOLDENBALL"
    
    static var experienceForLevel:[Int:Int]{
        get{
            var result = [Int:Int]()
            for level in 1...100{
                if level > 90{
                    result[level] = 10 + Int(level*10)
                }else if level > 80{
                    result[level] = 10 + Int(level*6)
                }else if level > 70{
                    result[level] = 10 + Int(level*4)
                }else if level > 60{
                    result[level] = 10 + Int(Double(level)*3)
                }else if level > 50{
                    result[level] = 10 + Int(level*2)
                }else if level > 40{
                    result[level] = 10 + Int(Double(level)*1.5)
                }else if level > 30{
                    result[level] = 10 + Int(Double(level)*1.4)
                }else if level > 20{
                    result[level] = 10 + Int(Double(level)*1.3)
                }else if level > 10{
                    result[level] = 10 + Int(Double(level)*1.2)
                }else{
                    result[level] = 10 + level
                }
            }
            return result
        }
    }
}
