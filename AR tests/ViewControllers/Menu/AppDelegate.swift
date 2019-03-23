//
//  AppDelegate.swift
//  AR tests
//
//  Created by Yu Wang on 1/7/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseUI
import FirebaseMessaging
import GameKit
import UserNotifications
//import VungleAdapter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{
    
    var window: UIWindow?
    
    var lastOpenDay = 0
    
    let standard = UserDefaults.standard
    
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //admob
        GADMobileAds.sharedInstance().start(completionHandler: { status in
//            let adapterState: GADAdapterInitializationState = status.adapterStatusesByClassName["GADMediationAdapterUnity","GADMAdapterChartboost","GADMediationAdapterIronSource"]!.state
//
//            if adapterState == GADAdapterInitializationState.ready {
//                // Sample adapter was successfully initialized.
//            } else {
//                // Sample adapter is not ready.
//            }
        })
        
        //game center
        gamecenterSetUp()
        
        //notification
        handleUserNotification()
        
        //firebase messaging
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        
        //firebase
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        let date = Date()
        let calendar = Calendar.current
        let today = calendar.component(.day, from: date)
        
        lastOpenDay = standard.integer(forKey: "lastOpenDay")
        
        encoder.outputFormat = .binary
        window = UIWindow(frame: UIScreen.main.bounds)
        if let data = standard.data(forKey: Constants.userDefaultSavingKeyForGameController),let gameController = try? decoder.decode(RootGameController.self, from: data){
            if lastOpenDay < today{
                gameController.missionToday[1].isCompleted = false
                lastOpenDay = today
            }
            window?.rootViewController = MenuViewController(gameController: gameController)
        }else{
            lastOpenDay = today
            window?.rootViewController = MenuViewController(gameController: RootGameController(wantDefault: true))
        }
        
        window?.makeKeyAndVisible()
        //check if need update
        checkUpdate()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) != nil {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func checkUpdate(){
        Database.database().reference().child("Events").child("Update").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                if let isMandatory = dictionary["isMandatory"] as? Int,let title = dictionary["title"] as? String,let url = dictionary["url"] as? String,let version = dictionary["version"] as? String{
                    if let selfVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,version != selfVersion{
                        if isMandatory == 0{
                            self.window?.rootViewController?.showAlert(title: "Update Available", message: title, buttonTitle: "Update", showCancel: false, buttonHandler: { (_) in
                                if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            })
                        }else if isMandatory == 1{
                            self.window?.rootViewController?.showAlert(title: "Update Available", message: title, buttonTitle: "Update", showCancel: true, buttonHandler: { (_) in
                                if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        storeGameController()
    }
    
    func storeGameController(){
        standard.set(lastOpenDay, forKey: "lastOpenDay")
        if let vc = window?.rootViewController as? MenuViewController{
            guard let data = try? encoder.encode(vc.gameController)
                else{fatalError("can't encode to PropertyList")}
            standard.set(data, forKey: Constants.userDefaultSavingKeyForGameController)
            saveToGameCenter(scoreToSend: vc.gameController.level, id: Constants.gcLeaderboardHighLevel)
            saveToGameCenter(scoreToSend: vc.gameController.highScores[GameToPresentOptions.basketballFree]!, id: Constants.gcLeaderboardBF)
            saveToGameCenter(scoreToSend: vc.gameController.highScores[GameToPresentOptions.basketballTimeLimited]!, id: Constants.gcLeaderboardBT)
            saveToGameCenter(scoreToSend: vc.gameController.highScores[GameToPresentOptions.basketballBallLimited]!, id: Constants.gcLeaderboardBB)
            saveToGameCenter(scoreToSend: vc.gameController.highScores[GameToPresentOptions.pong]!, id: Constants.gcLeaderboardPong)
        }
    }
    
    func gamecenterSetUp(){
        let gamecenterPlayer = GKLocalPlayer.local
        
        gamecenterPlayer.authenticateHandler = { [weak self] (vc, error) in
            if error == nil && vc != nil{
                self?.window?.rootViewController?.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    func saveToGameCenter(scoreToSend: Int, id: String){
        if GKLocalPlayer.local.isAuthenticated{
            let score = GKScore(leaderboardIdentifier: id)
            score.value = Int64(scoreToSend)
            GKScore.report([score], withCompletionHandler: nil)
        }
    }
    
    private func handleUserNotification(){
        var isGranted = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.badge,.alert]) { (granted, error) in
            isGranted = granted
        }
        if isGranted{
            let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(timeZone: NSTimeZone.local, hour: 13), repeats: true)
            
            let randomNumber = Int.random(in: 0...2)
            
            let content = UNMutableNotificationContent()
            
            switch randomNumber{
            case 0:
                content.title = "Check The New Effects"
            case 1:
                content.title = "Don't Know What To Do With Friends?"
            default:
                content.title = "Want to do some sports now?"
                content.body = "Playing sports in augmented reality!"
            }
            
            let request = UNNotificationRequest(identifier: "dailyRequest", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                return
            }
        }
        
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        storeGameController()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        storeGameController()
    }


}

