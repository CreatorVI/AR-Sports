//
//  RootPongViewController.swift
//  AR tests
//
//  Created by Yu Wang on 1/19/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import Foundation

class RootPongViewController: RootPlayViewController,TutorialViewControllerDelegate {
    var bat = SCNNode()
    
    var singlePlayer = false
    
    var shouldAddBall = true
    
    var shouldReceiveBall = false
    
    lazy var ball: SCNNode = {
        let sphereGeo = SCNSphere(radius: 0.02)
        sphereGeo.segmentCount = 96
        let ball = SCNNode(geometry: sphereGeo)
        
        
        ball.name = "pong ball"
        
        //physics
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.02), options: nil))
        ball.physicsBody?.categoryBitMask = catagory.pongBall.rawValue
        ball.physicsBody?.contactTestBitMask = catagory.pongRoom.rawValue | catagory.pongRoom.rawValue | catagory.pongRightTable.rawValue | catagory.pongLeftTable.rawValue
        ball.physicsBody?.collisionBitMask = catagory.pongTable.rawValue | catagory.pongBat.rawValue
        ball.physicsBody?.mass = 0.003
        ball.physicsBody?.restitution = 1
        
        //        collisionDetectingAreaForBall = SCNNode()
        //        collisionDetectingAreaForBall.name = "collision area"
        //        collisionDetectingAreaForBall.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.03), options: nil))
        //        collisionDetectingAreaForBall.physicsBody?.categoryBitMask = catagory.pongBallCollisionArea.rawValue
        //        collisionDetectingAreaForBall.physicsBody?.contactTestBitMask = catagory.pongBat.rawValue
        //        collisionDetectingAreaForBall.physicsBody?.collisionBitMask = catagory.non.rawValue
        //
        //        ball.addChildNode(collisionDetectingAreaForBall)
        
        return ball
    }()
    
    var ballsToClear = [SCNNode]()
    
//    var collisionDetectingAreaForBall = SCNNode()
    
    var tableAnchor:ARAnchor?
    
    var tableAnchorTransform:simd_float4x4?
    
    var tableAnchorName = "table anchor"
    
    var shouldHitBall = false
    
    var hasHittedLeftTable = false
    
    var deadLineTimer:Float = 0
    
    var deadLine:Float = 3
    
    var shouldDeadLineTimerBegin = false
    
    override func setUpAndAddScoreLabel() {
        return
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        sceneView.scene.physicsWorld.speed = 0.8
        
        modeLabel.text = "Pong"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.gameController.timesOfGame[ToturialProgess.universal] == 0{
            let tutorialVC = TutorialViewController(imagePrefixName: "universal", imageEndIndex: 4, firstImageIndex: 1)
            tutorialVC.modalPresentationStyle = .overCurrentContext
            tutorialVC.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.present(tutorialVC,animated: true)
            }
        }else{
            self.animateMiddleText("Find A Floor")
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
                    self.shouldAddNewNotice = false
                    self.gameController.timesOfGame[ToturialProgess.universal] = (self.gameController.timesOfGame[ToturialProgess.universal]! + 1)
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.shouldAddNewNotice = true
                self.showNoticeAndFade(notice: "Long Press To Shoot Ball")
                self.shouldAddNewNotice = false
                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                    self.shouldAddNewNotice = true
                    self.showNoticeAndFade(notice: "Stand Up, The Table Is 1.5 Meters High")
                    self.shouldAddNewNotice = false
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        self.shouldAddNewNotice = true
                        self.showNoticeAndFade(notice: "Look Upward To Shoot Higher")
                        self.shouldAddNewNotice = false
                        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                            self.shouldAddNewNotice = true
                            self.showNoticeAndFade(notice: "Press For About 0.5 Second To Get Best Result")
                            self.shouldAddNewNotice = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                                self.shouldAddNewNotice = true
                                self.showNoticeAndFade(notice: "Hit The Ball With Your Device")
                                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                                    self.animateMiddleText("You Can Use The Slider On The Right To Adjust Table Height")
                                    self.gameController.timesOfGame[ToturialProgess.pongBasic] = (self.gameController.timesOfGame[ToturialProgess.pongBasic]! + 1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var timer:Float = 0
    
    var shouldTimerBegin = false
    
    var shouldSyncTransform = true
    
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
        
        //        collisionDetectingAreaForBall.position = ball.position
        if let currentFrame = sceneView.session.currentFrame{
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.1
            bat.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
            if shouldSyncTransform{
                syncBatPosition(transform: bat.simdTransform)
                shouldSyncTransform = false
            }else{
                shouldSyncTransform = true
            }
        }
        if shouldTimerBegin{
            timer += Float(0.0002)
        }
//        if shouldDeadLineTimerBegin{
//            deadLineTimer += 1/60
//            if deadLineTimer > deadLine{
//                shouldDeadLineTimerBegin = false
//                deadLineTimer = 0
//                shouldAddBall = true
//                animateMiddleText()
//                ballsToClear.forEach { (node) in
//                    node.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0)
//                    node.physicsBody = nil
//                }
//                ballsToClear.removeAll()
//            }
//        }
    }
    
    
    
    func syncBatPosition(transform:simd_float4x4){
        
    }
    
    @objc func addBall(recog:UILongPressGestureRecognizer){
        switch recog.state{
        case .began:
            shouldTimerBegin = true
        case .ended,.cancelled:
            shouldTimerBegin = false
            shootBall()
            timer = 0
        default:
            break
        }
    }
    
    func getBall() -> SCNNode{
        return ball.clone()
    }
    
    lazy var dragon = effects.childNode(withName: "pongDragon", recursively: false)!.childNode(withName: "dragon", recursively: false)
    
    lazy var fire = effects.childNode(withName: "pongFire", recursively: false)?.childNode(withName: "particles", recursively: false)?.particleSystems?.first
    
    lazy var lava = effects.childNode(withName: "pongLava", recursively: false)?.childNode(withName: "particles", recursively: false)?.particleSystems?.first
        
    private func shootBall(){
        //        if shouldAddBall{
        let ball = getBall()
        
        guard let pointOfView = sceneView.pointOfView else{return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation/9
        ball.position = position
        let force = SCNVector3(orientation.x*timer, orientation.y*timer, orientation.z*timer)
        ball.physicsBody?.applyForce(force, asImpulse: true)
        
        switch gameController.selectedItems.pongSelection.name{
        case ShopItemsName.basicPingPong:
            ball.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        case ShopItemsName.orangePingPong:
            ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        default:
            break
        }
        
        var particle: SCNParticleSystem?
        var node: SCNNode?
        switch gameController.selectedItems.pongEffect.name {
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
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                node.runAction(SCNAction.sequence([SCNAction.move(to: location + orientation, duration: 1),SCNAction.fadeOut(duration: 1),SCNAction.removeFromParentNode()]))
                node.enumerateChildNodes { (node, _) in
                    node.runAction(SCNAction.sequence([SCNAction.wait(duration: 1),SCNAction.fadeOut(duration: 1),SCNAction.removeFromParentNode()]))
                }
                let currentPosition = node.position
                node.look(at: location + orientation*2)
                node.simdLocalRotate(by: simd_quatf(angle: Float.pi/2, axis: float3(0, -1, 0)))
                node.worldPosition = currentPosition + ball.worldPosition
                self.sceneView.scene.rootNode.addChildNode(node)
            }
            if noticeOfDragonEffectCount < 2{
                self.showNoticeAndFade(notice: "The dragon effect might cause low game performance")
                noticeOfDragonEffectCount += 1
            }
        }
        
        sceneView.scene.rootNode.addChildNode(ball)
//        shouldAddBall = false
        syncBall(position: position, force: force, orientation:orientation)
        
        //        }
    }
    
    var noticeOfDragonEffectCount = 0
    
    func syncBall(position:SCNVector3,force:SCNVector3,orientation:SCNVector3){
        
    }
    
    private func setUp(){
        //Physics
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, -2.5, 0)
        
        //gesture
        let recog = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(recog:)))
        recog.minimumPressDuration = 0.01
        sceneView.addGestureRecognizer(recog)
        
        setUpBat()
        setUpRoom()
    }
    
    
    
    private func setUpRoom(){
        let floor = SCNNode(geometry: SCNBox(width: 100, height: 0.05, length: 100, chamferRadius: 0))
        floor.name = "room"
        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0)
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 100, height: 0.05, length: 100, chamferRadius: 0), options: nil))
        floor.physicsBody?.categoryBitMask = catagory.pongRoom.rawValue
        floor.physicsBody?.contactTestBitMask = catagory.pongBall.rawValue
        floor.physicsBody?.collisionBitMask = catagory.non.rawValue
        floor.physicsBody?.isAffectedByGravity = false
        floor.position = SCNVector3(0, -2, 0)
        sceneView.scene.rootNode.addChildNode(floor)
    }
    
    func setUpWall(){
        let wall = SCNNode(geometry: SCNBox(width: 1.9, height: 2.5, length: 0.1, chamferRadius: 0.01))
        wall.name = "wall"
        wall.geometry?.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        wall.geometry?.firstMaterial?.isDoubleSided = true
        wall.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNBox(width: 1.9, height: 3, length: 0.1, chamferRadius: 0.01), options: nil))
        wall.physicsBody?.categoryBitMask = catagory.pongTable.rawValue
        wall.physicsBody?.contactTestBitMask = catagory.non.rawValue
        wall.physicsBody?.collisionBitMask = catagory.pongBall.rawValue
        wall.physicsBody?.isAffectedByGravity = false
        wall.physicsBody?.restitution = 1.1
        wall.position = SCNVector3(-0.09, 0.97, -1.11)
        sceneView.scene.rootNode.childNode(withName: "table body", recursively: true)?.addChildNode(wall)
    }
    
    func syncTable(with anchor:ARAnchor){
        //
    }
    
    private func setUpBat(){
        bat = SCNNode(geometry: SCNPlane(width: 0.3, height: 0.2))
        bat.name = "bat"
        bat.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0)
        bat.geometry?.firstMaterial?.isDoubleSided = true
        bat.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNPlane(width: 0.3, height: 0.2), options: nil))
        bat.physicsBody?.categoryBitMask = catagory.pongBat.rawValue
        bat.physicsBody?.contactTestBitMask = catagory.pongBall.rawValue | catagory.pongBallCollisionArea.rawValue
        bat.physicsBody?.collisionBitMask = catagory.pongBall.rawValue | catagory.pongTable.rawValue
        bat.physicsBody?.isAffectedByGravity = false
        bat.physicsBody?.restitution = 1.1
        sceneView.scene.rootNode.addChildNode(bat)
    }
    
    @objc func handleTap(recog:UILongPressGestureRecognizer){
        proceedTap(shouldShootBall: shouldBeginGame, recog: recog)
    }
    
    func proceedTap(shouldShootBall:Bool,recog:UILongPressGestureRecognizer){
        if shouldShootBall{
            if isFirstShoot{
                isFirstShoot = false
            }else{
                addBall(recog: recog)
            }
        }else{
            addGoalAnchor(recog: recog)
        }
    }
    
    func addGoalAnchor(recog:UILongPressGestureRecognizer){
        if let sceneView = recog.view as? ARSCNView{
            let hitTestResult = sceneView.smartHitTest(recog.location(in: sceneView))
            if let hitTestResult = hitTestResult{
                //get position
                let position = hitTestResult.worldTransform.columns.3
                //rotate so it faces the user
                let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
                //make anchor position to be tapped position and rotate it toward the user
                let anchorTransform = simd_float4x4().combinePositionAndRotation(position: position, rotation: rotate)
                self.tableAnchorTransform = anchorTransform
                self.tableAnchor = ARAnchor(name: tableAnchorName, transform: anchorTransform)
                //add goal anchor
                sceneView.session.add(anchor: tableAnchor!)
                syncTable(with: tableAnchor!)
                //set game events
                shouldBeginGame = true
                
            }else{
                if planeDetceted{
                    showNoticeAndFade(notice: "Set It Within The Plane")
                }else{
                    showNoticeAndFade(notice: "Plane With Context Is More Detectable, Try Putting A Paper With Text Or A Book On The Ground")
                }
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.name == "pong ball" && contact.nodeB.name == "room"{
            contact.nodeA.removeFromParentNode()
        }else if contact.nodeB.name == "pong ball" && contact.nodeA.name == "room"{
            contact.nodeB.removeFromParentNode()
        }
//        if contact.nodeA.name == "pong ball" || contact.nodeB.name == "pong ball"{
//            if contact.nodeA.name == "room" || contact.nodeB.name == "room"{
//                sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
//                    if node.name == "pong ball"{
//                        node.removeFromParentNode()
//                    }
//                }
//                shouldAddBall = true
 //               animateMiddleText()
                
//            }else if contact.nodeA.name == "left table" || contact.nodeB.name == "left table"{
//                hasHittedLeftTable = true
//                shouldDeadLineTimerBegin = true
//                sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
//                    if node.name == "pong ball"{
//                        ballsToClear.append(node)
//                    }
//                }
//                shouldAddBall = false
//            }else if contact.nodeA.name == "right table" || contact.nodeB.name == "right table"{
//                if hasHittedLeftTable{
//                    shouldAddBall = false
//                    shouldDeadLineTimerBegin = false
//                    deadLineTimer = 0
//                    score+=1
//                    hasHittedLeftTable = false
//                }else{
//                    shouldAddBall = false
//                    shouldDeadLineTimerBegin = true
//                    sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
//                        if node.name == "pong ball"{
//                            ballsToClear.append(node)
//                            node.removeFromParentNode()
//                            node.physicsBody = nil
//                            node.name = "ball to clear"
//                        }
//                    }
//                    animateMiddleText()
//                }
//            }
//        }
    }
    
    override func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        super.renderer(renderer, didAdd: node, for: anchor)
        
        //check if the anchor is goal anchor
        if anchor.name == "table anchor"{
            // save the reference to the virtual object anchor when the anchor is added from relocalizing
            if tableAnchor == nil {
                tableAnchor = anchor
                tableAnchorTransform = anchor.transform
            }
            //node's world position is 000
            node.simdTransform = anchor.transform
            proceedTable(with: node)
        }
    }
    
    var tableRootNode = SCNNode()
    var tableBodyNode = SCNNode()
//    var rightTableNode = SCNNode()
//    var leftTableNode = SCNNode()
    
    private func proceedTable(with node:SCNNode){
        guard let scene = SCNScene(named: "Models.scnassets/PingPong/PingPongTable.scn") else{return}
        let rootNode = scene.rootNode
        
        //set nodes
        self.tableRootNode = rootNode
        self.tableBodyNode = rootNode.childNode(withName: "TableObject", recursively: true)!
//        self.rightTableNode = rootNode.childNode(withName: "RightTable", recursively: true)!
//        self.leftTableNode = rootNode.childNode(withName: "LeftTable", recursively: true)!
        
        tableBodyNode.name = "table body"
//        rightTableNode.name = "right table"
//        leftTableNode.name = "left table"
        
        
        
//        rightTableNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: rightTableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        rightTableNode.physicsBody?.categoryBitMask = catagory.pongRightTable.rawValue
//        rightTableNode.physicsBody?.contactTestBitMask = catagory.pongBall.rawValue
//        rightTableNode.physicsBody?.collisionBitMask = catagory.non.rawValue
//        rightTableNode.physicsBody?.isAffectedByGravity = false
//
//        leftTableNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: leftTableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
//        leftTableNode.physicsBody?.categoryBitMask = catagory.pongLeftTable.rawValue
//        leftTableNode.physicsBody?.contactTestBitMask = catagory.pongBall.rawValue
//        leftTableNode.physicsBody?.collisionBitMask = catagory.non.rawValue
//        leftTableNode.physicsBody?.isAffectedByGravity = false
        
        
        //remove plane indicator
        focusSquare.removeFromParentNode()
        
        //MARK: Need Test
        if singlePlayer{
            guard let pointOfView = sceneView.pointOfView else{return}
            let transform = pointOfView.transform
            tableRootNode.position = SCNVector3(-transform.m31, 0, -transform.m33)
            setUpWall()
        }else{
            rootNode.childNode(withName: "field", recursively: false)?.removeFromParentNode()
            rootNode.childNode(withName: "drag", recursively: false)?.removeFromParentNode()
        }
        

        //set physics
        setTablePhysics()
        
        if gameController.timesOfGame[ToturialProgess.pongBasic] == 0{
            let tutorialVC = TutorialViewController(imagePrefixName: "pong", imageEndIndex: 2, firstImageIndex: 1)
            tutorialVC.modalPresentationStyle = .overCurrentContext
            tutorialVC.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.present(tutorialVC,animated: true)
            }
        }
        
        
        node.addChildNode(tableRootNode)
        if singlePlayer{
            setUpWall()
        }
        
        setUpSlider()
    }
    
    func setTablePhysics(){
        tableBodyNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: tableBodyNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        tableBodyNode.physicsBody?.categoryBitMask = catagory.pongTable.rawValue
        tableBodyNode.physicsBody?.contactTestBitMask = catagory.non.rawValue
        tableBodyNode.physicsBody?.collisionBitMask = catagory.pongBall.rawValue
        tableBodyNode.physicsBody?.restitution = 0.9
        tableBodyNode.physicsBody?.isAffectedByGravity = false
    }
    
    let slider = UISlider()
    
    func setUpSlider() {
        
        self.slider.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        slider.center = CGPoint(x: view.frame.width-32, y: view.frame.height-200)
        
        slider.minimumTrackTintColor = .black
        slider.maximumTrackTintColor = .clear
        slider.thumbTintColor = #colorLiteral(red: 0.01895777691, green: 0.5901213515, blue: 1.965498935e-16, alpha: 1)
        
        slider.maximumValue = 1
        slider.minimumValue = 0
        slider.setValue(1, animated: false)
        
        slider.addTarget(self, action: #selector(adjustHeight), for: UIControl.Event.valueChanged)
        
        self.view.addSubview(slider)
        slider.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
    }
    
    @objc func adjustHeight(){
        tableBodyNode.position.y = slider.value-1
        setTablePhysics()
        syncTableHeight(sliderValue: slider.value)
    }
    
    func syncTableHeight(sliderValue:Float){
        //sync
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.verticalSizeClass == .compact{
            slider.center = CGPoint(x: view.frame.width-88, y: view.frame.height-150)
        }else{
            slider.center = CGPoint(x: view.frame.width-32, y: view.frame.height-150)
        }
    }
    
    override func back() {
        customAlertView = BluredShadowView(title: "Are you sure to finish the game?", message: "", buttonTitle: "Yes", showCancel: true, buttonHandler: {
            self.getScoreView(game: GameToPresentOptions.pongSinglePlayer, score: self.score)
            transtitionView(self.scoreView, withDuration: 0.5, upWard: true)
            self.backButton.isUserInteractionEnabled = false
        })
        view.addSubview(customAlertView!)
        customAlertView!.setUpConstrantsIfIsUsedAsAlertView()
    }
}

