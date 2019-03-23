//
//  PlayViewController.swift
//  AR tests
//
//  Created by Yu Wang on 1/7/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import MultipeerConnectivity
import UserNotifications

func getFont(withSize size:Int = 24,adjustSizeAccordingToSystem:Bool = true) -> UIFont{
    guard let font = UIFont(name: "NovaFlat", size: CGFloat(size)) else {
        print("font invalide")
        return UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
    let cascadeList = [UIFontDescriptor(fontAttributes: [.name: "Chinese"])]
    let cascadeFontDescriptor = font.fontDescriptor.addingAttributes([.cascadeList:cascadeList])
    let cascadeFont = UIFont(descriptor: cascadeFontDescriptor, size: font.pointSize)
    if adjustSizeAccordingToSystem{
        return UIFontMetrics.default.scaledFont(for: cascadeFont)
    }else{
        return cascadeFont
    }
}

enum ViewControllerToGoBackOptions{
    case mainFromMode
    case mainFromHosting
    case mode
    case non
}

enum GameToPresentOptions:String,Codable{
    case basketballFree = "Basketball Free Mode"
    case basketballTimeLimited = "Basketball Limited Time Mode"
    case basketballBallLimited = "Basketball Limited Ball Mode"
    case archery = "Archery"
    case pong = "Ping Pong"
    case pongSinglePlayer = "pong single player"
}

class MenuViewController: UIViewController,ARSCNViewDelegate,UIGestureRecognizerDelegate {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad{
                return UIInterfaceOrientationMask.all
            }
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    var gameController:RootGameController
    
    var sceneView:ARSCNView = ARSCNView()
    
    var gameToPresent = GameToPresentOptions.basketballFree
    
    var mcSessionController:MultipeerSession?
    
    var backButton = CustomBackButton(image: #imageLiteral(resourceName: "goBack"))
    
    var viewToGoBack = ViewControllerToGoBackOptions.non
    
    @objc func goBack(recog:UIScreenEdgePanGestureRecognizer? = nil){
        if recog == nil || recog?.state == UIScreenEdgePanGestureRecognizer.State.began{
            switch viewToGoBack {
            case .mainFromMode:
                animateWidgetButtons()
                transtitionStackView(from: buttonStackForBaketballModeChoices, to: buttonStack)
                viewToGoBack = .non
            case .mainFromHosting:
                animateWidgetButtons()
                transtitionStackView(from: buttonStackForHostingChoices, to: buttonStack)
                viewToGoBack = .non
            case .mode:
                transtitionStackView(from: buttonStackForHostingChoices, to: buttonStackForBaketballModeChoices)
                viewToGoBack = .mainFromMode
            case .non:
                break
            }
        }
    }
    
    var homeButton = HomeButton(image: #imageLiteral(resourceName: "icon"))
    
    var homeShimmer = HomeButton(image: #imageLiteral(resourceName: "home-shimmer"))
    
    var shopButton = ShopButton(image: #imageLiteral(resourceName: "shopping-cart"))
    
    var shopShimmer = ShopButton(image: #imageLiteral(resourceName: "shopping-cart-shimmer"))
    
    //MARK: Main menu stack view with three buttons
    lazy var buttonStack:UIStackView = {
       let stack = UIStackView(arrangedSubviews: [pongButton,basketballButton,archeryButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 40
        stack.distribution = .fillEqually
        return stack
    }()
    
    var basketballButton = BluredShadowView(title: "Basketball", image: #imageLiteral(resourceName: "basketball-3"))
    
    var pongButton = BluredShadowView(title: "Pong", image: #imageLiteral(resourceName: "ping-pong"))
    
    var archeryButton = BluredShadowView(title: "Archery", image: #imageLiteral(resourceName: "bow"))
    
    //MARK: basketball menu stack view with three buttons
    lazy var buttonStackForBaketballModeChoices:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [freeMode,timeMode,limitedBallMode])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 40
        stack.distribution = .fillEqually
        return stack
    }()
    
    var freeMode = BluredShadowView(title: "Free Mode", image: #imageLiteral(resourceName: "basketball-4"))
    
    var timeMode:BluredShadowView = BluredShadowView(title: "Time Mode", image: #imageLiteral(resourceName: "hourglass"))
    
    var limitedBallMode = BluredShadowView(title: "Ball Mode", image: #imageLiteral(resourceName: "basketball-3"))
    
    //MARK: Main menu stack view with three buttons
    lazy var buttonStackForHostingChoices:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [singlePlayer,multiplayerLabel,host,join])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.setCustomSpacing(0, after: singlePlayer)
        stack.setCustomSpacing(0, after: multiplayerLabel)
        stack.setCustomSpacing(30, after: host)
        stack.distribution = .fillEqually
        return stack
    }()
    
    
    var singlePlayer = BluredShadowView(title: "Single Player", image: #imageLiteral(resourceName: "standing-up-man-"))
    
    var multiplayerLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFont(withSize: 34)
        label.text = "Multiplayer"
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    var host = BluredShadowView(title: "Host", image: #imageLiteral(resourceName: "antenna"))
    
    var join = BluredShadowView(title: "Join", image: #imageLiteral(resourceName: "molecular-bond"))
    
    //MARK: UI related
    init(gameController:RootGameController){
        self.gameController = gameController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        
        //set up ar scene view
        setUPSceneView()
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        //gesture
        let gestureRecog = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(goBack(recog:)))
        gestureRecog.edges = UIRectEdge.left
        
        sceneView.addGestureRecognizer(gestureRecog)
        
        //buttons and stacks setup
        setUp()
        
        //multipeer setup
        mcSessionController = MultipeerSession(receivedDataHandler: receivedDataHandler, dissmissHandler: dismissHandler, connectedHandler: connectedHandler, sendWorldMap: sendWorldMap, showNotification:showNotification, sendData: sendData)
        
        //check everytime if camera access allowed
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.handleCameraPermission()
        }
    }
    
    
    
    private func handleCameraPermission(){
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            self.showAlert(title: "AR Technology Requires Camera Access", message: "Plaease turn on allow camera useage for this app in the settings. Click on OPEN SETTINGS to set camera permission", buttonTitle: "OPEN SETTINGS", showCancel: false) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        } else {
            return
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    //MARK: Initial set up for all UIs
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
    }
    
    func animateWidgetButtons(toMainView:Bool = true){
        if toMainView{
            transtitionWidgetButton(with: backButton, x: -100, y: 0, alpha: 0)
            transtitionWidgetButton(with: homeButton, x: 100, y: 0, alpha: 1)
            transtitionWidgetButton(with: homeShimmer, x: 100, y: 0, alpha: 1)
            transtitionWidgetButton(with: shopButton, x: -100, y: 0, alpha: 1)
            transtitionWidgetButton(with: shopShimmer, x: -100, y: 0, alpha: 1)
        }else{
            transtitionWidgetButton(with: backButton, x: 100, y: 0, alpha: 1)
            transtitionWidgetButton(with: homeButton, x: -100, y: 0, alpha: 0)
            transtitionWidgetButton(with: shopButton, x: 100, y: 0, alpha: 0)
            transtitionWidgetButton(with: shopShimmer, x:100, y: 0, alpha: 0)
            transtitionWidgetButton(with: homeShimmer, x: -100, y: 0, alpha: 0)
        }
    }
    
    func setUp(){
        //widget buttons
        sceneView.addSubview(backButton)
        backButton.setConstraints()
        backButton.alpha = 0
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        //HOME
        sceneView.addSubview(homeButton)
        homeButton.setConstraints()
        homeButton.addTarget(self, action: #selector(openHome), for: .touchUpInside)
        //shimmer
        sceneView.addSubview(homeShimmer)
        homeShimmer.setConstraints()
        homeShimmer.isUserInteractionEnabled = false
        addGradientLayer(view: view, on: homeShimmer)
        
        //SHOP
        sceneView.addSubview(shopButton)
        shopButton.setConstraints()
        shopButton.addTarget(self, action: #selector(openShop), for: .touchUpInside)
        
        //shimmer
        sceneView.addSubview(shopShimmer)
        shopShimmer.setConstraints()
        shopShimmer.isUserInteractionEnabled = false
        addGradientLayer(view: view, on: shopShimmer)
        
        //set up stack buttons for main menu
        sceneView.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -100),
            buttonStack.heightAnchor.constraint(equalToConstant: 320),
            buttonStack.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalToConstant: 320),
            ]
        )
        
        
        //set up for basket ball mode choices
        sceneView.addSubview(buttonStackForBaketballModeChoices)
        NSLayoutConstraint.activate([
            buttonStackForBaketballModeChoices.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 420),
            buttonStackForBaketballModeChoices.heightAnchor.constraint(equalToConstant: 320),
            buttonStackForBaketballModeChoices.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            buttonStackForBaketballModeChoices.widthAnchor.constraint(equalToConstant: 320),
            ]
        )
        
        //set up for basket ball hosting choices
        sceneView.addSubview(buttonStackForHostingChoices)
        NSLayoutConstraint.activate([
            buttonStackForHostingChoices.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 420),
            buttonStackForHostingChoices.heightAnchor.constraint(equalToConstant: 350),
            buttonStackForHostingChoices.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            buttonStackForHostingChoices.widthAnchor.constraint(equalToConstant: 320),
            ]
        )
        
        //register gestures
        basketballButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(basketballChosen)))
        archeryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(archeryChosen)))
        pongButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pongChosen)))
        host.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hostMode)))
        join.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(joinMode)))
        singlePlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(offlineMode)))
        timeMode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(limitedTimeModeChosen)))
        limitedBallMode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(limitedBallModeChosen)))
        freeMode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(freeModeChosen)))
    }
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }
}




//MARK: Extension for button events in menu
extension MenuViewController{
    //For main menu
    @objc func basketballChosen(){
        animateWidgetButtons(toMainView: false)
        transtitionStackView(from: buttonStack, to: buttonStackForBaketballModeChoices)
        viewToGoBack = .mainFromMode
    }
    
    @objc func pongChosen(){
        animateWidgetButtons(toMainView: false)
        transtitionStackView(from: buttonStack, to: buttonStackForHostingChoices)
        viewToGoBack = .mainFromHosting
        gameToPresent = .pong
    }
    
    @objc func archeryChosen(){
//        animateWidgetButtons(toMainView: false)
//        transtitionStackView(from: buttonStack, to: buttonStackForHostingChoices)
//        viewToGoBack = .mainFromHosting
//        gameToPresent = .archery
        showAlert(title: "This Game Will Be Open Soon", message: "The Archery Game Will Be Available Soon")
    }
    
    //For hosting mode menu
    @objc func freeModeChosen(){
        transtitionStackView(from: buttonStackForBaketballModeChoices, to: buttonStackForHostingChoices)
        viewToGoBack = .mode
        gameToPresent = .basketballFree
    }
    
    @objc func limitedTimeModeChosen(){
        transtitionStackView(from: buttonStackForBaketballModeChoices, to: buttonStackForHostingChoices)
        viewToGoBack = .mode
        gameToPresent = .basketballTimeLimited
    }
    
    @objc func limitedBallModeChosen(){
        transtitionStackView(from: buttonStackForBaketballModeChoices, to: buttonStackForHostingChoices)
        viewToGoBack = .mode
        gameToPresent = .basketballBallLimited
    }
    
    //For widgets
    @objc func openShop(){
        transtitionView(buttonStack, withDuration: 0.1, upWard: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
            transtitionView(self.buttonStack, withDuration: 0.1, upWard: true)
        })
        sceneView.session.pause()
        let viewController = ShopViewController(gameController: gameController)
        viewController.menuViewController = self
        present(viewController,animated:true)
    }
    
    @objc func openHome(){
        sceneView.session.pause()
        let viewController = UserInfoViewController(gameController: gameController)
        viewController.menuViewController = self
        viewController.modalPresentationStyle = .overCurrentContext
        present(viewController,animated:true)
    }
    
    
}




//MARK: Extension for multipeer connect
extension MenuViewController{
    
    /**
     fake one
     */
    func sendData(){
        
    }
    /**
     fake one
     */
    func showNotification(string:String){
        
    }
    /**
     fake one
     */
    func sendWorldMap(){
        
    }
    
    func dismissHandler(){
        dismiss(animated: true, completion: nil)
        sceneView.session.run(ARWorldTrackingConfiguration())
    }
    
    /**
     fake one
     */
    func receivedDataHandler(data:Data,peerID:MCPeerID){
        
    }
    
    func connectedHandler(){
        sceneView.session.pause()
        switch gameToPresent {
        case .basketballFree:
            let viewController = MultiPlayerPlayBasketballFreeMode(gameController:gameController, mode: gameToPresent)
            viewController.menuViewController = self
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: false)
            present(viewController, animated: true, completion: nil)
        case .basketballTimeLimited:
            let viewController = MultiPlayerPlayBasketballFreeMode(gameController:gameController, mode: gameToPresent)
            viewController.menuViewController = self
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: false)
            present(viewController, animated: true, completion: nil)
        case .basketballBallLimited:
            let viewController = MultiPlayerPlayBasketballFreeMode(gameController:gameController, mode: gameToPresent)
            viewController.menuViewController = self
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: false)
            present(viewController, animated: true, completion: nil)
        case .archery:
            break
        case .pong:
            let viewController = MultiPlayerPongGameViewController(gameController:gameController)
            viewController.menuViewController = self
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: false)
            viewController.singlePlayer = false
            present(viewController, animated: true, completion: nil)
        case .pongSinglePlayer:
            break
        }
    }
    
    
    @objc func offlineMode(){
        sceneView.session.pause()
        switch gameToPresent {
        case .basketballFree:
            let viewController = PlayBasketballFreeModeViewController(gameController:gameController)
            viewController.menuViewController = self
            present(viewController, animated: false, completion: nil)
        case .basketballTimeLimited:
            let viewController = TimeModeViewController(gameController:gameController)
            viewController.menuViewController = self
            present(viewController, animated: false, completion: nil)
        case .basketballBallLimited:
            let viewController = BasketBallBallModeViewController(gameController:gameController)
            viewController.menuViewController = self
            present(viewController, animated: false, completion: nil)
        case .archery:
            let viewController = RootArcheryViewController(gameController:gameController)
            viewController.menuViewController = self
            present(viewController, animated: false, completion: nil)
        case .pong:
            let viewController = RootPongViewController(gameController:gameController)
            viewController.menuViewController = self
            viewController.singlePlayer = true
            present(viewController, animated: false, completion: nil)
        default:
            break
        }
        
    }
    
    @objc func hostMode(){
        sceneView.session.pause()
        switch gameToPresent {
        case .basketballFree:
            mcSessionController?.advertiser = MCAdvertiserAssistant(serviceType: serviceTypes.bbFree.rawValue, discoveryInfo: nil, session: (mcSessionController?.session)!)
            let viewController = MultiPlayerPlayBasketballFreeMode(gameController:gameController, mode: gameToPresent)
            viewController.menuViewController = self
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: true)
            present(viewController, animated: false, completion: nil)
        case .basketballTimeLimited:
            mcSessionController?.advertiser = MCAdvertiserAssistant(serviceType: serviceTypes.bbTime.rawValue, discoveryInfo: nil, session: (mcSessionController?.session)!)
            let viewController = MultiPlayerPlayBasketballFreeMode(gameController:gameController, mode: gameToPresent)
            viewController.menuViewController = self
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: true)
            present(viewController, animated: false, completion: nil)
        case .basketballBallLimited:
            mcSessionController?.advertiser = MCAdvertiserAssistant(serviceType: serviceTypes.bbBall.rawValue, discoveryInfo: nil, session: (mcSessionController?.session)!)
            let viewController = MultiPlayerPlayBasketballFreeMode(gameController:gameController, mode: gameToPresent)
            viewController.menuViewController = self
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: true)
            present(viewController, animated: false, completion: nil)
        case .archery:
            break
        case .pong:
            mcSessionController?.advertiser = MCAdvertiserAssistant(serviceType: serviceTypes.pp.rawValue, discoveryInfo: nil, session: (mcSessionController?.session)!)
            let viewController = MultiPlayerPongGameViewController(gameController:gameController)
            viewController.menuViewController = self
            viewController.singlePlayer = false
            viewController.setUpMultipeer(mcSessionController: mcSessionController!, isHost: true)
            present(viewController, animated: false, completion: nil)
        default:
            break
        }
        
    }
    
    @objc func joinMode(){
        sceneView.session.pause()
        switch gameToPresent {
        case .basketballFree:
            mcSessionController?.browser = MCBrowserViewController(serviceType: serviceTypes.bbFree.rawValue, session: (mcSessionController?.session)!)
            
        case .basketballTimeLimited:
            mcSessionController?.browser = MCBrowserViewController(serviceType: serviceTypes.bbTime.rawValue, session: (mcSessionController?.session)!)
        case .basketballBallLimited:
            mcSessionController?.browser = MCBrowserViewController(serviceType: serviceTypes.bbBall.rawValue, session: (mcSessionController?.session)!)
        case .archery:
            break
        case .pong:
            mcSessionController?.browser = MCBrowserViewController(serviceType: serviceTypes.pp.rawValue, session: (mcSessionController?.session)!)
        default:
            break
        }
        mcSessionController?.browser.delegate = mcSessionController
        present((mcSessionController?.browser)!, animated: false)
    }
}


func transtitionStackView(from stackToDisappear:UIStackView,to stackToShow:UIStackView,withDuration duration:Double = 0.2){
    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
        stackToDisappear.transform = stackToDisappear.transform.translatedBy(x: 0, y: 520)
    }) { (_) in
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            stackToShow.transform = stackToShow.transform.translatedBy(x: 0, y: -520)
        }, completion: nil)
    }
}

func transtitionView(_ view:UIView,withDuration duration:Double = 0.2,upWard:Bool = true){
    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
        if upWard{
            view.transform = view.transform.translatedBy(x: 0, y: -580)
        }else{
            view.transform = view.transform.translatedBy(x: 0, y: 580)
        }
    })
}

func transtitionWidgetButton(with button:UIButton,x:CGFloat = -100,y:CGFloat = 0,alpha:CGFloat = 0){
    if alpha == 0{
        button.isEnabled = false
    }else{
        button.isEnabled = true
    }
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        button.transform = button.transform.translatedBy(x: x, y: y)
        button.alpha = alpha
    }, completion: nil)
}

func addGradientLayer(view:UIView,on shimmerView:UIView,duration:Int = 3,delayInMilliseconds:Int = 0){
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
        UIColor.clear.cgColor, UIColor.clear.cgColor,
        UIColor.black.cgColor, UIColor.black.cgColor,
        UIColor.clear.cgColor, UIColor.clear.cgColor
    ]
    
    gradientLayer.locations = [0, 0.2, 0.4, 0.6, 0.8, 1]
    
    let angle = 45 * CGFloat.pi / 180
    let rotationTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
    gradientLayer.transform = rotationTransform
    view.layer.addSublayer(gradientLayer)
    gradientLayer.frame = view.frame
    
    shimmerView.layer.mask = gradientLayer
    
//    gradientLayer.transform = CATransform3DConcat(gradientLayer.transform, CATransform3DMakeScale(3, 3, 0))
    
    let animation = CABasicAnimation(keyPath: "transform.translation.x")
    animation.duration = CFTimeInterval(duration)
    animation.repeatCount = Float.infinity
    animation.autoreverses = false
    animation.fromValue = -view.frame.width
    animation.toValue = view.frame.width
    animation.isRemovedOnCompletion = false
    animation.fillMode = CAMediaTimingFillMode.forwards
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayInMilliseconds)) {
        gradientLayer.add(animation, forKey: "shimmerKey")
    }
}
