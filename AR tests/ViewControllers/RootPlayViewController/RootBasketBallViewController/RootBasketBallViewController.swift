//
//  rootBasketBallViewController.swift
//  AR tests
//
//  Created by Yu Wang on 1/11/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import Each

class RootBasketBallViewController: RootPlayViewController,TutorialViewControllerDelegate {
    
    //the root basketball goal with checkers node
    var rootBasketballGoalNode:SCNNode?
    var basketGoalNode:SCNNode?
    var upperChecker:SCNNode?
    var lowerChecher:SCNNode?
    var radialGravityFieldNode:SCNNode?
    var dragFieldNode:SCNNode?
    var linearGravityFieldNode:SCNNode?
    
    //
    let goalOutdoorScale = SCNVector3(0.7,0.7,0.7)
    let goalIndoorScale = SCNVector3(0.5,0.5,0.5)
    let ballIndoorSize = SCNVector3(1, 1, 1)
    let ballOutdoorSize = SCNVector3(1.4, 1.4, 1.4)
    var isIndoorMode = false
    
    let lowerCheckerIndoorPosition = SCNVector3(0, 1.9, 0.35)
    let upperCheckerIndoorPosition = SCNVector3(0, 2.2, 0.35)
    let lowerCheckerOutdoorPosition = SCNVector3(0, 2.65, 0.4)
    let upperCheckerOutdoorPosition = SCNVector3(0, 3, 0.4)
    
    let checherIndoorScale = SCNVector3(0.1,0.1,0.1)
    let checherOutdoorScale = SCNVector3(0.2,0.2,0.2)
    
    
    //for force calculation
    var powerTimer = Each.init(0.01).seconds
    var power:Float = 1
    
    //MARK:for checking if the ball scores usage
    var upperContacted = false
    var lowerContacted = false
    
    var contactNode1:SCNNode?
    var contactNode2:SCNNode?
    
    var lastDetectedBall:SCNNode?
    var goalPosition:SCNVector3?
    var goalAnchorTransform:simd_float4x4?
    
    //shoot interval default 1s
    let shootInterval = 1.0
    var shootIntervalTimer = -1.0
    var shootTimer = Each.init(1).seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tap for setting the basket and for shoot
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(recog:)))
        longPressGestureRecognizer.minimumPressDuration = 0.01
        sceneView.addGestureRecognizer(longPressGestureRecognizer)
        sceneView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(didPinch(recog:))))
        //add score label to every basketball game
        handleUniversalToturial()
        sceneView.scene.physicsWorld.speed = 0.9
    }
    
    func handleUniversalToturial(){
        if self.gameController.timesOfGame[ToturialProgess.universal] == 0{
            let tutorialVC = TutorialViewController(imagePrefixName: "universal", imageEndIndex: 4, firstImageIndex: 1)
            tutorialVC.modalPresentationStyle = .overCurrentContext
            tutorialVC.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.present(tutorialVC,animated: true)
            }
        }else{
            self.shouldAddNewNotice = true
            self.animateMiddleText("Find A Floor")
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.animateMiddleText("You Can Pinch The Basketball Goal")
            }
        }
    }
    
    func viewDidDismiss(tutorialVC: TutorialViewController) {
        shouldAddNewNotice = false
        if tutorialVC.imagePrefixName == "universal"{
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.animateMiddleText("Find A Floor")
                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                    self.shouldAddNewNotice = true
                    self.showNoticeAndFade(notice: "Tap To Place")
                }
            }
            
            self.gameController.timesOfGame[ToturialProgess.universal] = (self.gameController.timesOfGame[ToturialProgess.universal]! + 1)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.shouldAddNewNotice = true
                self.showNoticeAndFade(notice: "Long Press To Shoot Ball")
                self.shouldAddNewNotice = false
                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                    self.shouldAddNewNotice = true
                    self.showNoticeAndFade(notice: "Look Upward To Shoot Higher")
                    self.shouldAddNewNotice = false
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        self.shouldAddNewNotice = true
                        self.showNoticeAndFade(notice: "Try Making The Basket A Little Higher Than Screen Center And Press For 0.5 Seconds")
                        self.shouldAddNewNotice = false
                        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                            self.shouldAddNewNotice = true
                            self.showNoticeAndFade(notice: "You Can Pinch The Basketball Goal")
                            self.gameController.timesOfGame[ToturialProgess.basketballBasic] = (self.gameController.timesOfGame[ToturialProgess.basketballBasic]! + 1)
                        }
                    }
                }
            }
            
        }
    }
    
    @objc func didPinch(recog:UIPinchGestureRecognizer){
        handlePinch(recog: recog)
    }
    
    func handlePinch(recog:UIPinchGestureRecognizer){
        if shouldBeginGame{
            if recog.state == .changed{
                if basketGoalNode!.scale == goalIndoorScale{
                    if recog.scale > 1.2{
                        setGoalToOutdoor()
                        syncPinch(scaleUp: true)
                    }
                }else{
                    if recog.scale < 0.8{
                        setGoalToIndoor()
                        syncPinch(scaleUp: false)
                    }
                }
            }
        }
    }
    
    func setGoalToOutdoor(){
        basketGoalNode?.scale = goalOutdoorScale
        lowerChecher?.position = lowerCheckerOutdoorPosition
        upperChecker?.position = upperCheckerOutdoorPosition
        lowerChecher?.scale = checherOutdoorScale
        upperChecker?.scale = checherOutdoorScale
        
        radialGravityFieldNode?.position = upperCheckerOutdoorPosition+SCNVector3(0, 0.1, 0)
        dragFieldNode?.position = upperCheckerOutdoorPosition
        linearGravityFieldNode?.position = upperCheckerOutdoorPosition+SCNVector3(0, 0.2, 0)
        
        setPhysicsForGoalAndChecker()
        
        isIndoorMode = false
        showNoticeAndFade(notice: "Outdoor Mode, the goal is now 3 meters high")
    }
    
    func setGoalToIndoor(){
        basketGoalNode?.scale = goalIndoorScale
        lowerChecher?.position = lowerCheckerIndoorPosition
        upperChecker?.position = upperCheckerIndoorPosition
        lowerChecher?.scale = checherIndoorScale
        upperChecker?.scale = checherIndoorScale
        
        radialGravityFieldNode?.position = upperCheckerIndoorPosition+SCNVector3(0, 0.1, 0)
        dragFieldNode?.position = upperCheckerIndoorPosition
        linearGravityFieldNode?.position = upperCheckerIndoorPosition+SCNVector3(0, 0.15, 0)
        
        setPhysicsForGoalAndChecker()
        
        isIndoorMode = true
        showNoticeAndFade(notice: "Indoor Mode, the goal is now 2 meters high")
    }
    
    func syncPinch(scaleUp:Bool){
        //
    }
    
    private func setPhysicsForGoalAndChecker(){
        basketGoalNode!.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basketGoalNode!, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        lowerChecher?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: lowerChecher!, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        upperChecker?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: upperChecker!, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        basketGoalNode!.physicsBody?.categoryBitMask = catagory.goal.rawValue
        basketGoalNode!.physicsBody?.contactTestBitMask = catagory.non.rawValue
        basketGoalNode!.physicsBody?.collisionBitMask = catagory.basketball.rawValue
        basketGoalNode!.physicsBody?.restitution = 0.2
        
        //add physics body to checkers
        upperChecker!.physicsBody?.categoryBitMask = catagory.upperChecker.rawValue
        upperChecker!.physicsBody?.contactTestBitMask = catagory.basketball.rawValue
        upperChecker!.physicsBody?.collisionBitMask = catagory.non.rawValue
        
        lowerChecher!.physicsBody?.categoryBitMask = catagory.lowerChecher.rawValue
        lowerChecher!.physicsBody?.contactTestBitMask = catagory.basketball.rawValue
        lowerChecher!.physicsBody?.collisionBitMask = catagory.non.rawValue
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.name == "basketball"{
            if contact.nodeB.name == "lowerChecker"{
                contactNode1 = contact.nodeA
                contactNode2 = contact.nodeB
                if contactNode1 === lastDetectedBall{
                    lowerContacted = true
                }else{
                    upperContacted = false
                    lowerContacted = false
                    return
                }
            }else if contact.nodeB.name == "upperChecker"{
                contactNode1 = contact.nodeA
                contactNode2 = contact.nodeB
                upperContacted = true
                lastDetectedBall = contactNode1
            }
        }else if contact.nodeA.name == "lowerChecker"{
            if contact.nodeB.name == "basketball"{
                contactNode1 = contact.nodeB
                contactNode2 = contact.nodeA
                if contactNode1 === lastDetectedBall{
                    lowerContacted = true
                }else{
                    upperContacted = false
                    lowerContacted = false
                    return
                }
            }
        }else if contact.nodeA.name == "upperChecker"{
            if contact.nodeB.name == "basketball"{
                contactNode1 = contact.nodeB
                contactNode2 = contact.nodeA
                upperContacted = true
                lastDetectedBall = contactNode1
            }
        }
        
        if upperContacted&&lowerContacted{
            if contactNode1?.name == "basketball" && contactNode2?.name == "lowerChecker"{
                let factoredScore = calculateDistance()
                score += factoredScore
                if factoredScore == 0{
                    showNoticeAndFade(notice: "Stand at least 1 meter from the goal to get points \n The points you gain every time is equal to your distance from the goal")
                }
                upperContacted = false
                lowerContacted = false
                lastDetectedBall = nil
                syncScore(score: factoredScore)
            }
        }
    }
    
    func syncScore(score: Int){
        
    }
    
    private func calculateDistance()->Int{
        let userPos = sceneView.pointOfView!.position
        if let pos = goalPosition{
            let distance = sqrt((pos.x-userPos.x)*(pos.x-userPos.x)+(pos.y-userPos.y)*(pos.y-userPos.y)+(pos.z-userPos.z)*(pos.z-userPos.z))
            return Int(Darwin.floor(distance))
        }
        return 0
    }
    
    @objc func handleTap(recog:UILongPressGestureRecognizer){
        proceedTap(shouldShootBall: shouldBeginGame, recog: recog)
    }
    
    func proceedTap(shouldShootBall:Bool,recog:UILongPressGestureRecognizer){
        numberOfTriesToSetGoal += 1
        if shouldShootBall{
            if isFirstShoot{
                isFirstShoot = false
            }else{
                proceedShootBall(recog: recog)
            }
        }else{
            addGoalAnchor(recog: recog)
        }
    }
    
    func addGoalAnchor(recog:UILongPressGestureRecognizer){
        if let sceneView = recog.view as? ARSCNView{
            //MARK: Using smart hit test
            let hitTestResult = sceneView.smartHitTest(recog.location(in: sceneView))
            if let hitTestResult = hitTestResult{
                //get position
                let position = hitTestResult.worldTransform.columns.3
                //rotate so it faces the user
                let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
                //make anchor position to be tapped position and rotate it toward the user
                let anchorTransform = simd_float4x4().combinePositionAndRotation(position: position, rotation: rotate)
                self.goalAnchorTransform = anchorTransform
                goalAnchor = ARAnchor(name: goalAnchorName, transform: anchorTransform)
                //add goal anchor
                sceneView.session.add(anchor: goalAnchor!)
                syncGoal(with: goalAnchor!)
                //set game events
                shouldBeginGame = true
                
            }else{
                if numberOfTriesToSetGoal <= 3{
                    animateMiddleText("Surface Not Constructed Yet")
                }else{
                    if planeDetceted{
                        //                        showNoticeAndFade(notice: "Set It Within The Plane")
                    }else{
                        showNoticeAndFade(notice: "Plane With Context Is More Detectable, Try Putting A Paper With Text Or A Book On The Ground")
                    }
                }
            }
        }
    }
    
    func syncGoal(with anchor:ARAnchor){
        //
    }
    
    var goalAnchorName = "goalAnchorName"
    
    var goalAnchor:ARAnchor?
    
    override func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        super.renderer(renderer, didAdd: node, for: anchor)
        //check if the anchor is goal anchor
        guard anchor.name == goalAnchorName
            else { return }
        
        // save the reference to the virtual object anchor when the anchor is added from relocalizing
        if goalAnchor == nil {
            goalAnchor = anchor
            goalAnchorTransform = anchor.transform
        }
        //node's world position is 000
        node.simdTransform = anchor.transform
        proceedGoal(with: node)
    }
    
    func proceedGoal(with node:SCNNode){
        //get scene
        let scene = SCNScene(named: "basket.scn", inDirectory: "Models.scnassets", options: nil)!
        let basketballGoalRootNode = scene.rootNode
        
        //        basketballGoalRootNode.simdWorldTransform = goalAnchorTransform!
        self.rootBasketballGoalNode = basketballGoalRootNode
        
        //get the goal
        let basketballGoalNode = basketballGoalRootNode.childNode(withName: "_0488_basketball_goal_v1", recursively: true)!
        basketballGoalNode.name = "goal"
        self.basketGoalNode = basketballGoalNode
        
        //get chechers
        let upperCheckerNode = basketballGoalRootNode.childNode(withName: "upperChecker", recursively: true)!
        upperCheckerNode.name = "upperChecker"
        let lowerCheckerNode = basketballGoalRootNode.childNode(withName: "lowerChecker", recursively: true)!
        lowerCheckerNode.name = "lowerChecker"
        
        self.upperChecker = upperCheckerNode
        self.lowerChecher = lowerCheckerNode
        
        self.radialGravityFieldNode = basketballGoalRootNode.childNode(withName: "field", recursively: false)
        self.radialGravityFieldNode?.physicsField = basketballGoalRootNode.childNode(withName: "field", recursively: false)?.physicsField!
        
        self.dragFieldNode = basketballGoalRootNode.childNode(withName: "drag", recursively: false)
        self.dragFieldNode?.physicsField = basketballGoalRootNode.childNode(withName: "drag", recursively: false)?.physicsField!
        
        self.linearGravityFieldNode = basketballGoalRootNode.childNode(withName: "linear", recursively: false)
        self.linearGravityFieldNode?.physicsField = basketballGoalRootNode.childNode(withName: "linear", recursively: false)?.physicsField!
        
        
        //add physics body based on the shape of the basketball goal
        setPhysicsForGoalAndChecker()
        //add the goal and checker to the node associated with the goal anchor
        node.addChildNode(basketballGoalRootNode)
        //remove plane indicator
        focusSquare.removeFromParentNode()
        
        syncShootTimer()
        //bug
        goalPosition = basketballGoalRootNode.position
        
        if gameController.timesOfGame[ToturialProgess.basketballBasic] == 0{
            let tutorialVC = TutorialViewController(imagePrefixName: "basketball", imageEndIndex: 2, firstImageIndex: 1)
            tutorialVC.modalPresentationStyle = .overCurrentContext
            tutorialVC.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.present(tutorialVC,animated: true)
            }
        }
    }
    
    
    
    func syncShootTimer(){
        shootTimer.perform { () -> NextStep in
            self.shootIntervalTimer += 1
            return .continue
        }
    }
    
    func proceedShootBall(recog:UILongPressGestureRecognizer){
        switch recog.state{
        case .began:
            powerTimer.perform { () -> NextStep in
                self.power+=0.15
                return .continue
            }
        case .ended,.cancelled:
            powerTimer.stop()
            shootBall()
            power = 1
        default:
            break
        }
    }
    
    func getBall(selection:Selections? = nil)->SCNNode{
        var selectedItems:Selections
        if selection == nil{
            selectedItems = gameController.selectedItems
        }else{
            selectedItems = selection!
        }
        var ball = SCNNode()
        
        switch selectedItems.basketBallSelection.name{
        case .basicBasketBallSkin:
            ball = SCNNode(geometry: SCNSphere(radius: isIndoorMode ? 0.1 : 0.14))
            ball.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "basketballTexture")
        case .basketballNBASkin:
            if let scene = SCNScene(named: "Models.scnassets/basketball/ball.dae"){
                ball = scene.rootNode.childNode(withName: "basketball", recursively: false)!
                
                ball.scale = isIndoorMode ? SCNVector3(0.2,0.2,0.2) : SCNVector3(0.3,0.3,0.3)
            }
        case .basketballGoldSkin:
            if let scene = SCNScene(named: "Models.scnassets/basketball/goldenBall.dae"){
                ball = scene.rootNode.childNode(withName: "basketball", recursively: false)!
                
                ball.scale = isIndoorMode ? SCNVector3(0.2,0.2,0.2) : SCNVector3(0.3,0.3,0.3)
            }
        default:
            fatalError("selected Items randomized!")
            
        }
        
        ball.name = "basketball"
        //physics
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: isIndoorMode ? 0.1 : 0.14), options: nil))
        ball.physicsBody?.categoryBitMask = catagory.basketball.rawValue
        ball.physicsBody?.contactTestBitMask = catagory.upperChecker.rawValue | catagory.lowerChecher.rawValue
        ball.physicsBody?.collisionBitMask = catagory.goal.rawValue
        ball.physicsBody?.restitution = 0.2
        ball.physicsBody?.rollingFriction = 0.3
        ball.physicsBody?.mass = 1
        
        var particle: SCNParticleSystem?
        switch selectedItems.basketBallEffect.name {
        case .basketballFireEffect:
            particle = fire
            particle?.emitterShape = SCNSphere(radius: isIndoorMode ? 0.12 : 0.16)
        case .basketballMagicEffect:
            particle = smoke
            particle?.emitterShape = SCNSphere(radius: isIndoorMode ? 0.12 : 0.16)
        default:
            break
        }
        
        if let particle = particle{
            ball.addParticleSystem(particle)
        }
        
        //make sure the ball disappears later
        ball.runAction(SCNAction.sequence([SCNAction.wait(duration: 5),SCNAction.removeFromParentNode()]))
        return ball
        
    }
    
    lazy var fire = effects.childNode(withName: "fire", recursively: false)!.childNode(withName: "particles", recursively: false)?.particleSystems?.first
    
    lazy var smoke = SCNParticleSystem(named: "smoke.scnp", inDirectory: "Models.scnassets/Particle")!
    
    func shootBall(){
        //        if shootIntervalTimer >= shootInterval{
        guard let point = sceneView.pointOfView else {
            return
        }
        //            shootIntervalTimer = 0
        
        //constructing initial position of the ball
        let transform = point.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation/6
        
        //construct a ball
        let ball = getBall()
        ball.position = position
        
        //shoot with force
        let force = SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power)
        ball.physicsBody?.applyForce(force, asImpulse: true)
        syncBallShooting(position: position, force: force)
        //add ball
        sceneView.scene.rootNode.addChildNode(ball)
        //        }else{
        //            showNoticeAndFade(notice: "Please Wait For 1 Second")
        //        }
    }
    
    func syncBallShooting(position:SCNVector3,force:SCNVector3){
        //implement in multiplayer basketball game
    }
    
    
    
    deinit {
        powerTimer.stop()
        shootTimer.stop()
    }
    
}
