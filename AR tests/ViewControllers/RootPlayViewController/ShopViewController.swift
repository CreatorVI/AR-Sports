//
//  ShopViewController.swift
//  AR tests
//
//  Created by Yu Wang on 2/9/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import GoogleMobileAds
import StoreKit
import GameKit
import Firebase
import JGProgressHUD
import VungleAdapter

class ShopViewController: UIViewController,ARSCNViewDelegate,IAPServiceDelegate {

    unowned var gameController:RootGameController
    
    var iapService = IAPService()
    
    init(gameController:RootGameController){
        self.gameController = gameController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var sceneView:ARSCNView = ARSCNView()
    
    var rewardBasedAd:GADRewardedAd?
//    var interstitial: GADInterstitial!
    var rewardBasedAdID = Constants.rewardedAdID
    
    weak var menuViewController:MenuViewController?
    
    var backButton = CustomBackButton(image: #imageLiteral(resourceName: "goBack"))
    
    var middleNoticeLabel:UILabel = {
        let lable = UILabel()
        lable.font = getFont(withSize: 42)
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.textAlignment = .center
        lable.numberOfLines = 0
        lable.preferredMaxLayoutWidth = 300
        lable.adjustsFontForContentSizeCategory = true
        lable.textColor = UIColor.orange
        lable.sizeToFit()
        return lable
    }()
    
    var gemLabelView:UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var gemIcon:UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "gems")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var gemLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 26)
        gemLabel.textColor = UIColor.purple
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    var buyGemsButton:UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "25304")
        
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var isFirstLoad = true
    
    var gems:Int = 0{
        didSet{
            if !isFirstLoad{
                let addedGems = gems - gameController.gems
                if addedGems > 0{
                    customAlertView = BluredShadowView(title: "You Got \(addedGems) Gems!", message: "", buttonTitle: "OK", showCancel: true, buttonHandler: { [unowned self] in
                        self.movableGemLabel.text = String(addedGems)
                        self.movableGemLabel.alpha = 1
                        self.view.layoutIfNeeded()
                        self.movableGemLabelLeftAnchor?.constant = self.sceneView.frame.width/2 - 112
                        self.movableGemLabelTopAnchor?.constant = -(self.sceneView.frame.height/2 - 10)
                        
                        UIView.animate(withDuration: 2, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                            self.view.layoutIfNeeded()
                            }, completion: { (_) in
                                self.gemNumberNode.string = String(self.gems)
                                self.gemLabel.text = String(self.gems)
                                
                                self.movableGemLabelLeftAnchor?.constant = 8
                                self.movableGemLabelTopAnchor?.constant = -60
                                self.movableGemLabel.alpha = 0
                        })
                    })
                    
                    view.addSubview(customAlertView)
                    customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    gameController.gems = gems
                }else{
                    self.gemNumberNode.string = String(self.gems)
                    self.gemLabel.text = String(self.gems)
                    gameController.gems = gems
                }
            }else{
                isFirstLoad = false
                self.gemNumberNode.string = String(self.gems)
                self.gemLabel.text = String(self.gems)
            }
        }
    }
    
    var movableGemLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 26)
        gemLabel.textColor = UIColor.purple
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    var movableGemLabelTopAnchor:NSLayoutConstraint?
    var movableGemLabelLeftAnchor:NSLayoutConstraint?
    
    var gemNumberNode = SCNText()
    var basicBall = SCNNode()
    var nbaBall = SCNNode()
    var goldenBall = SCNNode()
    var fireBall = SCNNode()
    var magicBall = SCNNode()
    var basicPong = SCNNode()
    var firePong = SCNNode()
    
//    var missionShareVideo = SCNNode()
//    var missionShareGame = SCNNode()
//    var missionPlayMore = SCNNode()
//    var missionWatchVideo = SCNNode()
//    var missionLogin = SCNNode()
//    var missionFollowMe = SCNNode()
//    var missionFollowGame = SCNNode()
    
    var customAlertView = BluredShadowView()
    
    var gadRequest:GADRequest = {
        let request = GADRequest()
        let extras = VungleAdNetworkExtras()
        
        let placements = ["GET_GEMS-6844962", "DEFAULT-4343533"]
        extras.allPlacements = placements
        request.register(extras)
        return request
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUPSceneView()
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        //ad
        rewardBasedAd = createAndLoadRewardedAd()
//        interstitial = createAndLoadInterstitial()
        //all ui setup
        UISetup()
        setUPMiddleLabel()
        setUpIAPService()
        
        gems = gameController.gems
        animateMiddleText("Look Around",duration: 4)
//        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSceneViewTap(recog:))))
    }
    
    func createAndLoadRewardedAd() -> GADRewardedAd? {
        let rewardedAd = GADRewardedAd(adUnitID: rewardBasedAdID)
        rewardedAd.load(gadRequest, completionHandler: { error in
            if error != nil {
                
            } else {
                // Ad successfully loaded.
            }
        })
        return rewardedAd
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc func handleSceneViewTap(recog:UITapGestureRecognizer){
        if recog.state == .began{
            customAlertView.removeFromSuperview()
        }
    }
    
//    func createAndLoadInterstitial() -> GADInterstitial {
//        let interstitial = GADInterstitial(adUnitID: Constants.interstitialTestVideoID)
//        interstitial.delegate = self
//        let request = GADRequest()
//
//        request.testDevices = ["ec4912a80ff7b7c9bc94996b3ce5e3eb"]
//        interstitial.load(request)
//        return interstitial
//    }
    func purchasing(service: IAPService) {
        hud.textLabel.text = "Purchasing"
        hud.show(in: self.sceneView)
    }
    
    let hud = JGProgressHUD(style: .light)
    
    
    func purchaseSuccess(service: IAPService, product: SKProduct) {
        hud.dismiss(afterDelay: 0, animated: true)
        var message = ""
        switch product.productIdentifier {
        case IAPProduct.newUserGift.rawValue:
            self.gems += 20
            gameController.rawGems += 20
            message = "You Have Successfully Purchased The Gift Gems"
            self.gameController.hasPurchasedNewUserGift = true
        case IAPProduct.pocketOfGems.rawValue:
            self.gems += 25
            gameController.rawGems += 25
            message = "You Have Successfully Purchased A Pocket Of Gems"
        case IAPProduct.bagOfGems.rawValue:
            self.gems += 150
            gameController.rawGems += 150
            message = "You Have Successfully Purchased A Bag Of Gems"
        case IAPProduct.limitedTimeGem.rawValue:
            self.gems += 80
            gameController.rawGems += 80
            message = "You Have Successfully Purchased 80 Gems"
        case IAPProduct.weatherPack.rawValue:
            self.gameController.ownedItems.append(AllItemsAndMissions.allItems[5])
            self.gameController.ownedItems.append(AllItemsAndMissions.allItems[6])
            self.gameController.unownedItems.removeAll(where: { (item) -> Bool in
                item == AllItemsAndMissions.allItems[5] || item == AllItemsAndMissions.allItems[6]
            })
            message = "You Have Bought The Weather Pack Containing The Galaxy And Rain\n\n Try It Now"
            gameController.rawGems += 200
            self.gameController.hasPurchasedWeatherPack = true
        default:
            break
        }
        self.customAlertView = BluredShadowView(title: "Thank You", message: message, buttonTitle: "Done", showCancel: true, buttonHandler: {
            return
        })
        self.sceneView.addSubview(self.customAlertView)
        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func purchaseFailed(service: IAPService) {
        hud.dismiss()
        self.customAlertView = BluredShadowView(title: "Purchase Failed", message: "please try again later", buttonTitle: "OK", showCancel: false, buttonHandler: {
            return
        })
        self.sceneView.addSubview(self.customAlertView)
        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func restorePurchase(service: IAPService) {
        hud.textLabel.text = "Restoring"
        hud.show(in: self.sceneView)
    }
    
    func restoreCompleted(service:IAPService,message:String){
        if message == "no"{
            self.customAlertView = BluredShadowView(title: "Nothing To Restore", message: "", buttonTitle: "Done", showCancel: false, buttonHandler: {
                return
            })
            self.sceneView.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
        hud.dismiss()
    }
    
    func restoreFailed(service: IAPService) {
        hud.dismiss()
    }
    
    func setUpIAPService(){
        iapService.delegate = self
        iapService.getProduct()
    }

    func setUPSceneView(){
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ]
        )
        sceneView.scene = SCNScene(named: "Models.scnassets/shop/shop.scn")!

        self.getAllNodes()

        runActions()
    }
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }
    
    @objc func buyGems(){
        //
        if iapService.productsAvailable{
            var products = iapService.products
            if gameController.hasPurchasedWeatherPack{
                products = products.filter({ (product) -> Bool in
                    product.productIdentifier != IAPProduct.weatherPack.rawValue
                })
            }
            if gameController.hasPurchasedNewUserGift{
                products = products.filter({ (product) -> Bool in
                    product.productIdentifier != IAPProduct.newUserGift.rawValue
                })
            }
            customAlertView = BluredShadowView(
                products: products,
                buyAction: { (product) in
                let iapProduct = IAPProduct.all.filter { $0.rawValue == product.productIdentifier}.first
                    self.iapService.purchase(product: iapProduct!)
            }, restoreAction: {
                self.iapService.restorePurchases()
            })
        }else{
            customAlertView = BluredShadowView(title: "Internet Connection Error", message: "Please Try Again Later")
        }
        view.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func UISetup(){
        sceneView.addSubview(backButton)
        backButton.setConstraints()

        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
        transtitionWidgetButton(with: backButton, x: 100, y: 0, alpha: 1)
        
        sceneView.addSubview(gemLabelView)
        NSLayoutConstraint.activate([
            gemLabelView.topAnchor.constraint(equalTo: view.safeTopAnchor,constant:12),
            gemLabelView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            gemLabelView.heightAnchor.constraint(equalToConstant: 40),
            gemLabelView.widthAnchor.constraint(equalToConstant: 156),
            ]
        )
        
        gemLabelView.addSubview(gemIcon)
        NSLayoutConstraint.activate([
            gemIcon.topAnchor.constraint(equalTo: gemLabelView.topAnchor,constant: 0),
            gemIcon.leftAnchor.constraint(equalTo: gemLabelView.leftAnchor, constant: 0),
            gemIcon.heightAnchor.constraint(equalToConstant: 40),
            gemIcon.widthAnchor.constraint(equalToConstant: 40),
            ]
        )
        
        gemLabelView.addSubview(gemLabel)
        NSLayoutConstraint.activate([
            gemLabel.centerYAnchor.constraint(equalTo: gemLabelView.centerYAnchor,constant: 0),
            gemLabel.leftAnchor.constraint(equalTo: gemIcon.rightAnchor, constant: 16),
            ]
        )
        
        gemLabelView.addSubview(buyGemsButton)
        NSLayoutConstraint.activate([
            buyGemsButton.topAnchor.constraint(equalTo: gemLabelView.topAnchor,constant: 0),
            buyGemsButton.rightAnchor.constraint(equalTo: gemLabelView.rightAnchor, constant: 0),
            buyGemsButton.heightAnchor.constraint(equalToConstant: 40),
            buyGemsButton.widthAnchor.constraint(equalToConstant: 40),
            ]
        )
        gemLabelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyGems)))
        
        sceneView.addSubview(movableGemLabel)
        movableGemLabelTopAnchor = movableGemLabel.topAnchor.constraint(equalTo: sceneView.centerYAnchor,constant: -60)
        movableGemLabelTopAnchor!.isActive = true
        movableGemLabelLeftAnchor = movableGemLabel.leftAnchor.constraint(equalTo: sceneView.centerXAnchor, constant: 8)
        movableGemLabelLeftAnchor!.isActive = true
        movableGemLabel.alpha = 0
    }
    
    func getAllNodes(){
        let root = sceneView.scene.rootNode.childNode(withName: "root", recursively: false)!
        self.gemNumberNode = root.childNode(withName: "gem", recursively: false)!.childNode(withName: "gemNumber", recursively: false)!.geometry as! SCNText
        self.gemNumberNode.string = String(gems)
        
        let basketballs = root.childNode(withName: "shop", recursively: false)!.childNode(withName: "basketballs", recursively: false)!
        self.basicBall = basketballs.childNode(withName: "basicBall", recursively: false)!
        self.nbaBall = basketballs.childNode(withName: "nbaBall", recursively: false)!
        self.goldenBall = basketballs.childNode(withName: "goldenBall", recursively: false)!
        
        let effects = root.childNode(withName: "shop", recursively: false)!.childNode(withName: "effects", recursively: false)!
        self.fireBall = effects.childNode(withName: "fire", recursively: false)!.childNode(withName: "fire", recursively: false)!
        self.magicBall = effects.childNode(withName: "magic", recursively: false)!.childNode(withName: "magic", recursively: false)!
        
        let pongs = root.childNode(withName: "shop", recursively: false)!.childNode(withName: "pong", recursively: false)!
        self.basicPong = pongs.childNode(withName: "basicPong", recursively: false)!
        self.firePong = pongs.childNode(withName: "pongFire", recursively: false)!
        
        let missions = root.childNode(withName: "missions", recursively: false)!
        if gameController.hasRatedApp {
            missions.childNode(withName: "rate", recursively: false)?.removeFromParentNode()
        }
    }
    
    private func runActions(){
        sceneView.scene.rootNode.childNode(withName: "root", recursively: false)!.childNode(withName: "gem", recursively: false)!.childNode(withName: "gem", recursively: false)!.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(5))))
        basicBall.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
        nbaBall.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
        goldenBall.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
        fireBall.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
        magicBall.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
        basicPong.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
        firePong.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentTouchLocation = touches.first?.location(in: sceneView), let node = sceneView.hitTest(currentTouchLocation, options: [SCNHitTestOption.firstFoundOnly : true]).first?.node else { return }
        
        var title = ""
        var message = ""
        var buttonText = ""
        var handler:(() -> Void)?
        if node.parent?.name == "missions"{
            let all = gameController.missionToday
            switch node.name {
            case "rate":
                title = all[7].title
                message = all[7].description
                buttonText = "Rate"
                handler = {
                    SKStoreReviewController.requestReview()
                    self.gameController.hasRatedApp = true
                    self.sceneView.scene.rootNode.childNode(withName: "root", recursively: false)!.childNode(withName: "missions", recursively: false)!.childNode(withName: "rate", recursively: false)?.removeFromParentNode()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                        self.gems += all[7].awards
                        self.gameController.rawGems += all[7].awards
                    })
                }
            case "shareVideo":
                title = all[0].title
                message = all[0].description
                buttonText = "GO"
                handler = { [unowned self] in
                    self.goBack()
                }
            case "shareGame":
                title = all[1].title
                
                if !all[1].isCompleted{
                    message = all[1].description
                    buttonText = "GO"
                    handler = { [unowned self] in
                        self.share()
                    }
                }else{
                    message = "You Have Completed This Mission"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }
            case "playMore":
                title = all[2].title
                message = all[2].description
                buttonText = "GO"
                handler = { [unowned self] in
                    self.goBack()
                }
            case "watchVideo":
                title = all[3].title
                message = all[3].description
                buttonText = "GO"
                handler = { [unowned self] in
                    if let ad = self.rewardBasedAd, ad.isReady{
                        DispatchQueue.main.async{
                            ad.present(fromRootViewController: self, delegate: self)
                        }
                    }else{
                        self.handleRewardBasedAdNotAvailable()
                    }
//                    if self.interstitial.isReady {
//                        self.interstitial.present(fromRootViewController: self)
//                    }
                }
            case "login":
                title = all[4].title
                if !gameController.hasLoggedInFirstTime{
                    message = all[4].description
                    buttonText = "GO"
                    handler = { [unowned self] in
                        self.present(UserInfoViewController(gameController: self.gameController), animated: true, completion: nil)
                    }
                }else{
                    message = "You Have Completed This Mission"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }
            case "followMe":
                title = all[5].title
                
                if !all[5].isCompleted{
                    message = all[5].description
                    buttonText = "GO"
                    handler = { [unowned self] in
                        self.openIns(with: "illuminat_or")
                    }
                }else{
                    message = "You Have Completed This Mission"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }
            case "followGame":
                title = all[6].title
                
                if !all[6].isCompleted{
                    message = all[6].description
                    buttonText = "GO"
                    handler = { [unowned self] in
                        self.openIns(with: "ar_sports_multiplayer")
                    }
                }else{
                    message = "You Have Completed This Mission"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }
            default:
                return
            }
        }else{
            let allShoppable = AllItemsAndMissions.allItems
            let allBasic = AllItemsAndMissions.basicItems
            let allConsumable = AllItemsAndMissions.allComsumableItems
            switch node.name{
            case "gem","gemNumber":
                title = "Here is your gems, you buy stuffs with it"
                message = "You can earn gems by complete the missions show on the left, or play some games and get rewards, or you can also buy gems"
                buttonText = "Buy Gems"
                handler = {
                    self.buyGems()
                }
            case "basicPong":
                dealWithShopItemSelection(item: allBasic[0], itemCategory: "p")
                return
            case "orangePong":
                dealWithShopItemSelection(item: allShoppable[8], itemCategory: "p")
                return
            case "basicBall":
                dealWithShopItemSelection(item: allBasic[1], itemCategory: "bb")
                return
            case "nbaBall":
                dealWithShopItemSelection(item: allShoppable[3], itemCategory: "bb")
                return
            case "goldenBall":
                dealWithShopItemSelection(item: allShoppable[1], itemCategory: "bb")
                return
            case "fire":
                dealWithShopItemSelection(item: allShoppable[0], itemCategory: "be")
                return
            case "magic":
                dealWithShopItemSelection(item: allShoppable[2], itemCategory: "be")
                return
            case "pongFire":
                dealWithShopItemSelection(item: allShoppable[4], itemCategory: "pe")
                return
            case "pongDragon","dragon":
                dealWithShopItemSelection(item: allShoppable[7], itemCategory: "pe")
                return
            case "rain":
                dealWithWeather(item: allShoppable[5])
                return
            case "noEffects":
                dealWithShopItemSelection(item: allBasic[3], itemCategory: "be")
                return
            case "star":
                dealWithWeather(item: allShoppable[6])
                return
            case "slowTime":
                buyConsumableItem(item: allConsumable[0])
                return
            case "love":
                buyConsumableItem(item: allConsumable[1])
                return
            case "whiteLight":
                buyConsumableItem(item: allConsumable[2])
                return
            case "manyLoves":
                buyConsumableItem(item: allConsumable[3])
                return
            case "angry":
                buyConsumableItem(item: allConsumable[4])
                return
            case "fireItem":
                buyConsumableItem(item: allConsumable[5])
                return
            default:
                return
            }
        }
        
        
        customAlertView = BluredShadowView(title: title, message: message, buttonTitle: buttonText, showCancel: true, buttonHandler: {
            handler!()
        })
        sceneView.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func buyConsumableItem(item:ShopItem){
        let title = "\(item.name.rawValue)\n\n\(item.description)"
        var handler:(() -> Void)?
        
        let message = "You Have \(gameController.consumableItems[item]!) \(item.name.rawValue) \nDo You Want To Buy More?"
        let buttonText = "BUY 3 MORE"
        handler = { [unowned self] in
            self.customAlertView = BluredShadowView(paymentOptions: item.price, buyWithGemsAction: { [unowned self] in
                if self.gameController.gems >= item.price[PaymentOptions.gems]!{
                    self.customAlertView = BluredShadowView(title: "Are You Sure To Buy", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: { [unowned self] in
                        self.gems -= item.price[PaymentOptions.gems]!
                        self.gameController.consumableItems[item] = self.gameController.consumableItems[item]! + 3
                        
                        self.customAlertView = BluredShadowView(title: "You Have Bought 3 \(item.name.rawValue)", message: "", buttonTitle: "Done", showCancel: false, buttonHandler: {
                            return
                        })
                        self.view.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    })
                    self.view.addSubview(self.customAlertView)
                    self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                }else{
                    self.customAlertView = BluredShadowView(title: "You Don't Have Enough Gems", message: "Go Get Some Gems By Playing More Games, Completing Missions or buying directly", buttonTitle: "Buy Gems", showCancel: true, buttonHandler: { [unowned self] in
                        if !self.gameController.hasPurchasedNewUserGift{
                            self.customAlertView = BluredShadowView(title: "You Can Get 20 Gems At A Every Low Price, It's Only For You At A Limited Time!", message: "Buy 20 Gems With Just A Buck!\n  1.5X Value!!!", buttonTitle: "Buy", showCancel: true, buttonHandler: {
                                self.iapService.purchase(product: IAPProduct.newUserGift)
                            })
                            self.view.addSubview(self.customAlertView)
                            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                        }else{
                            self.buyGems()
                        }
                    })
                    self.view.addSubview(self.customAlertView)
                    self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                }
                }, watchedVideos: self.gameController.watchedVideos[item]!, buyWithVideosAction: { [unowned self] in
                    if let ad = self.rewardBasedAd, ad.isReady{
                        self.rewardForSpecificItem = item
                        ad.present(fromRootViewController: self, delegate: self)
                    }else{
                        self.customAlertView.removeFromSuperview()
                        self.handleRewardBasedAdNotAvailable()
                    }
            })
            self.view.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
        customAlertView = BluredShadowView(title: title, message: message, buttonTitle: buttonText, showCancel: true, buttonHandler: {
            handler!()
        })
        view.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func dealWithWeather(item:ShopItem){
        let title = item.name.rawValue
        var message = ""
        var buttonText = ""
        var handler:(() -> Void)?
        
        if gameController.ownedItems.contains(item){
            if gameController.selectedItems.weather == item{
                message = "\(item.description)\n\n  SELECTED\n"
                buttonText = "OK"
                handler = {
                    return
                }
            }else{
                message = "\(item.description)\n\n  UNSELECTED\n"
                buttonText = "Select"
                handler = { [unowned self] in
                    self.gameController.selectedItems.weather = item
                }
            }
        }else{
            message = "\(item.description)\n\nYou haven't owned this cool item, you can buy it with multiple options"
            buttonText = "BUY IT"
            handler = { [unowned self] in
                self.customAlertView = BluredShadowView(paymentOptions: item.price, buyWithGemsAction: {
                    if self.gameController.gems >= item.price[PaymentOptions.gems]!{
                        self.customAlertView = BluredShadowView(title: "Are You Sure  To Buy With \(item.price[PaymentOptions.gems]!) Gems", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: { [unowned self] in
                            self.gems -= item.price[PaymentOptions.gems]!
                            self.gameController.ownedItems.append(item)
                            self.gameController.unownedItems.removeAll(where: { (item) -> Bool in
                                item == item
                            })
                            if item.name == ShopItemsName.basketballGoldSkin{
                                var achievements = [GKAchievement]()
                                let fullAchievement = GKAchievement(identifier: Constants.gcLeaderAchievementBuyGoldenBall)
                                fullAchievement.percentComplete = 100
                                fullAchievement.showsCompletionBanner = true
                                achievements.append(fullAchievement)
                                GKAchievement.report(achievements)
                            }
                            self.customAlertView = BluredShadowView(title: "You Have Bought \(item.name.rawValue)", message: "Try It Now", buttonTitle: "Done", showCancel: false, buttonHandler: {
                                self.dealWithWeather(item: item)
                            })
                            self.sceneView.addSubview(self.customAlertView)
                            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                        })
                        self.sceneView.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    }else{
                        self.customAlertView = BluredShadowView(title: "You Don't Have Enough Gems", message: "Go Get Some Gems By Playing More Games, Completing Missions or buying directly", buttonTitle: "Buy Gems", showCancel: true, buttonHandler: {
                            if !self.gameController.hasPurchasedNewUserGift{
                                self.customAlertView = BluredShadowView(title: "You Can Get 20 Gems At A Every Low Price, It's Only For You At A Limited Time!", message: "Buy 20 Gems With Just A Buck!\n  1.5X Value!!!", buttonTitle: "Buy", showCancel: true, buttonHandler: {
                                    self.iapService.purchase(product: IAPProduct.newUserGift)
                                })
                                self.sceneView.addSubview(self.customAlertView)
                                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                            }else{
                                self.buyGems()
                            }
                        })
                        self.sceneView.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    }
                })
                self.sceneView.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }
        }
        
        customAlertView = BluredShadowView(title: title, message: message, buttonTitle: buttonText, showCancel: true, buttonHandler: {
            handler!()
        })
        sceneView.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func dealWithShopItemSelection(item:ShopItem,itemCategory:String){
        var title = ""
        var message = ""
        var buttonText = ""
        var handler:(() -> Void)?
        
        
        
        title = item.name.rawValue
        
        if gameController.ownedItems.contains(item){
            switch itemCategory{
            case "bb":
                if gameController.selectedItems.basketBallSelection == item{
                    message = "\(item.description)\n\n  SELECTED\n"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }else{
                    message = "\(item.description)\n\n  UNSELECTED\n"
                    buttonText = "Select"
                    handler = { [unowned self] in
                        self.gameController.selectedItems.basketBallSelection = item
                    }
                }
            case "be":
                if gameController.selectedItems.basketBallEffect == item{
                    message = "\(item.description)\n\n  SELECTED\n"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }else{
                    message = "\(item.description)\n\n  UNSELECTED\n"
                    buttonText = "Select"
                    handler = { [unowned self] in
                        self.gameController.selectedItems.basketBallEffect = item
                    }
                }
            case "pe":
                if gameController.selectedItems.pongEffect == item{
                    message = "\(item.description)\n\n  SELECTED\n"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }else{
                    message = "\(item.description)\n\n  UNSELECTED\n"
                    buttonText = "Select"
                    handler = { [unowned self] in
                        self.gameController.selectedItems.pongEffect = item
                    }
                }
            case "p":
                if gameController.selectedItems.pongSelection == item{
                    message = "\(item.description)\n\n   Selected"
                    buttonText = "OK"
                    handler = {
                        return
                    }
                }else{
                    message = "\(item.description)\n\n   Unselected"
                    buttonText = "Select"
                    handler = { [unowned self] in
                        self.gameController.selectedItems.pongSelection = item
                    }
                }
            default:
                break
            }
        }else{
            message = "\(item.description)\n\nYou haven't owned this cool item, you can buy it with multiple options"
            buttonText = "BUY IT"
            handler = { [unowned self] in
                self.customAlertView = BluredShadowView(paymentOptions: item.price, buyWithGemsAction: {
                    if self.gameController.gems >= item.price[PaymentOptions.gems]!{
                        self.customAlertView = BluredShadowView(title: "Are You Sure  To Buy With \(item.price[PaymentOptions.gems]!) Gems", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: { [unowned self] in
                            self.gems -= item.price[PaymentOptions.gems]!
                            self.gameController.ownedItems.append(item)
                            self.gameController.unownedItems.removeAll(where: { (item) -> Bool in
                                item == item
                            })
                            self.customAlertView = BluredShadowView(title: "You Have Bought \(item.name.rawValue)", message: "Try It Now", buttonTitle: "Done", showCancel: false, buttonHandler: {
                                self.dealWithShopItemSelection(item:item,itemCategory:itemCategory)
                            })
                            self.sceneView.addSubview(self.customAlertView)
                            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                        })
                        self.sceneView.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    }else{
                        self.customAlertView = BluredShadowView(title: "You Don't Have Enough Gems", message: "Go Get Some Gems By Playing More Games, Completing Missions or buying directly", buttonTitle: "Buy Gems", showCancel: true, buttonHandler: {
                            if !self.gameController.hasPurchasedNewUserGift{
                                self.customAlertView = BluredShadowView(title: "You Can Get 20 Gems At A Every Low Price, It's Only For You At A Limited Time!", message: "Buy 20 Gems With Just A Buck!\n  1.5X Value!!!", buttonTitle: "Buy", showCancel: true, buttonHandler: {
                                    self.iapService.purchase(product: IAPProduct.newUserGift)
                                })
                                self.view.addSubview(self.customAlertView)
                                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                            }else{
                                self.buyGems()
                            }
                        })
                        self.sceneView.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    }
                },watchedVideos:self.gameController.watchedVideos[item]!,
                  buyWithVideosAction: { [unowned self] in
                    if let ad = self.rewardBasedAd, ad.isReady{
                        self.rewardForSpecificItem = item
                        ad.present(fromRootViewController: self, delegate: self)
                    }else{
                        self.customAlertView.removeFromSuperview()
                        self.handleRewardBasedAdNotAvailable()
                    }
                })
                self.sceneView.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }
        }
        
        customAlertView = BluredShadowView(title: title, message: message, buttonTitle: buttonText, showCancel: true, buttonHandler: {
            handler!()
        })
        sceneView.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    
    var rewardForSpecificItem:ShopItem?
    
    @objc func goBack(){
        menuViewController?.sceneView.session.run(ARWorldTrackingConfiguration())
        dismiss(animated: true)
    }

    
    @objc func openIns(with UserName:String) {
        
        let username = UserName
        let appURL = URL(string: "instagram://user?username=\(username)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            if username == "illuminat_or"{
                if !gameController.hasFollowedMe{
                    gameController.hasFollowedMe = true
                    gems += AllItemsAndMissions.allMissions[5].awards
                    self.gameController.rawGems += AllItemsAndMissions.allMissions[5].awards
                }
            }else{
                if !gameController.hasFollowedGame{
                    gameController.hasFollowedGame = true
                    gems += AllItemsAndMissions.allMissions[6].awards
                    self.gameController.rawGems += AllItemsAndMissions.allMissions[6].awards
                }
            }
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            self.customAlertView = BluredShadowView(title: "Instagram Not Installed", message: "Go get instagram and be a 2019 person", buttonTitle: "Download", showCancel: true, buttonHandler: {
                let vc = SKStoreProductViewController()
                vc.delegate = self
                let parameters = [SKStoreProductParameterITunesItemIdentifier: 389801252]
                
                vc.loadProduct(withParameters: parameters, completionBlock: { (status, error) in
                    if status{
                        self.present(vc, animated: true, completion: nil)
                    }else{
                        
                    }
                })
            })
            self.sceneView.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    @objc func share(){
        if Reachability.isConnectedToNetwork(){
            var firstActivityItem = "Check out this cool AR game"
            var link = URL(string: "https://testflight.apple.com/join/lJ7wzNde")!
            Database.database().reference().child("Events").child("Share").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                print(snapshot)
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    if let title = dictionary["title"] as? String{
                        firstActivityItem = title
                    }
                    if let fetchedLink = dictionary["link"] as? String{
                        link = URL(string: fetchedLink)!
                    }
                }
            }, withCancel: nil)
            
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem, link], applicationActivities: nil)
            
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [.addToReadingList,.assignToContact,.copyToPasteboard,.markupAsPDF,.openInIBooks,.saveToCameraRoll,.print]
            
            activityViewController.completionWithItemsHandler = { [unowned self] activity, success, items, error in
                if !success{
                    self.customAlertView = BluredShadowView(title: "Share Failed", message: "", buttonTitle: "Again", showCancel: true, buttonHandler: {
                        self.share()
                    })
                    
                    self.sceneView.addSubview(self.customAlertView)
                    self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                }else{
                    if !self.gameController.missionToday[1].isCompleted{
                        self.gems += AllItemsAndMissions.allMissions[1].awards
                        self.gameController.missionToday[1].isCompleted = true
                    }
                }
            }
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceView = self.sceneView
            }
            present(activityViewController, animated: true)
        }else{
            self.customAlertView = BluredShadowView(title: "Please Check Your Internet Connection And Try Again", message: "", buttonTitle: "Again", showCancel: true, buttonHandler: {
                self.share()
            })
            
            self.sceneView.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    func handleRewardBasedAdNotAvailable(){
        customAlertView = BluredShadowView(title: "Video Not Currently Available", message: "Please Check Your Internet Connection And Try Again Later", buttonTitle: "OK", showCancel: true, buttonHandler: {
            return
        })
        sceneView.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func setUPMiddleLabel(){
        sceneView.addSubview(middleNoticeLabel)
        NSLayoutConstraint.activate([
            middleNoticeLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            middleNoticeLabel.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor)
            ]
        )
        middleNoticeLabel.alpha = 0
    }
    
    func animateMiddleText(_ text:String,duration:Int = 6){
        middleNoticeLabel.text = text
        self.sceneView.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.middleNoticeLabel.alpha = 1
            }, completion: { (_) in
                UIView.animate(withDuration: TimeInterval(duration/2), delay: TimeInterval(duration/2), options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.middleNoticeLabel.alpha = 0
                }, completion: nil)
            })
        }
    }
    
    func showAlertIfARTrackingInterrupted(){
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            self.customAlertView = BluredShadowView(title: "If The Screen Stucks(AR Objects Don't Move), Go Back To Main Menu And Come Back Again, If Not, Just Cancel This.", message: "", buttonTitle: "Go Back", showCancel: true, buttonHandler: {
                self.menuViewController?.sceneView.session.run(ARWorldTrackingConfiguration(), options: [])
                self.dismiss(animated: true)
            })
            
            self.sceneView.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
}

extension ShopViewController:GADRewardedAdDelegate{
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        if let rewardForSpecificItem = rewardForSpecificItem{
            gameController.watchedVideos[rewardForSpecificItem] = (1 + gameController.watchedVideos[rewardForSpecificItem]!)
            self.rewardForSpecificItem = nil
            let videosLeft = (rewardForSpecificItem.price[PaymentOptions.watchingVideos]! - gameController.watchedVideos[rewardForSpecificItem]!)
            if videosLeft > 0{
                customAlertView = BluredShadowView(title: "Do You Want To Watch Again?", message: "\(videosLeft) times left to get \(rewardForSpecificItem.name.rawValue)", buttonTitle: "Watch", showCancel: true, buttonHandler: {
                    if let ad = self.rewardBasedAd, ad.isReady{
                        ad.present(fromRootViewController: self, delegate: self)
                    }else{
                        self.handleRewardBasedAdNotAvailable()
                    }
                })
                sceneView.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }else{
                if AllItemsAndMissions.allItems.contains(rewardForSpecificItem){
                    self.gameController.ownedItems.append(rewardForSpecificItem)
                    self.gameController.unownedItems.removeAll(where: { (item) -> Bool in
                        item == rewardForSpecificItem
                    })
                    self.gameController.watchedVideos[rewardForSpecificItem] = 0
                    self.gameController.rawGems += rewardForSpecificItem.price[PaymentOptions.gems]!
                    self.customAlertView = BluredShadowView(title: "You Have Got \(rewardForSpecificItem.name.rawValue)", message: "Try It Now", buttonTitle: "Done", showCancel: false, buttonHandler: {
                        return
                    })
                }else if AllItemsAndMissions.allComsumableItems.contains(rewardForSpecificItem){
                    gameController.watchedVideos[rewardForSpecificItem] = 0
                    gameController.consumableItems[rewardForSpecificItem] = gameController.consumableItems[rewardForSpecificItem]! + 3
                    self.customAlertView = BluredShadowView(title: "You Got 3 \(rewardForSpecificItem.name.rawValue)s", message: "Try It Now", buttonTitle: "Done", showCancel: false, buttonHandler: {
                        return
                    })
                }
                self.sceneView.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }
        }else{
            self.gems += 1
            self.gameController.rawGems += 1
            self.customAlertView = BluredShadowView(title: "Do You Want To Watch Again?", message: "", buttonTitle: "Watch", showCancel: true, buttonHandler: {
                if let ad = self.rewardBasedAd, ad.isReady{
                    ad.present(fromRootViewController: self, delegate: self)
                }else{
                    self.handleRewardBasedAdNotAvailable()
                }
            })
            self.sceneView.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        rewardBasedAd = createAndLoadRewardedAd()
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            self.showAlertIfARTrackingInterrupted()
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        rewardBasedAd = createAndLoadRewardedAd()
        print(error.localizedDescription)
    }
}



extension ShopViewController:SKStoreProductViewControllerDelegate{
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
