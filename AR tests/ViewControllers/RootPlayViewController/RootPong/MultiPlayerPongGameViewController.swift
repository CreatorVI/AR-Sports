//
//  MultiPlayerPongGameViewController.swift
//  AR tests
//
//  Created by Yu Wang on 2/5/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import Each
import MultipeerConnectivity

class MultiPlayerPongGameViewController: RootPongViewController {

    var isHost:Bool?
    
    var batForOtherPlayer:SCNNode = {
        let bat = SCNNode(geometry: SCNBox(width: 0.3, height: 0.2, length: 0.02, chamferRadius: 0.008))
        bat.name = "bat for other player"
        bat.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bat.geometry?.firstMaterial?.isDoubleSided = true
        bat.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNBox(width: 0.3, height: 0.2, length: 0.02, chamferRadius: 0), options: nil))
        bat.physicsBody?.categoryBitMask = catagory.pongBat.rawValue
        bat.physicsBody?.contactTestBitMask = catagory.pongBall.rawValue
        bat.physicsBody?.collisionBitMask = catagory.pongBall.rawValue
        bat.physicsBody?.isAffectedByGravity = false
        bat.physicsBody?.restitution = 1.1
        return bat
    }()
    
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
    
    var addScoreForOther = BluredShadowView(image: #imageLiteral(resourceName: "25304"))
    
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
    
    override func setUpAndAddScoreLabel() {
        view.addSubview(scoreLabel)
        scoreLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: sceneView.leftAnchor, constant: 8).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
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
    
    
    //MARK: for multuplayer pong selection
    var pongBallForOtherPlayer = Selections()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modeLabel.text = "Multiplayer"
        
        setUpAndAddScoreLabelForTheOtherPlayer()
        setUpAndAddAddScoreButton()
        encoder.outputFormat = .binary
        
        
        //multiplayer
        multiplayerSessionController!.showNotification = showNoticeAndFade
        multiplayerSessionController!.receivedDataHandler = receivedDataHandler(data:peerID:)
        multiplayerSessionController!.sendData = sendData
        if isHost!{
            //check user's experience
            self.handleMultiplayerToturial()
            
            multiplayerSessionController!.advertiser.start()
            multiplayerSessionController!.sendWorldMap = sendWorldMap
            multiplayerSessionController!.isHost = true
            multiplayerSessionController?.advertiser.start()
        }else{
            multiplayerSessionController!.sendData()
            scoreLabelForTheOtherPlayer.isHidden = false
            multiplayerSessionController!.isHost = false
            otherPlayerName = multiplayerSessionController?.connectedPeers.first?.displayName[0..<6] ?? "Player2"
            addScoreForOther.isHidden = false
        }
        score = 0
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
            expandItemsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            expandItemsButton.widthAnchor.constraint(equalToConstant: 40),
            expandItemsButton.heightAnchor.constraint(equalToConstant: 40),
            expandItemsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
            ]
        )
        expandItemsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandItems)))
        
        view.addSubview(itemsBackGroudView)
        NSLayoutConstraint.activate([
            itemsBackGroudView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
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
        if self.gameController.timesOfGame[ToturialProgess.universal] == 0 || self.gameController.timesOfGame[ToturialProgess.pongBasic] == 0{
            self.showAlert(title: "Please Complete A Single Player Game First",message: "Watch The Basic Toturial On How To Play",buttonTitle: "OK",showCancel: false, buttonHandler: { (_) in
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
        self.shouldAddNewNotice = false
        if tutorialVC.imagePrefixName == "multiplayer"{
            self.shouldAddNewNotice = true
            self.showNoticeAndFade(notice: "Scan Your Floor Exclusively")
            self.shouldAddNewNotice = false
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.shouldAddNewNotice = true
                self.showNoticeAndFade(notice: "Hold Your Device Still When Your Friend Joins")
                self.gameController.timesOfGame[ToturialProgess.multiplayer] = (self.gameController.timesOfGame[ToturialProgess.multiplayer]! + 1)
            }
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
        guard let data = try? encoder.encode(dataCatagoryClass)
            else{fatalError("can't encode to PropertyList")}
        multiplayerSessionController?.sendToAllPeers(data)
    }
    
    func receivedDataHandler(data: Data, peerID:MCPeerID){
        do{
            let dataClass = try decoder.decode(SendDataWithCatagoryManager.self, from: data)
            switch dataClass.dataType {
            
            case .initialRequestForWorldMap:
                sendWorldMap()
                DispatchQueue.main.async {
                    self.scoreLabelForTheOtherPlayer.isHidden = false
                    self.addScoreForOther.isHidden = false
                    self.otherPlayerName = self.multiplayerSessionController?.connectedPeers.first?.displayName[0..<6] ?? "Player2"
                }
                if let data = try? encoder.encode(self.gameController.selectedItems.weather){
                    dataCatagoryClass.dataType = .weather
                    dataCatagoryClass.data = data
                    sendData()
                }
                if let data = try? encoder.encode(self.gameController.selectedItems){
                    dataCatagoryClass.dataType = .pongBallSelection
                    dataCatagoryClass.data = data
                    sendData()
                }
                sceneView.scene.rootNode.addChildNode(batForOtherPlayer)
                animateMiddleText("Remember To Add Score For The Other Player")
            case .worldMap:
                do{
                    if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: dataClass.data) {
                        // Run the session with the received world map.
                        let configuration = ARWorldTrackingConfiguration()
                        configuration.planeDetection = [.horizontal]
                        configuration.initialWorldMap = worldMap
                        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                        showNoticeAndFade(notice: "Find The Floor Your Friend Has Scaned")
                        sceneView.scene.rootNode.addChildNode(batForOtherPlayer)
                        animateMiddleText("Remember To Add Score For The Other Player")
                    }
                }catch{
                    showNoticeAndFade(notice: "An multiplayer connection error occured, please try again later")
                }
                if let data = try? encoder.encode(self.gameController.selectedItems){
                    dataCatagoryClass.dataType = .pongBallSelection
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
            case .pongBallSelection:
                if let selection = try? decoder.decode(Selections.self, from: dataClass.data){
                    self.pongBallForOtherPlayer = selection
                }
            case .score:
                score += 1
                
            case .leaveSession:
                if isHost!{
                    showNoticeAndFade(notice: "\(peerID.displayName) has left")
                }else{
                    customAlertView = BluredShadowView(title: "The Host Has Left This Game", message: "Click Ok to go back to menu", buttonTitle: "OK", showCancel: false, buttonHandler: {
                        self.getScoreView(game: GameToPresentOptions.pongSinglePlayer, score: self.score)
                        transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                        self.backButton.isUserInteractionEnabled = false
                    })
                    view.addSubview(customAlertView!)
                    customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
                }
            case .syncBat:
                let transformForOthersBat = dataClass.data.to(type: simd_float4x4.self)
                batForOtherPlayer.simdTransform = transformForOthersBat
            case .syncPingPongBall:
                if let ballInfo = try? decoder.decode(BallBehavior.self, from: dataClass.data){
                    let ball = getBall()
                    switch pongBallForOtherPlayer.pongSelection.name{
                    case ShopItemsName.basicPingPong:
                        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                    case ShopItemsName.orangePingPong:
                        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
                    default:
                        break
                    }
                    ball.position = ballInfo.position
                    var particle: SCNParticleSystem?
                    var node: SCNNode?
                    switch pongBallForOtherPlayer.pongEffect.name {
                    case .pongLavaEffect:
                        particle = lava
                    case .pingpongBallFireEffect:
                        particle = fire
                    case .pongDragonEffect:
                        node = dragon?.clone()
                    default:
                        break
                    }
                    
                    
                    if let particle = particle{
                        ball.addParticleSystem(particle)
                    }
                    if let node = node{
                        node.runAction(SCNAction.sequence([SCNAction.move(to: ballInfo.position + ballInfo.orientation, duration: 1),SCNAction.fadeOut(duration: 1),SCNAction.removeFromParentNode()]))
                        node.enumerateChildNodes { (node, _) in
                            node.runAction(SCNAction.sequence([SCNAction.wait(duration: 1),SCNAction.fadeOut(duration: 1),SCNAction.removeFromParentNode()]))
                        }
                        let currentPosition = node.position
                        node.look(at: ballInfo.position + ballInfo.orientation*2)
                        node.simdLocalRotate(by: simd_quatf(angle: Float.pi/2, axis: float3(0, -1, 0)))
                        node.worldPosition = currentPosition + ball.worldPosition
                        sceneView.scene.rootNode.addChildNode(node)
                    }
                    ball.physicsBody?.applyForce(ballInfo.force, asImpulse: true)
                    sceneView.scene.rootNode.addChildNode(ball)
                }
            case .syncTable:
                
                if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: dataClass.data){
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        self.sceneView.session.add(anchor: anchor)
                        self.showNoticeAndFade(notice: "Long Press To Shoot Ball")
                        self.shouldBeginGame = true
                    }
                    
                }else{
                    self.showAlert(title: "A Problem Occured When Connecting With The Host", message: "Please go back and connect again ", buttonTitle: "Go Back", showCancel: false) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
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
    
    override func syncBatPosition(transform: simd_float4x4) {
        if (multiplayerSessionController?.connectedPeers.count)! >= 1{
            dataCatagoryClass.dataType = .syncBat
            let data = Data(from: transform)
            dataCatagoryClass.data = data
            sendData()
        }
    }
    
    ////////////////// ovveriide!
    func syncScore() {
        dataCatagoryClass.dataType = .score
        let data = Data(from: Int(1))
        dataCatagoryClass.data = data
        sendData()
    }
    
    override func setUpWall(){
        return
    }
    
    override func syncBall(position: SCNVector3, force: SCNVector3, orientation:SCNVector3) {
        let ballInfo = BallBehavior(postion: position, force: force,orientation:orientation)
        //allow for errors when ball behaviors can't sync
        if let data = try? encoder.encode(ballInfo){
            dataCatagoryClass.dataType = .syncPingPongBall
            dataCatagoryClass.data = data
            sendData()
        }else{
            showNoticeAndFade(notice: "A network issue occured")
        }
    }
    
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
    
    override func syncTable(with anchor: ARAnchor) {
        //allow for errors when ball behaviors can't sync but remind the players to restart
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: false){
            dataCatagoryClass.dataType = .syncTable
            dataCatagoryClass.data = data
            sendData()
        }else{
            self.showAlert(title: "A Problem Occured When Connecting With The Host", message: "Please go back and connect again ", buttonTitle: "Go Back", showCancel: false) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func syncTableHeight(sliderValue: Float) {
        slider.value = sliderValue
        tableBodyNode.position.y = slider.value-1
        setTablePhysics()
    }
    
    override func back() {
        if isHost!{
            customAlertView = BluredShadowView(title: "Are You Sure To Leave", message: "If you leave now, your friend will be forced to leave", buttonTitle: "Leave Game", showCancel: true, buttonHandler: {
                if self.multiplayerSessionController?.connectedPeers.count == 0{
                    self.getScoreView(game: GameToPresentOptions.pong, score: 0)
                    transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
                    self.backButton.isUserInteractionEnabled = false
                    return
                }
                self.getScoreView(game: GameToPresentOptions.pong, score: self.score, scoreForTheOtherPlayer: self.scoreForTheOtherPlayer)
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
                self.getScoreView(game: GameToPresentOptions.pong, score: self.score, scoreForTheOtherPlayer: self.scoreForTheOtherPlayer)
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
    
    func setUpAndAddScoreLabelForTheOtherPlayer(){
        view.addSubview(scoreLabelForTheOtherPlayer)
        scoreLabelForTheOtherPlayer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabelForTheOtherPlayer.widthAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabelForTheOtherPlayer.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -8).isActive = true
        scoreLabelForTheOtherPlayer.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
        scoreLabelForTheOtherPlayer.isHidden = true
    }
    
    func setUpAndAddAddScoreButton(){
        view.addSubview(addScoreForOther)
        addScoreForOther.heightAnchor.constraint(equalToConstant: 60).isActive = true
        addScoreForOther.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addScoreForOther.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -80).isActive = true
        addScoreForOther.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
        addScoreForOther.isHidden = true
        addScoreForOther.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addScore)))
    }
    
    @objc func addScore(){
        scoreForTheOtherPlayer += 1
        syncScore()
    }
}
