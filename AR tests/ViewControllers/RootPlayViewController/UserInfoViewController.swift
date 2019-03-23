//
//  UserInfoViewController.swift
//  AR tests
//
//  Created by Yu Wang on 2/20/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import FirebaseUI
import GameKit
import GoogleMobileAds
import StoreKit
import JGProgressHUD
import Firebase
import VungleAdapter

class UserInfoViewController: UIViewController, FUIAuthDelegate, GKGameCenterControllerDelegate, UIGestureRecognizerDelegate,IAPServiceDelegate {
    
    override var shouldAutorotate: Bool{
        get{
            return false
        }
    }
    
    var isUserLoggedIn:Bool = false{
        didSet{
            gameController.hasLoggedIn = isUserLoggedIn
            if isUserLoggedIn{
                loginNoticeLabel.text = ""
            }else{
                loginNoticeLabel.text = "You haven't logged in"
            }
        }
    }
    
    unowned var gameController:RootGameController
    
    init(gameController:RootGameController){
        self.gameController = gameController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var menuViewController:MenuViewController?
    
    var iapService = IAPService()
    
    var rewardBasedAd:GADRewardedAd?
    
    
    var rewardBasedAdID = Constants.rewardedAdID
    
    lazy var loginNoticeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 20)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = view.frame.width - 64
        label.sizeToFit()
        return label
    }()
    
    lazy var mainScrollView:SmartScrollView = {
        let view = SmartScrollView()
        view.frame = self.view.frame
        view.contentSize = CGSize(width: view.frame.width, height: 2400)
        view.backgroundColor = UIColor.clear
        view.alwaysBounceVertical = false
        view.showsVerticalScrollIndicator = false
        return view
    }()

    
    var profileImageView:UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "user"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.cornerRadius = 60
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var loginButton:UIImageView = {
        let button = UIImageView()
        button.image = #imageLiteral(resourceName: "login")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.contentMode = .scaleAspectFill
        button.isUserInteractionEnabled = true
        return button
    }()
    
    var name:String = ""{
        didSet{
            nameLabel.text = "Name: \(self.name)"
        }
    }
    
    var level:Int = 1{
        didSet{
            levelLabel.text = "Level: \(self.level)"
        }
    }
    
    var experience:Int = 0{
        didSet{
            experienceLabel.text = "Experience: \(self.experience)"
        }
    }
    
    //MARK: ALl labels
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Name:"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    var levelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Level"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    var rankButtonForLevel:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "rank"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(showLeaderBoard), for: .touchUpInside)
        return button
    }()
    
    var experienceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Experience"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    //MARK: high scores section
    var line:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var highScoresLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 28)
        label.text = "High Scores"
        label.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    var rankButtonForHighScores:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "rank"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(showLeaderBoard), for: .touchUpInside)
        return button
    }()
    
    var basketballLabel: UIImageView = {
       let view = UIImageView(image: #imageLiteral(resourceName: "basketball-3"))
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var basketballFreeModeScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Free Mode: \(gameController.highScores[GameToPresentOptions.basketballFree]!)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var timeModeScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Time Mode: \(gameController.highScores[GameToPresentOptions.basketballTimeLimited]!)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var ballModeScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Ball Mode: \(gameController.highScores[GameToPresentOptions.basketballBallLimited]!)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    var pongLabel: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "ping-pong"))
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var pingpongFreeModeScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Free Mode: \(gameController.highScores[GameToPresentOptions.pong]!)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    var archeryLabel: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "bow"))
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var archeryFreeModeScoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Free Mode: \(gameController.highScores[GameToPresentOptions.archery]!)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    //MARK: Multiplayer section
    var lineForMultiplayer:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var multiplayerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 28)
        label.text = "Multiplayer"
        label.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    var rankButtonForMultiplayer:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "rank"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(showLeaderBoard), for: .touchUpInside)
        return button
    }()
    
    lazy var winTimesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Total Wins: \(gameController.winTimes)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var loseTimesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Total Loses: \(gameController.loseTimes)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var drawTimesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 24)
        label.text = "Total Draws: \(gameController.drawTimes)"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    
    //MARK: Shop
    var lineForShop:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewInARLabel:NoticePaddingLabel = {
        let label = NoticePaddingLabel()
        label.bottomInset = 6
        label.topInset = 6
        label.leftInset = 6
        label.rightInset = 6
        label.font = getFont(withSize: 18)
        label.text = "Shop In AR"
        
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        return label
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
    
    var watchVideoButton:UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "watchVideo")
        
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    //MARK: shop items
    var basketballItemsLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 22)
        gemLabel.text = "Basketballs"
        gemLabel.textColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    lazy var basketballStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [basicBall,nbaBall,goldenBall])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        return stack
    }()
    
    var basicBall = BluredShadowView(image: #imageLiteral(resourceName: "basketballBasic"), corner: 40, imageMultplier: 0.9)
    
    var nbaBall = BluredShadowView(image: #imageLiteral(resourceName: "basketballNBA"), corner: 40, imageMultplier: 0.9)
    
    var goldenBall = BluredShadowView(image: #imageLiteral(resourceName: "basketballGold"), corner: 40, imageMultplier: 0.9)
    
    //effects
    var basketballEffectsLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 22)
        gemLabel.text = "Basketball Effects"
        gemLabel.textColor = UIColor.blue
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    lazy var basketballEffectsStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noEffectBall,fireBall,magicBall])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        return stack
    }()
    
    var noEffectBall = BluredShadowView(image: #imageLiteral(resourceName: "no"), corner: 40, imageMultplier: 0.8)
    
    var fireBall = BluredShadowView(image: #imageLiteral(resourceName: "basketballFire"), corner: 40, imageMultplier: 0.8)
    
    var magicBall = BluredShadowView(image: #imageLiteral(resourceName: "basketballMagic"), corner: 40, imageMultplier: 0.8)
    
    
    //pong
    var pongballLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 22)
        gemLabel.text = "Table Tennis Balls"
        gemLabel.textColor = #colorLiteral(red: 0.1185673964, green: 0.5311310279, blue: 0.1033556676, alpha: 1)
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    lazy var pongballStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [basicPong,orangePong])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        return stack
    }()
    
    var basicPong = BluredShadowView(image: #imageLiteral(resourceName: "pongBasic"), corner: 40, imageMultplier: 0.5)

    var orangePong = BluredShadowView(image: #imageLiteral(resourceName: "orange"), corner: 40, imageMultplier: 0.5)
    
    //pong effect
    var pongballEffectsLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 22)
        gemLabel.text = "Table Tennis Ball Effects"
        gemLabel.textColor = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    lazy var pongballEffectsStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noEffectPong,lavaPong,firePong])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        return stack
    }()
    
    var noEffectPong = BluredShadowView(image: #imageLiteral(resourceName: "no"), corner: 40, imageMultplier: 0.8)
    
    var lavaPong = BluredShadowView(image: #imageLiteral(resourceName: "pongLava"), corner: 40, imageMultplier: 0.5)
    
    var firePong = BluredShadowView(image: #imageLiteral(resourceName: "pongFire"), corner: 40, imageMultplier: 0.8)
    
    lazy var pongballEffectsSecondStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dragonPong])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        return stack
    }()
    
    var dragonPong = BluredShadowView(image: #imageLiteral(resourceName: "dragon"), corner: 40, imageMultplier: 0.9)

    //weather
    var weatherLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 22)
        gemLabel.text = "Weather"
        gemLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    lazy var weatherStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noWeather,rain,star])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        return stack
    }()
    
    var noWeather = BluredShadowView(image: #imageLiteral(resourceName: "sun"), corner: 40, imageMultplier: 0.8)
    
    var rain = BluredShadowView(image: #imageLiteral(resourceName: "rain"), corner: 40, imageMultplier: 0.8)
    
    var star = BluredShadowView(image: #imageLiteral(resourceName: "galaxy"), corner: 40, imageMultplier: 0.8)
    
    
    
    
    
    //consumable items
    var consumableItemsLabel:UILabel = {
        let gemLabel = UILabel()
        gemLabel.translatesAutoresizingMaskIntoConstraints = false
        gemLabel.font = getFont(withSize: 22)
        gemLabel.text = "Special Items"
        gemLabel.textColor = #colorLiteral(red: 1, green: 0.09473012359, blue: 0.04896101969, alpha: 1)
        gemLabel.adjustsFontForContentSizeCategory = true
        gemLabel.numberOfLines = 1
        gemLabel.isUserInteractionEnabled = false
        return gemLabel
    }()
    
    var consumableItemsCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    
    @objc func buyGems(){
        //
        if iapService.productsAvailable {
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
    
    @objc func watchVideo(){
        if let ad = self.rewardBasedAd, ad.isReady{
            ad.present(fromRootViewController: self, delegate: self)
        }else{
            customAlertView = BluredShadowView(title: "Video Currently Not Available", message: "Please try again later", buttonTitle: "OK", showCancel: true, buttonHandler: {
                return
            }
            )
            view.addSubview(customAlertView)
            customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    var isFirstLoad = true
    
    var gems:Int = 0{
        didSet{
            if !isFirstLoad{
                let addedGems = gems - gameController.gems
                if addedGems > 0{
                    self.gemLabel.text = String(self.gems)
                    customAlertView = BluredShadowView(title: "You Got \(addedGems) Gems!", message: "Go Shopping With The Gems", buttonTitle: "OK", showCancel: true, buttonHandler: {
                        return
                    }
                    )
                    view.addSubview(customAlertView)
                    customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    gameController.gems = gems
                }else{
                    self.gemLabel.text = String(self.gems)
                    gameController.gems = gems
                }
            }else{
                self.gemLabel.text = String(self.gems)
                isFirstLoad = false
            }
            encoder.outputFormat = .binary
            guard let data = try? encoder.encode(gameController)
                else{fatalError("can't encode to PropertyList")}
            UserDefaults.standard.set(data, forKey: "new game controller 999999999")
        }
    }

    let encoder = PropertyListEncoder()
    
    var logoutButton = BluredShadowView(title: "Log Out", image: #imageLiteral(resourceName: "logout"))
    
    
    var backButton:UIButton = {
       let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Go Back", for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        return button
    }()
    
    let authUI = FUIAuth.defaultAuthUI()
    
    var customAlertView = BluredShadowView()
    
    var gadRequest:GADRequest = {
        let request = GADRequest()
        let extras = VungleAdNetworkExtras()
        
        let placements = ["GET_GEMS-6844962", "DEFAULT-4343533"]
        extras.allPlacements = placements
        request.register(extras)
        return request
    }()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        //ad
        rewardBasedAd = createAndLoadRewardedAd()
        //firebase ui
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(),
            FUIGoogleAuth(),
            FUIFacebookAuth(),
        ]
        authUI?.providers = providers
        view.backgroundColor = #colorLiteral(red: 0.9991907477, green: 0.7645849771, blue: 0.374939957, alpha: 1)
        setUp()
        sendScoreToFirebase()
        gamecenterSetUp()
        setUpIAPService()
        if !gameController.hasLoggedInFirstTime{
            showAlert(title: "Login To Save Infomation", message: "Your info such as level and gems will be stored online so won't lose these data even if you haved deleted the game", buttonTitle: "Login", showCancel: true) { (_) in
                self.login()
            }
        }
        fetchEvents()
    }
    
    func fetchEvents(){
        Database.database().reference().child("Events").child("Gems").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                if let available = dictionary["available"] as? Int,let gems = dictionary["gems"] as? Int,let title = dictionary["title"] as? String,let id = dictionary["id"] as? Int{
                    if available == 1 && self.gameController.getGemsID != id{
                        self.customAlertView = BluredShadowView(title: title, message: "You get \(gems) gems", buttonTitle: "Get!", showCancel: false, buttonHandler: {
                            self.gems+=gems
                            self.gameController.rawGems+=gems
                            self.gameController.getGemsID = id
                        })
                        self.view.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    }
                }
            }
        })
    }
    
    func purchasing(service: IAPService) {
        hud.textLabel.text = "Purchasing"
        hud.show(in: self.view)
    }
    
    let hud = JGProgressHUD(style: .light)
    
    
    func purchaseSuccess(service: IAPService, product: SKProduct) {
        hud.dismiss(afterDelay: 0, animated: true)
        var message = ""
        switch product.productIdentifier {
        case IAPProduct.newUserGift.rawValue:
            self.gems += 20
            self.gameController.rawGems += 20
            message = "You Have Successfully Purchased The Gift Gems"
            self.gameController.hasPurchasedNewUserGift = true
        case IAPProduct.pocketOfGems.rawValue:
            self.gems += 25
            self.gameController.rawGems += 25
            message = "You Have Successfully Purchased A Pocket Of Gems"
        case IAPProduct.bagOfGems.rawValue:
            self.gems += 150
            self.gameController.rawGems += 150
            message = "You Have Successfully Purchased A Bag Of Gems"
        case IAPProduct.limitedTimeGem.rawValue:
            self.gems += 80
            self.gameController.rawGems += 80
            message = "You Have Successfully Purchased 80 Gems"
        case IAPProduct.weatherPack.rawValue:
            self.gameController.ownedItems.append(AllItemsAndMissions.allItems[5])
            self.gameController.ownedItems.append(AllItemsAndMissions.allItems[6])
            self.gameController.unownedItems.removeAll(where: { (item) -> Bool in
                item == AllItemsAndMissions.allItems[5] || item == AllItemsAndMissions.allItems[6]
            })
            self.gameController.rawGems += 200
            message = "You Have Bought The Weather Pack Containing The Galaxy And Rain\n\n Try It Now"
            self.gameController.hasPurchasedWeatherPack = true
        default:
            break
        }
        self.customAlertView = BluredShadowView(title: "Thank You", message: message, buttonTitle: "Done", showCancel: true, buttonHandler: {
            return
        })
        self.view.addSubview(self.customAlertView)
        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func purchaseFailed(service: IAPService) {
        hud.dismiss()
        self.customAlertView = BluredShadowView(title: "Purchase Failed", message: "please try again later", buttonTitle: "OK", showCancel: false, buttonHandler: {
            return
        })
        self.view.addSubview(self.customAlertView)
        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    func restorePurchase(service: IAPService) {
        hud.textLabel.text = "Restoring"
        hud.show(in: self.view)
    }
    
    func restoreFailed(service: IAPService) {
        hud.dismiss()
    }
    
    func restoreCompleted(service:IAPService,message:String){
        if message == "no"{
            self.customAlertView = BluredShadowView(title: "Nothing To Restore", message: "", buttonTitle: "Done", showCancel: false, buttonHandler: {
                return
            })
            self.view.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
        hud.dismiss()
    }
    
    func setUpIAPService(){
        iapService.delegate = self
        iapService.getProduct()
    }
    
    func sendScoreToFirebase(){
        if Auth.auth().currentUser != nil{
            DispatchQueue.global(qos: .userInitiated).async{ [unowned self] in
                let userDataRef = Database.database().reference().child("USERDATA").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                var values = [String:AnyObject]()
                values["gems"] = self.gameController.gems as AnyObject
                userDataRef.updateChildValues(values)
                
                let databaseRef = Database.database().reference().child("HIGHSCORES")
                let levelRef = databaseRef.child("Level").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["level"] = self.gameController.level as AnyObject
                values["name"] = self.name as AnyObject
                levelRef.updateChildValues(values)
                
                let bfRef = databaseRef.child("Basketball Free Mode").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["score"] = self.gameController.highScores[GameToPresentOptions.basketballFree] as AnyObject
                values["name"] = self.name as AnyObject
                bfRef.updateChildValues(values)
                
                let btRef = databaseRef.child("Basketball Time Mode").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["score"] = self.gameController.highScores[GameToPresentOptions.basketballTimeLimited] as AnyObject
                values["name"] = self.name as AnyObject
                btRef.updateChildValues(values)
                
                let bbRef = databaseRef.child("Basketball Ball Mode").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["score"] = self.gameController.highScores[GameToPresentOptions.basketballBallLimited] as AnyObject
                values["name"] = self.name as AnyObject
                bbRef.updateChildValues(values)
                
                let pongRef = databaseRef.child("Pong").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["score"] = self.gameController.highScores[GameToPresentOptions.pong] as AnyObject
                values["name"] = self.name as AnyObject
                pongRef.updateChildValues(values)
                
                let winRef = databaseRef.child("WinTimes").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["score"] = self.gameController.winTimes as AnyObject
                values["name"] = self.name as AnyObject
                winRef.updateChildValues(values)
                
                //play times
                let playTimesDatabaseRef = Database.database().reference().child("PLAYTIMES")
                let basketballFreeRef = playTimesDatabaseRef.child("BasketballFree").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["times"] = self.gameController.timesOfPlayingGameNotTutorial[GameToPresentOptions.basketballFree] as AnyObject
                basketballFreeRef.updateChildValues(values)
                
                let basketballBallLimitedRef = playTimesDatabaseRef.child("BasketballBallLimited").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["times"] = self.gameController.timesOfPlayingGameNotTutorial[GameToPresentOptions.basketballBallLimited] as AnyObject
                basketballBallLimitedRef.updateChildValues(values)
                
                let basketballTimeLimitedRef = playTimesDatabaseRef.child("BasketballTimeLimited").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["times"] = self.gameController.timesOfPlayingGameNotTutorial[GameToPresentOptions.basketballTimeLimited] as AnyObject
                basketballTimeLimitedRef.updateChildValues(values)
                
                let pongSinglePlayerRef = playTimesDatabaseRef.child("PongSinglePlayer").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["times"] = self.gameController.timesOfPlayingGameNotTutorial[GameToPresentOptions.pongSinglePlayer] as AnyObject
                pongSinglePlayerRef.updateChildValues(values)
                
                let pongMultiRef = playTimesDatabaseRef.child("pongMultiplayer").child((Auth.auth().currentUser?.uid as AnyObject) as! String)
                values = [String:AnyObject]()
                values["times"] = self.gameController.timesOfPlayingGameNotTutorial[GameToPresentOptions.pong] as AnyObject
                pongMultiRef.updateChildValues(values)
            }
        }
    }
    
    func gamecenterSetUp(){
        let gamecenterPlayer = GKLocalPlayer.local
        
        gamecenterPlayer.authenticateHandler = { (vc, error) in
            if error == nil && vc != nil{
                self.present(vc!, animated: true, completion: nil)
            }
        }
        
        saveToGameCenter(scoreToSend: gameController.level, id: Constants.gcLeaderboardHighLevel)
        saveToGameCenter(scoreToSend: gameController.highScores[GameToPresentOptions.basketballFree]!, id: Constants.gcLeaderboardBF)
        saveToGameCenter(scoreToSend: gameController.highScores[GameToPresentOptions.basketballTimeLimited]!, id: Constants.gcLeaderboardBT)
        saveToGameCenter(scoreToSend: gameController.highScores[GameToPresentOptions.basketballBallLimited]!, id: Constants.gcLeaderboardBB)
        saveToGameCenter(scoreToSend: gameController.highScores[GameToPresentOptions.pong]!, id: Constants.gcLeaderboardPong)
        saveToGameCenter(scoreToSend: gameController.winTimes, id: Constants.gcLeaderBoardWin)
    }
    
    func saveToGameCenter(scoreToSend: Int, id: String){
        if GKLocalPlayer.local.isAuthenticated{
            let score = GKScore(leaderboardIdentifier: id)
            score.value = Int64(scoreToSend)
            GKScore.report([score], withCompletionHandler: nil)
        }
    }
    
    @objc func showLeaderBoard(){
        let vc = GKGameCenterViewController()
        vc.gameCenterDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func setUp(){
        view.addSubview(mainScrollView)
        
        
        mainScrollView.addSubview(loginNoticeLabel)
        NSLayoutConstraint.activate([
            loginNoticeLabel.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 12),
            loginNoticeLabel.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 12),
            loginNoticeLabel.heightAnchor.constraint(equalToConstant: 100)
            ]
        )
        
        isUserLoggedIn = gameController.hasLoggedIn
        
        
        mainScrollView.addSubview(loginButton)
        loginButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: loginNoticeLabel.centerYAnchor).isActive = true
        loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        loginButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(login)))
        if !isUserLoggedIn{
            loginButton.isHidden = false
        }else{
            loginButton.isHidden = true
        }
        
        
        mainScrollView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: loginNoticeLabel.bottomAnchor, constant: 12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor).isActive = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.borderWidth = 5

        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(levelLabel)
        NSLayoutConstraint.activate([
            levelLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            levelLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        mainScrollView.addSubview(rankButtonForLevel)
        rankButtonForLevel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        rankButtonForLevel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        rankButtonForLevel.leftAnchor.constraint(equalTo: levelLabel.rightAnchor, constant: 48).isActive = true
        rankButtonForLevel.centerYAnchor.constraint(equalTo: levelLabel.centerYAnchor).isActive = true
        
        view.addSubview(experienceLabel)
        NSLayoutConstraint.activate([
            experienceLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 12),
            experienceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        
        //score
        view.addSubview(line)
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 24),
            line.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            line.heightAnchor.constraint(equalToConstant: 2),
            line.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(highScoresLabel)
        NSLayoutConstraint.activate([
            highScoresLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 12),
            highScoresLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        mainScrollView.addSubview(rankButtonForHighScores)
        rankButtonForHighScores.heightAnchor.constraint(equalToConstant: 30).isActive = true
        rankButtonForHighScores.widthAnchor.constraint(equalToConstant: 30).isActive = true
        rankButtonForHighScores.leftAnchor.constraint(equalTo: highScoresLabel.rightAnchor, constant: 48).isActive = true
        rankButtonForHighScores.centerYAnchor.constraint(equalTo: highScoresLabel.centerYAnchor).isActive = true
        
        view.addSubview(basketballLabel)
        NSLayoutConstraint.activate([
            basketballLabel.topAnchor.constraint(equalTo: highScoresLabel.bottomAnchor, constant: 12),
            basketballLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            basketballLabel.heightAnchor.constraint(equalToConstant: 60),
            basketballLabel.widthAnchor.constraint(equalToConstant: 60)
            ]
        )
        
        view.addSubview(basketballFreeModeScoreLabel)
        NSLayoutConstraint.activate([
            basketballFreeModeScoreLabel.topAnchor.constraint(equalTo: basketballLabel.bottomAnchor, constant: 12),
            basketballFreeModeScoreLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(timeModeScoreLabel)
        NSLayoutConstraint.activate([
            timeModeScoreLabel.topAnchor.constraint(equalTo: basketballFreeModeScoreLabel.bottomAnchor, constant: 12),
            timeModeScoreLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(ballModeScoreLabel)
        NSLayoutConstraint.activate([
            ballModeScoreLabel.topAnchor.constraint(equalTo: timeModeScoreLabel.bottomAnchor, constant: 12),
            ballModeScoreLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(pongLabel)
        NSLayoutConstraint.activate([
            pongLabel.topAnchor.constraint(equalTo: ballModeScoreLabel.bottomAnchor, constant: 18),
            pongLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            pongLabel.heightAnchor.constraint(equalToConstant: 60),
            pongLabel.widthAnchor.constraint(equalToConstant: 60)
            ]
        )
        
        view.addSubview(pingpongFreeModeScoreLabel)
        NSLayoutConstraint.activate([
            pingpongFreeModeScoreLabel.topAnchor.constraint(equalTo: pongLabel.bottomAnchor, constant: 12),
            pingpongFreeModeScoreLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(archeryLabel)
        NSLayoutConstraint.activate([
            archeryLabel.topAnchor.constraint(equalTo: pingpongFreeModeScoreLabel.bottomAnchor, constant: 18),
            archeryLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            archeryLabel.heightAnchor.constraint(equalToConstant: 60),
            archeryLabel.widthAnchor.constraint(equalToConstant: 60)
            ]
        )
        
        
        view.addSubview(archeryFreeModeScoreLabel)
        NSLayoutConstraint.activate([
            archeryFreeModeScoreLabel.topAnchor.constraint(equalTo: archeryLabel.bottomAnchor, constant: 12),
            archeryFreeModeScoreLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        
        //multiplayer
        view.addSubview(lineForMultiplayer)
        NSLayoutConstraint.activate([
            lineForMultiplayer.topAnchor.constraint(equalTo: archeryFreeModeScoreLabel.bottomAnchor, constant: 24),
            lineForMultiplayer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            lineForMultiplayer.heightAnchor.constraint(equalToConstant: 2),
            lineForMultiplayer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(multiplayerLabel)
        NSLayoutConstraint.activate([
            multiplayerLabel.topAnchor.constraint(equalTo: lineForMultiplayer.bottomAnchor, constant: 12),
            multiplayerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        mainScrollView.addSubview(rankButtonForMultiplayer)
        rankButtonForMultiplayer.heightAnchor.constraint(equalToConstant: 30).isActive = true
        rankButtonForMultiplayer.widthAnchor.constraint(equalToConstant: 30).isActive = true
        rankButtonForMultiplayer.leftAnchor.constraint(equalTo: multiplayerLabel.rightAnchor, constant: 48).isActive = true
        rankButtonForMultiplayer.centerYAnchor.constraint(equalTo: multiplayerLabel.centerYAnchor).isActive = true
        
        view.addSubview(winTimesLabel)
        NSLayoutConstraint.activate([
            winTimesLabel.topAnchor.constraint(equalTo: multiplayerLabel.bottomAnchor, constant: 24),
            winTimesLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(loseTimesLabel)
        NSLayoutConstraint.activate([
            loseTimesLabel.topAnchor.constraint(equalTo: winTimesLabel.bottomAnchor, constant: 24),
            loseTimesLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        view.addSubview(drawTimesLabel)
        NSLayoutConstraint.activate([
            drawTimesLabel.topAnchor.constraint(equalTo: loseTimesLabel.bottomAnchor, constant: 24),
            drawTimesLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        
        //shop
        view.addSubview(lineForShop)
        NSLayoutConstraint.activate([
            lineForShop.topAnchor.constraint(equalTo: drawTimesLabel.bottomAnchor, constant: 24),
            lineForShop.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            lineForShop.heightAnchor.constraint(equalToConstant: 2),
            lineForShop.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        
        
        mainScrollView.addSubview(gemLabelView)
        NSLayoutConstraint.activate([
            gemLabelView.topAnchor.constraint(equalTo: lineForShop.bottomAnchor,constant:12),
            gemLabelView.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 12),
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
        
        mainScrollView.addSubview(watchVideoButton)
        NSLayoutConstraint.activate([
            watchVideoButton.topAnchor.constraint(equalTo: gemLabelView.topAnchor,constant: 0),
            watchVideoButton.leftAnchor.constraint(equalTo: buyGemsButton.rightAnchor, constant: 12),
            watchVideoButton.heightAnchor.constraint(equalToConstant: 40),
            watchVideoButton.widthAnchor.constraint(equalToConstant: 40),
            ]
        )
        watchVideoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(watchVideo)))
        
        
        //view in AR
        mainScrollView.addSubview(viewInARLabel)
        NSLayoutConstraint.activate([
            viewInARLabel.topAnchor.constraint(equalTo: gemLabelView.topAnchor,constant: 0),
            viewInARLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            ]
        )
        viewInARLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewInAR)))
        DispatchQueue.main.async {
            self.viewInARLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            self.viewInARLabel.backgroundColor = #colorLiteral(red: 1, green: 0.4357282873, blue: 0.9564618453, alpha: 1)
            UIView.animate(withDuration: 3, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.viewInARLabel.alpha = 0.2
            }, completion: nil)
        }
        
        //MARK:shop items
        mainScrollView.addSubview(basketballItemsLabel)
        NSLayoutConstraint.activate([
            basketballItemsLabel.topAnchor.constraint(equalTo: gemLabelView.bottomAnchor,constant: 12),
            basketballItemsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            ]
        )
        
        mainScrollView.addSubview(basketballStack)
        NSLayoutConstraint.activate([
            basketballStack.topAnchor.constraint(equalTo: basketballItemsLabel.bottomAnchor,constant: 12),
            basketballStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            basketballStack.heightAnchor.constraint(equalToConstant: 80),
            basketballStack.widthAnchor.constraint(equalToConstant: 288),
            ]
        )
        
        //MARKS: basketball Effects
        mainScrollView.addSubview(basketballEffectsLabel)
        NSLayoutConstraint.activate([
            basketballEffectsLabel.topAnchor.constraint(equalTo: basketballStack.bottomAnchor,constant: 12),
            basketballEffectsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            ]
        )
        
        mainScrollView.addSubview(basketballEffectsStack)
        NSLayoutConstraint.activate([
            basketballEffectsStack.topAnchor.constraint(equalTo: basketballEffectsLabel.bottomAnchor,constant: 12),
            basketballEffectsStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            basketballEffectsStack.heightAnchor.constraint(equalToConstant: 80),
            basketballEffectsStack.widthAnchor.constraint(equalToConstant: 288),
            ]
        )
        
        //MARK: pong
        mainScrollView.addSubview(pongballLabel)
        NSLayoutConstraint.activate([
            pongballLabel.topAnchor.constraint(equalTo: basketballEffectsStack.bottomAnchor,constant: 12),
            pongballLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            ]
        )
        
        mainScrollView.addSubview(pongballStack)
        NSLayoutConstraint.activate([
            pongballStack.topAnchor.constraint(equalTo: pongballLabel.bottomAnchor,constant: 12),
            pongballStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            pongballStack.heightAnchor.constraint(equalToConstant: 80),
            pongballStack.widthAnchor.constraint(equalToConstant: 184),
            ]
        )
        
        mainScrollView.addSubview(pongballEffectsLabel)
        NSLayoutConstraint.activate([
            pongballEffectsLabel.topAnchor.constraint(equalTo: pongballStack.bottomAnchor,constant: 12),
            pongballEffectsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            ]
        )
        
        mainScrollView.addSubview(pongballEffectsStack)
        NSLayoutConstraint.activate([
            pongballEffectsStack.topAnchor.constraint(equalTo: pongballEffectsLabel.bottomAnchor,constant: 12),
            pongballEffectsStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            pongballEffectsStack.heightAnchor.constraint(equalToConstant: 80),
            pongballEffectsStack.widthAnchor.constraint(equalToConstant: 288),
            ]
        )
        
        mainScrollView.addSubview(pongballEffectsSecondStack)
        NSLayoutConstraint.activate([
            pongballEffectsSecondStack.topAnchor.constraint(equalTo: pongballEffectsStack.bottomAnchor,constant: 12),
            pongballEffectsSecondStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            pongballEffectsSecondStack.heightAnchor.constraint(equalToConstant: 80),
            pongballEffectsSecondStack.widthAnchor.constraint(equalToConstant: 80),
            ]
        )
        
        //MARK: Weather
        mainScrollView.addSubview(weatherLabel)
        NSLayoutConstraint.activate([
            weatherLabel.topAnchor.constraint(equalTo: pongballEffectsSecondStack.bottomAnchor,constant: 12),
            weatherLabel.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 12),
            ]
        )
        
        mainScrollView.addSubview(weatherStack)
        NSLayoutConstraint.activate([
            weatherStack.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor,constant: 12),
            weatherStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            weatherStack.heightAnchor.constraint(equalToConstant: 80),
            weatherStack.widthAnchor.constraint(equalToConstant: 288),
            ]
        )
        
        //MARK: consumable
        mainScrollView.addSubview(consumableItemsLabel)
        NSLayoutConstraint.activate([
            consumableItemsLabel.topAnchor.constraint(equalTo: weatherStack.bottomAnchor,constant: 24),
            consumableItemsLabel.leftAnchor.constraint(equalTo: mainScrollView.leftAnchor, constant: 12),
            ]
        )
        
        
        consumableItemsCollectionView.register(ConsumableItemCell.self, forCellWithReuseIdentifier: consumableItemCellID)
        consumableItemsCollectionView.delegate = self
        consumableItemsCollectionView.dataSource = self
        consumableItemsCollectionView.showsHorizontalScrollIndicator = false
        mainScrollView.addSubview(consumableItemsCollectionView)
        NSLayoutConstraint.activate([
            consumableItemsCollectionView.heightAnchor.constraint(equalToConstant: 128),
            consumableItemsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            consumableItemsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            consumableItemsCollectionView.topAnchor.constraint(equalTo: consumableItemsLabel.bottomAnchor, constant: 12)
            ]
        )
        
        
        
        mainScrollView.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: consumableItemsCollectionView.bottomAnchor, constant: 50),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 80),
            logoutButton.widthAnchor.constraint(equalToConstant: 240)
            ]
        )
        logoutButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logout)))
        if isUserLoggedIn{
            logoutButton.isHidden = false
        }else{
            logoutButton.isHidden = true
        }
        
        
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 100)
            ]
        )
        
        name = gameController.playerName
        level = gameController.level
        experience = gameController.experience
        gems = gameController.gems
        
        if isKeyPresentInUserDefaults(key: UserInfoViewController.userProfileImageKey){
            profileImageView.image = UIImage(data: getProfileImageFromUserDefaults() as! Data)
        }
        
        //add gestures
        let recog = UITapGestureRecognizer(target: self, action: #selector(selectItem(recog:)))
        recog.delegate = self
        view.addGestureRecognizer(recog)
    }
    
    @objc func viewInAR(){
        present(ShopViewController(gameController: gameController), animated: false, completion: nil)
    }
    
    let consumableItemCellID = "consumableItemCellID"
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let view = touch.view
        if view == basicPong || view == basicBall || view == nbaBall || view == goldenBall || view == fireBall || view == magicBall || view == firePong || view == rain || view == star || view == dragonPong || view == noWeather || view == lavaPong || view == noEffectBall || view == noEffectPong || view == orangePong
        {
            return true
        }
        return false
    }
    
    @objc func selectItem(recog: UITapGestureRecognizer){
        if recog.state == .ended{
            guard let view = recog.view else { return }
            let subview = view.hitTest(recog.location(in: recog.view), with: UIEvent())
            let allShoppable = AllItemsAndMissions.allItems
            let allBasic = AllItemsAndMissions.basicItems
            switch subview{
            case basicPong:
                dealWithShopItemSelection(item: allBasic[0], itemCategory: "p")
                return
            case orangePong:
                dealWithShopItemSelection(item: allShoppable[8], itemCategory: "p")
                return
            case basicBall:
                dealWithShopItemSelection(item: allBasic[1], itemCategory: "bb")
                return
            case nbaBall:
                dealWithShopItemSelection(item: allShoppable[3], itemCategory: "bb")
                return
            case goldenBall:
                dealWithShopItemSelection(item: allShoppable[1], itemCategory: "bb")
                return
            case noEffectBall:
                dealWithShopItemSelection(item: allBasic[3], itemCategory: "be")
                return
            case fireBall:
                dealWithShopItemSelection(item: allShoppable[0], itemCategory: "be")
                return
            case magicBall:
                dealWithShopItemSelection(item: allShoppable[2], itemCategory: "be")
                return
            case firePong:
                dealWithShopItemSelection(item: allShoppable[4], itemCategory: "pe")
                return
            case noEffectPong:
                dealWithShopItemSelection(item: allBasic[4], itemCategory: "pe")
                return
            case lavaPong:
                dealWithShopItemSelection(item: allShoppable[9], itemCategory: "pe")
                return
            case dragonPong:
                dealWithShopItemSelection(item: allShoppable[7], itemCategory: "pe")
                return
            case noWeather:
                dealWithWeather(item: allBasic[2])
            case rain:
                dealWithWeather(item: allShoppable[5])
            case star:
                dealWithWeather(item: allShoppable[6])
            default:
                return
            }
        }else{
            return
        }
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
                            self.customAlertView = BluredShadowView(title: "You Have Bought \(item.name.rawValue)", message: "Try It Now", buttonTitle: "Done", showCancel: false, buttonHandler: {
                                self.dealWithWeather(item: item)
                            })
                            self.view.addSubview(self.customAlertView)
                            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                        })
                        self.view.addSubview(self.customAlertView)
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
                        self.view.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    }
                })
                self.view.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }
        }
        
        customAlertView = BluredShadowView(title: title, message: message, buttonTitle: buttonText, showCancel: true, buttonHandler: {
            handler!()
        })
        view.addSubview(customAlertView)
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
                        self.customAlertView = BluredShadowView(title: "Are You Sure To Buy With \(item.price[PaymentOptions.gems]!) Gems", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: { [unowned self] in
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
                                self.dealWithShopItemSelection(item:item,itemCategory:itemCategory)
                            })
                            self.view.addSubview(self.customAlertView)
                            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                        })
                        self.view.addSubview(self.customAlertView)
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
                        self.view.addSubview(self.customAlertView)
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
                self.view.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }
        }
        
        customAlertView = BluredShadowView(title: title, message: message, buttonTitle: buttonText, showCancel: true, buttonHandler: {
            handler!()
        })
        view.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
    
    var rewardForSpecificItem:ShopItem?
    
    
    @objc func login(){
        let vc = authUI!.authViewController()
        present(vc, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if user != nil && error == nil{
            isUserLoggedIn = true
            loginButton.isHidden = true
            logoutButton.isHidden = false
            if !gameController.hasLoggedInFirstTime{
                if let vc = self.presentingViewController as? ShopViewController{
                    vc.gems += AllItemsAndMissions.allMissions[4].awards
                    self.gameController.rawGems += AllItemsAndMissions.allMissions[4].awards
                }else{
                    self.customAlertView = BluredShadowView(title: "You Have Logged In", message: "Login Mission Completed, You Can Find More Missions On The AR Shop(Top Right At Main Menu", buttonTitle: "OK", showCancel: true, buttonHandler: {
                        self.gems += AllItemsAndMissions.allMissions[4].awards
                        self.gameController.rawGems += AllItemsAndMissions.allMissions[4].awards
                    })
                    self.view.addSubview(self.customAlertView)
                    self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                }
                gameController.hasLoggedInFirstTime = true
            }
            if getProfileImageFromUserDefaults() == nil{
                if let url = user?.photoURL{
                    profileImageView.loadImageUsingCacheWithUrlString(
                        urlString: url.absoluteString,
                        doIfDownloadFailed: {
                            return
                    },
                        doIfSuccess: {
                            self.saveProfileImageInUserDefaults(image: self.profileImageView.image!)
                    })
                }
            }
            if let name = user?.displayName{
                self.customAlertView = BluredShadowView(title: "Do You Want To Change Your Display Name To That On The Account You Just Logged In To", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: {
                    self.gameController.playerName = name
                    self.nameLabel.text = "Name: \(name)"
                })
                self.view.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }
            Database.database().reference().child("USERDATA").child(user!.uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    if let gems = dictionary["rawgems"] as? Int,let level = dictionary["level"] as? Int,let xp = dictionary["xp"] as? Int{
                        self.customAlertView = BluredShadowView(title: "You Have An Account With \(gems) Gems", message: "Do You Want To Use This Account's Data?", buttonTitle: "Yes", showCancel: true, buttonHandler: {
                            self.gems = gems
                            self.gameController.level = level
                            self.gameController.experience = xp
                            self.gameController.ownedItems = AllItemsAndMissions.basicItems
                            self.gameController.consumableItems = [AllItemsAndMissions.allComsumableItems[0]:3,AllItemsAndMissions.allComsumableItems[1]:3,AllItemsAndMissions.allComsumableItems[2]:3,AllItemsAndMissions.allComsumableItems[3]:3,AllItemsAndMissions.allComsumableItems[4]:3,AllItemsAndMissions.allComsumableItems[5]:3,]
                            self.consumableItemsCollectionView.reloadData()
                        })
                        self.view.addSubview(self.customAlertView)
                        self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
                    }
                }
            }, withCancel: nil)
        }
    }
    
    @objc func back(){
        if let vc = self.presentingViewController as? ShopViewController{
            vc.showAlertIfARTrackingInterrupted()
        }
        menuViewController?.sceneView.session.run(ARWorldTrackingConfiguration())
        dismiss(animated: true)
    }
    
    @objc func logout(){
        self.showAlert(title: "Are You Sure To Log Out", message: "", buttonTitle: "Yes", showCancel: true) { (_) in
            if let user = Auth.auth().currentUser{
                let userDataRef = Database.database().reference().child("USERDATA").child(user.uid)
                var values = [String:AnyObject]()
                values["rawgems"] = self.gameController.rawGems as AnyObject
                values["level"] = self.gameController.level as AnyObject
                values["xp"] = self.gameController.experience as AnyObject
                userDataRef.updateChildValues(values)
                
            }
            if (try? self.authUI?.signOut()) != nil{
                self.isUserLoggedIn = false
                self.loginButton.isHidden = false
                self.logoutButton.isHidden = true
                
            }else{
                print("logout failed")
            }
        }
    }
    
    static var userProfileImageKey = "userProfileImageKey"
    
    func saveProfileImageInUserDefaults(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 0.5)
        let defaults = UserDefaults.standard
        defaults.set(imageData, forKey: UserInfoViewController.userProfileImageKey)
    }
    
    func getProfileImageFromUserDefaults() -> Any? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: UserInfoViewController.userProfileImageKey)
    }
    
    
    func handleRewardBasedAdNotAvailable(){
        customAlertView = BluredShadowView(title: "Video Not Currently Available", message: "Please Check Your Internet Connection And Try Again Later", buttonTitle: "OK", showCancel: true, buttonHandler: {
            return
        })
        view.addSubview(customAlertView)
        customAlertView.setUpConstrantsIfIsUsedAsAlertView()
    }
}

extension UserInfoViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @objc func handleSelectProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        let actionSheet = UIAlertController(title: "Choose image", message: "Choose Profile Photo from photo library or take one", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = profileImageView
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profileImageView.image = editedImage
            saveProfileImageInUserDefaults(image: editedImage)
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImageView.image = originalImage
            saveProfileImageInUserDefaults(image: originalImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

//MARK: collection view
extension UserInfoViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AllItemsAndMissions.allComsumableItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: consumableItemCellID, for: indexPath) as! ConsumableItemCell
        cell.imageView.imageViewForButton?.image = UIImage(named: AllItemsAndMissions.allComsumableItems[indexPath.row].image)
        cell.slowCountLabel.text = String(gameController.consumableItems[AllItemsAndMissions.allComsumableItems[indexPath.row]]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        buyConsumableItem(item: AllItemsAndMissions.allComsumableItems[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 128)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func buyConsumableItem(item:ShopItem){
        let title = "\(item.name.rawValue)\n\n\(item.description)"
        var handler:(() -> Void)?
        
        let message = ""
        let buttonText = "BUY 3 MORE"
        handler = { [unowned self] in
            self.customAlertView = BluredShadowView(paymentOptions: item.price, buyWithGemsAction: { [unowned self] in
                if self.gameController.gems >= item.price[PaymentOptions.gems]!{
                    self.customAlertView = BluredShadowView(title: "Are You Sure To Buy", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: {
                        self.gems -= item.price[PaymentOptions.gems]!
                        self.gameController.consumableItems[item] = self.gameController.consumableItems[item]! + 3
                        
                        self.customAlertView = BluredShadowView(title: "You Have Bought 3 \(item.name.rawValue)", message: "", buttonTitle: "Done", showCancel: false, buttonHandler: { [unowned self] in
                            self.consumableItemsCollectionView.reloadData()
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
}

extension UserInfoViewController:GADRewardedAdDelegate{
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        if let rewardForSpecificItem = rewardForSpecificItem{
            gameController.watchedVideos[rewardForSpecificItem] = (1 + gameController.watchedVideos[rewardForSpecificItem]!)
            self.rewardForSpecificItem = nil
            let videosLeft = (rewardForSpecificItem.price[PaymentOptions.watchingVideos]! - gameController.watchedVideos[rewardForSpecificItem]!)
            if videosLeft > 0{
                customAlertView = BluredShadowView(title: "Do You Want To Watch Again?", message: "\(videosLeft) times left to get \(rewardForSpecificItem.name.rawValue)", buttonTitle: "Watch", showCancel: true, buttonHandler: {
                    if let ad = self.rewardBasedAd, ad.isReady{
                        self.rewardForSpecificItem = rewardForSpecificItem
                        ad.present(fromRootViewController: self, delegate: self)
                    }else{
                        self.handleRewardBasedAdNotAvailable()
                    }
                })
                view.addSubview(self.customAlertView)
                self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
            }else{
                if AllItemsAndMissions.allItems.contains(rewardForSpecificItem){
                    self.gameController.ownedItems.append(rewardForSpecificItem)
                    self.gameController.unownedItems.removeAll(where: { (item) -> Bool in
                        item == rewardForSpecificItem
                    })
                    self.gameController.watchedVideos[rewardForSpecificItem] = 0
                    self.gameController.rawGems += rewardForSpecificItem.price[PaymentOptions.gems]!
                    self.customAlertView = BluredShadowView(title: "You Got \(rewardForSpecificItem.name.rawValue)", message: "Try It Now", buttonTitle: "Done", showCancel: false, buttonHandler: {
                        return
                    })
                }else if AllItemsAndMissions.allComsumableItems.contains(rewardForSpecificItem){
                    gameController.watchedVideos[rewardForSpecificItem] = 0
                    gameController.consumableItems[rewardForSpecificItem] = gameController.consumableItems[rewardForSpecificItem]! + 3
                    consumableItemsCollectionView.reloadData()
                    self.customAlertView = BluredShadowView(title: "You Have Got 3 \(rewardForSpecificItem.name.rawValue)s", message: "Try It Now", buttonTitle: "Done", showCancel: false, buttonHandler: {
                        return
                    })
                }
                self.view.addSubview(self.customAlertView)
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
            self.view.addSubview(self.customAlertView)
            self.customAlertView.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        rewardBasedAd = createAndLoadRewardedAd()
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        self.rewardBasedAd = createAndLoadRewardedAd()
        print(error.localizedDescription)
    }
}





let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    func loadImageUsingCacheWithUrlString(urlString:String,doIfDownloadFailed failedFunc:@escaping ()->()?,doIfSuccess scuceededFunc:@escaping ()->()?){
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        if let url = URL(string: urlString){
            DispatchQueue.global(qos: .userInitiated).async {
                [weak self] in
                let urlContent = try? Data(contentsOf: url)
                if let content = urlContent{
                    if let downloadedImage = UIImage(data: content){
                        DispatchQueue.main.async {
                            imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                            self?.image = downloadedImage
                            scuceededFunc()
                        }
                    }
                }else{
                    failedFunc()
                }
            }
        }
    }
}
