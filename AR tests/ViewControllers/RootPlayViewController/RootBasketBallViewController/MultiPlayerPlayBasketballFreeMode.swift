//
//  MultiPlayerPlayBasketballFreeMode.swift
//  AR tests
//
//  Created by Yu Wang on 1/7/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import Each
import MultipeerConnectivity
import Foundation


class MultiPlayerPlayBasketballFreeMode: RootBasketBallViewController {
    
    var isHost:Bool?
    
    //encoder and decoder for all data transferred through MCsession
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    
    var scoreLabelForTheOtherPlayer:BluredShadowView = {
        let label = BluredShadowView(title: "Player2\n0")
        label.label?.contentMode = .scaleToFill
        label.label?.textAlignment = .center
        label.label?.font = getFont(withSize: 20)
        return label
    }()
    
    var otherPlayerName:String = "Player2"{
        didSet{
            DispatchQueue.main.async {
                self.scoreLabelForTheOtherPlayer.label!.text = "\(self.otherPlayerName)\n\(self.scoreForTheOtherPlayer)"
            }
        }
    }
    
    var scoreForTheOtherPlayer:Int = 0{
        didSet{
            DispatchQueue.main.async {
                self.scoreLabelForTheOtherPlayer.label!.text = "\(self.otherPlayerName)\n\(self.scoreForTheOtherPlayer)"
            }
        }
    }
    
    override var score: Int{
        didSet{
            DispatchQueue.main.async {
                self.scoreLabel.label!.text = "You\n\(self.score)"
            }
        }
    }
    
    /**
     default to be .initialRequestForWorldMap
     */
    var dataCatagoryClass = SendDataWithCatagoryManager(type: DataCategory.initialRequestForWorldMap, data: Data())
    
    var multiplayerSessionController:MultipeerSession?
    
    lazy var selfPeerID = multiplayerSessionController?.myPeerID
    
    /**
     required before initialization
     */
    func setUpMultipeer(mcSessionController:MultipeerSession, isHost:Bool){
        self.multiplayerSessionController = mcSessionController
        self.isHost = isHost
    }
    
    var mode:GameToPresentOptions
    
    init(gameController:RootGameController, mode:GameToPresentOptions){
        self.mode = mode
        super.init(gameController: gameController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: if time mode
    var countDownTimer = Each.init(1).seconds
    
    var maxGameTime = 120
    
    var timeLeft = 120{
        didSet{
            countDownLabel.text = "Time\n\(self.timeLeft)"
        }
    }
    
    //MARK: if ball mode
    let maximumBalls = 12
    
    var ballThrown = 0{
        didSet{
            countDownLabel.text = "Balls\n\(maximumBalls - ballThrown)"
            if ballThrown >= maximumBalls{
                selfHasShotAllBalls = true
                if otherPlayerHasShotAllBalls{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.getScoreView(game: GameToPresentOptions.basketballBallLimited, score: self.score, scoreForTheOtherPlayer: self.scoreForTheOtherPlayer)
                        transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                        self.backButton.isUserInteractionEnabled = false
                        self.sceneView.isUserInteractionEnabled = false
                    }
                }
            }
        }
    }
    
    var ballThrownForOtherPlayer = 0{
        didSet{
            if ballThrownForOtherPlayer >= maximumBalls{
                otherPlayerHasShotAllBalls = true
                if selfHasShotAllBalls{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.getScoreView(game: GameToPresentOptions.basketballBallLimited, score: self.score, scoreForTheOtherPlayer: self.scoreForTheOtherPlayer)
                        transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                        self.backButton.isUserInteractionEnabled = false
                        self.sceneView.isUserInteractionEnabled = false
                    }
                }
            }
        }
    }
    
    var countDownLabel = CustomRoundedRectLabel()
    
    
    //MARK: for multuplayer ball selection
    var selectionsForOtherPlayer = Selections()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modeLabel.text = "Multiplayer"
        
        setUpAndAddScoreLabelForTheOtherPlayer()
        
        encoder.outputFormat = .binary
        
        
        self.handleMultiplayerToturial()
        
        
        multiplayerSessionController!.showNotification = showNoticeAndFade
        multiplayerSessionController!.receivedDataHandler = receivedDataHandler(data:peerID:)
        multiplayerSessionController!.sendData = sendData
        if isHost!{
            multiplayerSessionController!.advertiser.start()
            multiplayerSessionController!.sendWorldMap = sendWorldMap
            multiplayerSessionController!.isHost = true
            multiplayerSessionController?.advertiser.start()
        }else{
            multiplayerSessionController!.sendData()
            multiplayerSessionController!.isHost = false
            scoreLabelForTheOtherPlayer.isHidden = false
            goalAnchor = nil
            otherPlayerName = multiplayerSessionController?.connectedPeers.first?.displayName[0..<6] ?? "Player2"
        }
        switch mode {
        case .basketballTimeLimited ,.basketballBallLimited:
            setUpCountDownLabel()
        default:
            break
        }
        setUpExpandItems()
    }
    
    let expandItemsButton = BluredShadowView(image: #imageLiteral(resourceName: "expand").withHorizontallyFlippedOrientation(), corner: 4, imageMultplier: 1)
    
    var itemsBackGroudView:UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = UIColor.yellow.withAlphaComponent(0.6)
        return view
    }()
    
    lazy var itemsStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [slowTimeButton,loveButton,whiteLightButton,manyLovesButton,angryButton,fireButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    var slowTimeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "slowTime"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(slowTime), for: .touchUpInside)
        return button
    }()
    
    var loveButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "love"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(showLove), for: .touchUpInside)
        return button
    }()
    
    var whiteLightButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "whiteLight"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(showWhiteLight), for: .touchUpInside)
        return button
    }()
    
    var manyLovesButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "manyLoves"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(showManyLoves), for: .touchUpInside)
        return button
    }()
    
    var angryButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "angry"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(showAngry), for: .touchUpInside)
        return button
    }()
    
    var fireButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "fire"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(addFire), for: .touchUpInside)
        return button
    }()
    
    //count
    lazy var itemsCountStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [slowTimeCountLabel,loveCountLabel,whiteLightCountLabel,manyLovesCountLabel,angryCountLabel,fireCountLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var slowTimeCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = String(gameController.consumableItems[AllItemsAndMissions.allComsumableItems[0]]!)
        label.sizeToFit()
        label.font = getFont(withSize: 10)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 35
        label.textAlignment = .center
        return label
    }()
    
    var slowTimeCount:Int = 0{
        didSet{
            slowTimeCountLabel.text = String(slowTimeCount)
            syncConsumableItem(at: 0, to: slowTimeCount)
        }
    }
    
    lazy var loveCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = String(gameController.consumableItems[AllItemsAndMissions.allComsumableItems[1]]!)
        label.sizeToFit()
        label.font = getFont(withSize: 10)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 35
        label.textAlignment = .center
        return label
    }()
    
    var loveCount:Int = 0{
        didSet{
            loveCountLabel.text = String(loveCount)
            syncConsumableItem(at: 1, to: loveCount)
        }
    }
    
    lazy var whiteLightCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = String(gameController.consumableItems[AllItemsAndMissions.allComsumableItems[2]]!)
        label.sizeToFit()
        label.font = getFont(withSize: 10)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 35
        label.textAlignment = .center
        return label
    }()
    
    var whiteLightCount:Int = 0{
        didSet{
            whiteLightCountLabel.text = String(whiteLightCount)
            syncConsumableItem(at: 2, to: whiteLightCount)
        }
    }
    
    lazy var manyLovesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = String(gameController.consumableItems[AllItemsAndMissions.allComsumableItems[3]]!)
        label.sizeToFit()
        label.font = getFont(withSize: 10)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 35
        label.textAlignment = .center
        return label
    }()
    
    var manyLovesCount:Int = 0{
        didSet{
            manyLovesCountLabel.text = String(manyLovesCount)
            syncConsumableItem(at: 3, to: manyLovesCount)
        }
    }
    
    lazy var angryCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = String(gameController.consumableItems[AllItemsAndMissions.allComsumableItems[4]]!)
        label.sizeToFit()
        label.font = getFont(withSize: 10)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 35
        label.textAlignment = .center
        return label
    }()
    
    var angryCount:Int = 0{
        didSet{
            angryCountLabel.text = String(angryCount)
            syncConsumableItem(at: 4, to: angryCount)
        }
    }
    
    lazy var fireCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = String(gameController.consumableItems[AllItemsAndMissions.allComsumableItems[5]]!)
        label.sizeToFit()
        label.font = getFont(withSize: 10)
        label.adjustsFontForContentSizeCategory = true
        label.preferredMaxLayoutWidth = 35
        label.textAlignment = .center
        return label
    }()
    
    var fireCount:Int = 0{
        didSet{
            fireCountLabel.text = String(fireCount)
            syncConsumableItem(at: 5, to: fireCount)
        }
    }
    
    func setUpExpandItems(){
        view.addSubview(expandItemsButton)
        NSLayoutConstraint.activate([
            expandItemsButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 150),
            expandItemsButton.widthAnchor.constraint(equalToConstant: 40),
            expandItemsButton.heightAnchor.constraint(equalToConstant: 40),
            expandItemsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        expandItemsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandItems)))
        
        view.addSubview(itemsBackGroudView)
        NSLayoutConstraint.activate([
            itemsBackGroudView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 150),
            itemsBackGroudView.widthAnchor.constraint(equalToConstant: 35*6+8*7),
            itemsBackGroudView.heightAnchor.constraint(equalToConstant: 80),
            itemsBackGroudView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60)
            ]
        )
        itemsBackGroudView.alpha = 0
        
        itemsBackGroudView.addSubview(itemsStack)
        NSLayoutConstraint.activate([
            itemsStack.topAnchor.constraint(equalTo: itemsBackGroudView.topAnchor, constant: 5),
            itemsStack.widthAnchor.constraint(equalToConstant: 35*6+8*5),
            itemsStack.heightAnchor.constraint(equalToConstant: 35),
            itemsStack.centerXAnchor.constraint(equalTo: itemsBackGroudView.centerXAnchor)
            ]
        )
        
        itemsBackGroudView.addSubview(itemsCountStack)
        NSLayoutConstraint.activate([
            itemsCountStack.topAnchor.constraint(equalTo: itemsBackGroudView.topAnchor, constant: 45),
            itemsCountStack.widthAnchor.constraint(equalToConstant: 35*6+8*5),
            itemsCountStack.heightAnchor.constraint(equalToConstant: 30),
            itemsCountStack.centerXAnchor.constraint(equalTo: itemsBackGroudView.centerXAnchor)
            ]
        )
        
        slowTimeCount = gameController.consumableItems[AllItemsAndMissions.allComsumableItems[0]]!
        
        loveCount = gameController.consumableItems[AllItemsAndMissions.allComsumableItems[1]]!
        
        whiteLightCount = gameController.consumableItems[AllItemsAndMissions.allComsumableItems[2]]!
        
        manyLovesCount = gameController.consumableItems[AllItemsAndMissions.allComsumableItems[3]]!
        
        angryCount = gameController.consumableItems[AllItemsAndMissions.allComsumableItems[4]]!
        
        fireCount = gameController.consumableItems[AllItemsAndMissions.allComsumableItems[5]]!
        
        
        view.addSubview(whiteLightView)
        NSLayoutConstraint.activate([
            whiteLightView.topAnchor.constraint(equalTo: view.topAnchor),
            whiteLightView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            whiteLightView.leftAnchor.constraint(equalTo: view.leftAnchor),
            whiteLightView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ]
        )
        view.bringSubviewToFront(whiteLightView)
        whiteLightView.alpha = 0
    }
    
    var hasExpandedItems = false
    
    @objc func expandItems(){
        if hasExpandedItems{
            UIView.animate(withDuration: 0.1, animations: {
                self.itemsBackGroudView.alpha = 0
            }) { (_) in
                self.hasExpandedItems = false
            }
            expandItemsButton.imageViewForButton!.image = expandItemsButton.imageViewForButton!.image?.withHorizontallyFlippedOrientation()
        }else{
            UIView.animate(withDuration: 0.1, animations: {
                self.itemsBackGroudView.alpha = 1
            }) { (_) in
                self.hasExpandedItems = true
            }
            expandItemsButton.imageViewForButton!.image = expandItemsButton.imageViewForButton!.image?.withHorizontallyFlippedOrientation()
        }
    }
    
    var whiteLightView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    @objc func slowTime(){
        if slowTimeCount > 0{
            dataCatagoryClass.dataType = .slowTime
            dataCatagoryClass.data = Data()
            sendData()
            let originalSpeed = sceneView.scene.physicsWorld.speed
            sceneView.scene.physicsWorld.speed = 0.5
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.sceneView.scene.physicsWorld.speed = originalSpeed
            }
            slowTimeCount -= 1
        }else{
            self.customAlertView = BluredShadowView(title: "You Don't Have This Item", message: "", buttonTitle: "OK", showCancel: false, buttonHandler: {
                return
            })
            view.addSubview(customAlertView!)
            customAlertView?.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    @objc func showLove(){
        if loveCount > 0{
            loveCount -= 1
            
            let node = emojiModels.childNode(withName: "love", recursively: true)!
            node.position = sceneView.pointOfView!.position + SCNVector3(0, 0.1, -0.3)
            node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
            sceneView.scene.rootNode.addChildNode(node)
            
            dataCatagoryClass.dataType = .love
            dataCatagoryClass.data = Data()
            sendData()
        }else{
            self.customAlertView = BluredShadowView(title: "You Don't Have This Item", message: "", buttonTitle: "OK", showCancel: false, buttonHandler: {
                return
            })
            view.addSubview(customAlertView!)
            customAlertView?.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    @objc func showWhiteLight(){
        if whiteLightCount > 0{
            whiteLightCount -= 1
            dataCatagoryClass.dataType = .whiteLight
            dataCatagoryClass.data = Data()
            sendData()
        }else{
            self.customAlertView = BluredShadowView(title: "You Don't Have This Item", message: "", buttonTitle: "OK", showCancel: false, buttonHandler: {
                return
            })
            view.addSubview(customAlertView!)
            customAlertView?.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    @objc func showManyLoves(){
        if manyLovesCount > 0{
            manyLovesCount -= 1
            sceneView.scene.rootNode.addParticleSystem(manyLovesParticle!)
            dataCatagoryClass.dataType = .manyLoves
            dataCatagoryClass.data = Data()
            sendData()
        }else{
            self.customAlertView = BluredShadowView(title: "You Don't Have This Item", message: "", buttonTitle: "OK", showCancel: false, buttonHandler: {
                return
            })
            view.addSubview(customAlertView!)
            customAlertView?.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    @objc func showAngry(){
        if angryCount > 0{
            angryCount -= 1
            let node = emojiModels.childNode(withName: "angry", recursively: true)!
            node.position = sceneView.pointOfView!.position + SCNVector3(0, 0.1, -0.3)
            node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
            sceneView.scene.rootNode.addChildNode(node)
            
            dataCatagoryClass.dataType = .angry
            dataCatagoryClass.data = Data()
            sendData()
        }else{
            self.customAlertView = BluredShadowView(title: "You Don't Have This Item", message: "", buttonTitle: "OK", showCancel: false, buttonHandler: {
                return
            })
            view.addSubview(customAlertView!)
            customAlertView?.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    lazy var bigFire:SCNParticleSystem = {
        let particle = effects.childNode(withName: "bigFire", recursively: false)?.particleSystems?.first
        return particle!
    }()
    
    let manyLovesParticle = SCNParticleSystem(named: "manyLoves", inDirectory: "Models.scnassets/Particle")
    
    
    @objc func addFire(){
        if fireCount > 0{
            fireCount -= 1
            let node = SCNNode()
            node.position = SCNVector3(0,-1,0)
            node.addParticleSystem(bigFire)
            sceneView.scene.rootNode.addChildNode(node)
            dataCatagoryClass.dataType = .fire
            dataCatagoryClass.data = Data()
            sendData()
        }else{
            self.customAlertView = BluredShadowView(title: "You Don't Have This Item", message: "", buttonTitle: "OK", showCancel: false, buttonHandler: {
                return
            })
            view.addSubview(customAlertView!)
            customAlertView?.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    func syncConsumableItem(at index: Int, to count:Int){
        gameController.consumableItems[AllItemsAndMissions.allComsumableItems[index]] = count
    }
    
    func handleMultiplayerToturial(){
        if self.gameController.timesOfGame[ToturialProgess.universal] == 0 || self.gameController.timesOfGame[ToturialProgess.basketballBasic] == 0{
            self.showAlert(title: "Please Complete A Single Player Game First",message: "Watch The Basic Toturial On How To Detect Surfaces",buttonTitle: "OK",showCancel: false, buttonHandler: { (_) in
                self.dismiss(animated: false)
            })
        }
        if self.gameController.timesOfGame[ToturialProgess.multiplayer] == 0{
            let tutorialVC = TutorialViewController(imagePrefixName: "multiplayer", imageEndIndex: 7, firstImageIndex: 1)
            tutorialVC.modalPresentationStyle = .overCurrentContext
            tutorialVC.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.present(tutorialVC,animated: true)
            }
        }else{
            self.shouldAddNewNotice = true
            self.showNoticeAndFade(notice: "Scan Your Floor Exclusively")
            self.shouldAddNewNotice = false
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.shouldAddNewNotice = true
                self.showNoticeAndFade(notice: "Hold Your Device Still When Your Friend Joins")
            }
        }
    }
    
    override func viewDidDismiss(tutorialVC: TutorialViewController) {
        if tutorialVC.imagePrefixName == "multiplayer"{
            self.gameController.timesOfGame[ToturialProgess.multiplayer] = (self.gameController.timesOfGame[ToturialProgess.multiplayer]! + 1)
            self.shouldAddNewNotice = true
            self.showNoticeAndFade(notice: "Scan Your Floor Exclusively")
            self.shouldAddNewNotice = false
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.shouldAddNewNotice = true
                self.showNoticeAndFade(notice: "Hold Your Device Still When Your Friend Joins")
            }
        }
    }
    
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
        if !isHost!{
            if shouldBeginGame{
                shootIntervalTimer+=0.017
            }
        }
    }
    
    override func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        if !isHost!{
            if camera.trackingState.localizedFeedbackForClient != ARCamera.TrackingState.limited(ARCamera.TrackingState.Reason.initializing).localizedFeedbackForClient{
                let message = camera.trackingState.localizedFeedbackForClient
                if message != ""{
                    showNoticeAndFade(notice: message)
                }
            }
        }else{
            super.session(session, cameraDidChangeTrackingState: camera)
        }
    }
    
    //MARK: data transfer
    func sendWorldMap(){
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: false)
                else { fatalError("can't encode map") }
            self.dataCatagoryClass.dataType = .worldMap
            self.dataCatagoryClass.data = data
            
            self.sendData()
        }
    }

    func sendData(){
        if (multiplayerSessionController?.connectedPeers.count)! > 0{
            guard let data = try? encoder.encode(dataCatagoryClass)
                else{fatalError("can't encode to PropertyList")}
            multiplayerSessionController?.sendToAllPeers(data)
        }
    }
    
    
    func receivedDataHandler(data: Data, peerID:MCPeerID){
        do{
            let dataClass = try decoder.decode(SendDataWithCatagoryManager.self, from: data)
            switch dataClass.dataType {
            case .initialRequestForWorldMap:
                sendWorldMap()
                DispatchQueue.main.async {
                    self.scoreLabelForTheOtherPlayer.isHidden = false
                    self.otherPlayerName = self.multiplayerSessionController?.connectedPeers.first?.displayName[0..<6] ?? "Player2"
                }
                if let data = try? encoder.encode(self.gameController.selectedItems.weather){
                    dataCatagoryClass.dataType = .weather
                    dataCatagoryClass.data = data
                    sendData()
                }
                if let data = try? encoder.encode(self.gameController.selectedItems){
                    dataCatagoryClass.dataType = .basketballSelection
                    dataCatagoryClass.data = data
                    sendData()
                }
                syncScore(score: score)
            case .worldMap:
                do{
                    if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: dataClass.data) {
                        // Run the session with the received world map.
                        let configuration = ARWorldTrackingConfiguration()
                        configuration.planeDetection = [.horizontal]
                        configuration.initialWorldMap = worldMap
                        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                        showNoticeAndFade(notice: "Find The Floor Your Friend Has Scaned")
                        worldMap.anchors.forEach({ (anchor) in
                            if anchor.name == goalAnchorName{
                                shouldBeginGame = true
                            }
                        })
                    }
                }catch{
                    showNoticeAndFade(notice: "An multiplayer connection error occured, please try again later")
                }
                if let data = try? encoder.encode(self.gameController.selectedItems){
                    dataCatagoryClass.dataType = .basketballSelection
                    dataCatagoryClass.data = data
                    sendData()
                }
            case .weather:
                if let weather = try? decoder.decode(ShopItem.self, from: dataClass.data){
                    let birthPlace = SCNNode()
                    
                    switch weather{
                    case AllItemsAndMissions.allItems[5]:
                        birthPlace.addParticleSystem(SCNParticleSystem(named: "rain", inDirectory: "Models.scnassets/Particle")!)
                        birthPlace.position = SCNVector3(0,3,0)
                    case AllItemsAndMissions.allItems[6]:
                        birthPlace.addParticleSystem(SCNParticleSystem(named: "star", inDirectory: "Models.scnassets/Particle")!)
                        birthPlace.position = SCNVector3(0,5,-10)
                    default:
                        return
                    }
                    sceneView.scene.rootNode.addChildNode(birthPlace)
                }
            case .basketballSelection:
                if let selection = try? decoder.decode(Selections.self, from: dataClass.data){
                    self.selectionsForOtherPlayer = selection
                }
            case .score:
                let receivedScore = dataClass.data.to(type: Int.self)
                scoreForTheOtherPlayer += receivedScore
            case .projectBasketBall:
                if let ballInfo = try? decoder.decode(BallBehavior.self, from: dataClass.data){
                    let ball = getBall(selection:self.selectionsForOtherPlayer)
                    //score detection depends on name, set the name to be defferent so friend's score don't count
                    ball.name = "friend's ball"
                    ball.position = ballInfo.position
                    ball.physicsBody?.applyForce(ballInfo.force, asImpulse: true)
                    ball.runAction(SCNAction.sequence([SCNAction.wait(duration: 5),SCNAction.removeFromParentNode()]))
                    sceneView.scene.rootNode.addChildNode(ball)
                    ballThrownForOtherPlayer += 1
                }else{
                    self.showNoticeAndFade(notice: "ball didn't sync")
                }
            case .leaveSession:
                if isHost!{
                    showNoticeAndFade(notice: "\(peerID.displayName) has left")
                }else{
                    self.showAlert(title: "The Host Has Left This Game", message: "Click Ok to go back to menu", buttonTitle: "Ok", showCancel: false) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            case .addGoal:
                print("added goal received")
                if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: dataClass.data){
                    sceneView.session.add(anchor: anchor)
                    
                    self.shouldBeginGame = true
                    self.showNoticeAndFade(notice: "Long Press To Shoot Ball")
                }else{
                    self.showAlert(title: "A Problem Occured When Connecting With The Host", message: "Please go back and connect again ", buttonTitle: "Go Back", showCancel: false) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            case .syncPinch:
                if dataClass.data.to(type: Bool.self){
                    setGoalToOutdoor()
                }else{
                    setGoalToIndoor()
                }
            //MARK: Magic Items
            case .whiteLight:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.whiteLightView.isHidden = false
                        self.whiteLightView.alpha = 1
                    }) { (_) in
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 2, delay: 3, options: UIView.AnimationOptions.curveEaseIn, animations: {
                                self.whiteLightView.alpha = 0
                            }, completion: { (_) in
                                self.whiteLightView.isHidden = true
                            })
                        }
                    }
                }
            case .slowTime:
                let originalSpeed = sceneView.scene.physicsWorld.speed
                sceneView.scene.physicsWorld.speed = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    self.sceneView.scene.physicsWorld.speed = originalSpeed
                }
            case .love:
                let node = emojiModels.childNode(withName: "love", recursively: true)!
                node.position = sceneView.pointOfView!.position + SCNVector3(0, 0.1, -0.3)
                node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
                sceneView.scene.rootNode.addChildNode(node)
            case .manyLoves:
                sceneView.scene.rootNode.addParticleSystem(manyLovesParticle!)
            case .fire:
                let node = SCNNode()
                node.position = SCNVector3(0,-1,0)
                node.addParticleSystem(bigFire)
                sceneView.scene.rootNode.addChildNode(node)
            case .angry:
                let node = emojiModels.childNode(withName: "angry", recursively: true)!
                node.position = sceneView.pointOfView!.position + SCNVector3(0, 0.1, -0.3)
                node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi/2, z: 0, duration: TimeInterval(3))))
                sceneView.scene.rootNode.addChildNode(node)
            default:
                break
            }
        }catch{
            showNoticeAndFade(notice: "An multiplayer connection error occured")
        }
    }
    //MARK:Setup
    override func setUpAndAddScoreLabel() {
        super.setUpAndAddScoreLabel()
        scoreLabel.label!.text = "You\n0"
    }
    
    func setUpAndAddScoreLabelForTheOtherPlayer(){
        view.addSubview(scoreLabelForTheOtherPlayer)
        scoreLabelForTheOtherPlayer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabelForTheOtherPlayer.widthAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabelForTheOtherPlayer.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -8).isActive = true
        scoreLabelForTheOtherPlayer.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
        scoreLabelForTheOtherPlayer.isHidden = true
    }
    
    override func back() {
        if isHost!{
            customAlertView = BluredShadowView(title: "Are You Sure To Leave", message: "If you leave now, your friend will be forced to leave", buttonTitle: "Leave Game", showCancel: true, buttonHandler: { [unowned self] in
                if self.multiplayerSessionController?.connectedPeers.count == 0{
                    self.getScoreView(game: GameToPresentOptions.basketballFree, score: 0)
                    transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                    self.backButton.isUserInteractionEnabled = false
                    return
                }
                self.getScoreView(game: GameToPresentOptions.basketballFree, score: self.score, scoreForTheOtherPlayer: self.scoreForTheOtherPlayer)
                transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                self.backButton.isUserInteractionEnabled = false
                self.dataCatagoryClass.dataType = .leaveSession
                self.dataCatagoryClass.data = Data()
                self.sendData()
                self.multiplayerSessionController?.session.disconnect()
            })
            view.addSubview(customAlertView!)
            customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
        }else{
            customAlertView = BluredShadowView(title: "Are you sure to finish the game?", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: {
                self.getScoreView(game: GameToPresentOptions.basketballFree, score: self.score, scoreForTheOtherPlayer: self.scoreForTheOtherPlayer)
                transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                self.backButton.isUserInteractionEnabled = false
                self.dataCatagoryClass.dataType = .leaveSession
                self.dataCatagoryClass.data = Data()
                self.sendData()
                self.multiplayerSessionController?.session.disconnect()
            })
            view.addSubview(customAlertView!)
            customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
        }
    }
    
    //MARK:Sync actions
    override func addGoalAnchor(recog: UILongPressGestureRecognizer) {
        if recog.state == .began{
            if !isHost!{
                customAlertView = BluredShadowView(title: "Only Host Can Add Goal", message: "Ask the host to add a goal and you will also see it and play", buttonTitle: "Yes", showCancel: false, buttonHandler: {
                    self.customAlertView?.removeFromSuperview()
                })
                view.addSubview(customAlertView!)
                customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
            }else{
                if multiplayerSessionController?.connectedPeers.count == 1{
                    super.addGoalAnchor(recog: recog)
                }else{
                    customAlertView = BluredShadowView(title: "Please Wait For Your Friend To Join", message: "If you don't want to wait, you can leave this game and go to single player mode", buttonTitle: "Leave Game", showCancel: true, buttonHandler: {
                        self.back()
                    })
                    view.addSubview(customAlertView!)
                    customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
                }
            }
        }
    }
    
    override func syncBallShooting(position: SCNVector3, force: SCNVector3) {
        let ballInfo = BallBehavior(postion: position, force: force,orientation:SCNVector3(0,0,0))
        //allow for errors when ball behaviors can't sync
        if let data = try? encoder.encode(ballInfo){
            dataCatagoryClass.dataType = .projectBasketBall
            dataCatagoryClass.data = data
            sendData()
        }else{
            showNoticeAndFade(notice: "A network issue occured")
        }
    }
    
    override func syncScore(score: Int) {
        dataCatagoryClass.dataType = .score
        let data = Data(from: score)
        dataCatagoryClass.data = data
        sendData()
    }
    
    override func syncGoal(with anchor: ARAnchor) {
        //allow for errors when ball behaviors can't sync but remind the players to restart
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: false){
            dataCatagoryClass.dataType = .addGoal
            dataCatagoryClass.data = data
            sendData()
        }else{
            self.showAlert(title: "A Problem Occured When Connecting With The Host", message: "Please go back and connect again ", buttonTitle: "Go Back", showCancel: false) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func syncPinch(scaleUp: Bool) {
        dataCatagoryClass.dataType = .syncPinch
        let data = Data(from: scaleUp)
        dataCatagoryClass.data = data
        sendData()
    }
    
    override func proceedGoal(with node: SCNNode) {
        super.proceedGoal(with: node)
        switch mode {
        case .basketballTimeLimited:
            countDownTimer.perform { [unowned self] () -> NextStep in
                if self.timeLeft <= 0{
                    self.sceneView.session.pause()
                    self.getScoreView(game: GameToPresentOptions.basketballTimeLimited, score: self.score, scoreForTheOtherPlayer: self.scoreForTheOtherPlayer)
                    transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                    self.backButton.isUserInteractionEnabled = false
                    self.multiplayerSessionController?.session.disconnect()
                    return .stop
                }
                self.timeLeft -= 1
                return .continue
            }
        default:
            break
        }
        
    }
    
    var otherPlayerHasShotAllBalls = false
    
    var selfHasShotAllBalls = false
    
    override func shootBall() {
        if mode == .basketballBallLimited{
            if ballThrown < maximumBalls{
                super.shootBall()
                ballThrown += 1
            }
        }else{
            super.shootBall()
        }
    }
    
    deinit {
        multiplayerSessionController?.advertiser.stop()
        countDownTimer.stop()
    }
    
}

//for time mode and ball mode
extension MultiPlayerPlayBasketballFreeMode{
    func setUpCountDownLabel(){
        switch mode {
        case .basketballTimeLimited:
            countDownLabel.text = "Time\n\(maxGameTime)"
        case .basketballBallLimited:
            countDownLabel.text = "Balls\n\(maximumBalls)"
        default:
            return
        }
        
        view.addSubview(countDownLabel)
        countDownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        countDownLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        countDownLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        countDownLabel.topAnchor.constraint(equalTo: view.topAnchor, constant:100).isActive = true
    }
}
