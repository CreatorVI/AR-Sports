//
//  RootPlayViewController.swift
//  AR tests
//
//  Created by Yu Wang on 1/11/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import ReplayKit
import Each

/// Main catagory for all games. Used for physics bitmasks.
enum catagory:Int{
    case basketball = 1
    case goal = 2
    case upperChecker = 3
    case lowerChecher = 4
    
//    case poolTable = 10
//    case poolCue = 11
//    case poolBall = 12
    
    case pongBat = 20
    case pongTable = 21
    case pongBall = 22
    case pongBallCollisionArea = 23
    case pongRoom = 24
    case pongRightTable = 25
    case pongLeftTable = 26
    case pongNet = 27
    
    case arrow = 30
    case bow = 31
    case archeryTargetBody = 32
    case archeryTargetRings = 33
    
    case non = 100
}

/// The root play view controller to all ar games with back button, notice label and settings button. All subclasses will auto detect planes and set the shouldBeginGame parameter to true after detecting planes. Occlusion is defined here.
class RootPlayViewController: UIViewController,ARSCNViewDelegate,SCNPhysicsContactDelegate,ARSessionDelegate,RPPreviewViewControllerDelegate {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return UIInterfaceOrientationMask.all
        }
    }
    
    var shouldAddNewNotice = true
    
    unowned var gameController:RootGameController
    
    var planeDetceted = false
    
    var numberOfTriesToSetGoal = 0
    
    var shouldEnablePointDetetion = false
    
    var sceneView:ARSCNView = ARSCNView()
    
    var shouldBeginGame = false
    
    var backButton = BluredShadowView(title: "Finish",corner:CGFloat(30),fontSize:16)
    
    var scoreView = ScoreView()
    
    var customAlertView:BluredShadowView?
    
    var previewView = ImageAndVideoHandlingView()
    
    var recorder = RPScreenRecorder.shared()
    
    var videoRecordedPreviewController = [RPPreviewViewController]()
    
    lazy var widgetButtonsStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [helpButton,showFeaturePointsButton,recordVideoButton,screenShotButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    var showFeaturePointsButton = BluredShadowView(image: #imageLiteral(resourceName: "molecular-bond"))
    
    var recordVideoButton:BluredShadowView = {
        let view = BluredShadowView(image: #imageLiteral(resourceName: "videoRecording"))
        view.whiteMask!.backgroundColor = UIColor.red
        return view
    }()
    
    var screenShotButton = BluredShadowView(image: #imageLiteral(resourceName: "screenShot"))
    
    var helpButton = BluredShadowView(image: #imageLiteral(resourceName: "questionMarkWhite"))
    
    var settingsButton:UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "settings-work-tool"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).withAlphaComponent(0)
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    var noticeLabel:NoticePaddingLabel = {
        let label = NoticePaddingLabel()
        label.layer.cornerRadius = 8
        return label
    }()
    
    var modeLabel:NoticePaddingLabel = {
        let label = NoticePaddingLabel()
        label.bottomInset = 12
        label.topInset = 12
        label.leftInset = 24
        label.rightInset = 24
        label.font = getFont(withSize: 24)
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        return label
    }()
    
    var scoreLabel:BluredShadowView = {
        let label = BluredShadowView(title: "score\n0")
        label.label?.contentMode = .scaleToFill
        label.label?.textAlignment = .center
        label.label?.font = getFont(withSize: 20)
        return label
    }()
    
    var score:Int = 0{
        didSet{
            DispatchQueue.main.async {
                self.scoreLabel.label!.text = "score\n\(self.score)"
            }
        }
    }
    
    
    func setUpAndAddScoreLabel(){
        sceneView.addSubview(scoreLabel)
        scoreLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: sceneView.leftAnchor, constant: 8).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
    }
    
    
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
    
    func setUPMiddleLabel(){
        sceneView.addSubview(middleNoticeLabel)
        NSLayoutConstraint.activate([
            middleNoticeLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            middleNoticeLabel.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor)
            ]
        )
        middleNoticeLabel.alpha = 0
    }
    
    init(gameController:RootGameController){
        self.gameController = gameController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //for UX when finding surface
    var focusSquare = FocusSquare()
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var session: ARSession {
        return sceneView.session
    }
    
    let updateQueue = DispatchQueue(label: "com.example.artests.serialSceneKitQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        setUPSceneView()
        setupCamera()
//        sceneView.debugOptions = [.showPhysicsFields]
        setUpAndAddScoreLabel()
        setUpAndAddBackButton()
        setUpAndAddNoticeLabel()
        setUpAndAddModeLabel()
        setUpAndAddSettingButton()
        setUpWidgetButtonsStack()
        setUPMiddleLabel()
        timerSinceStartGame.perform { () -> NextStep in
            self.timeSinceStartGame += 1
            return .continue
        }
        addWeather()
        getEffectsScene()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the `ARSession`.
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerSinceStartGame.stop()
        sceneView.session.pause()
    }
    
    func updateFocusSquare() {
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
                if !self.planeDetceted{
                    self.showNoticeAndFade(notice: "Tap And Place")
                    self.planeDetceted = true
                }
            }
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
        }
    }
    
    var emojiModels = SCNNode()
    
    func getEffectsScene(){
        if let scene = SCNScene(named: "Models.scnassets/Particle/Effects.scn"){
            DispatchQueue.global(qos: .userInitiated).async {
                self.effects = scene.rootNode.childNode(withName: "effects", recursively: true)!
                self.emojiModels = scene.rootNode.childNode(withName: "emojis", recursively: true)!
            }
        }
    }
    
    
    
    func addWeather(){
        let birthPlace = SCNNode()
        
        switch gameController.selectedItems.weather{
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
    
    /// Clear all tracking data and anchors
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    func animateMiddleText(_ text:String){
        middleNoticeLabel.text = text
        self.sceneView.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.middleNoticeLabel.alpha = 1
            }, completion: { (_) in
                UIView.animate(withDuration: 3, delay: 3, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.middleNoticeLabel.alpha = 0
                }, completion: nil)
            })
        }
    }
    
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        let message = camera.trackingState.localizedFeedbackForHost
        if message != ""{
            showNoticeAndFade(notice: message)
        }
        if camera.trackingState.localizedFeedbackForHost == ARCamera.TrackingState.limited(.excessiveMotion).localizedFeedbackForHost{
            excessiveMotionNoticceCount += 1
            if excessiveMotionNoticceCount > 10{
                animateMiddleText("If you can't find AR objects, finish game and try again")
            }
        }
    }
    
    var excessiveMotionNoticceCount = 0
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate {
                self.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 100)
            } else {
                self.enableEnvironmentMapWithIntensity(25)
            }
            if !self.shouldBeginGame{
                self.updateFocusSquare()
            }
        }
    }
    
    var effects = SCNNode()
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor{
            if !shouldBeginGame{
//                showNoticeAndFade(notice: "Plane Detected")
                planeDetceted = true
            }
                let planeNode = setUpSurroundingDetection(anchor: anchor)
                node.addChildNode(planeNode)
            //            syncAnchor(with: node, for: anchor)
        }
        
    }
    
//    func syncAnchor(with node:SCNNode,for anchor:ARAnchor){
//        
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor{
            node.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
            let planeNode = setUpSurroundingDetection(anchor: anchor)
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            node.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
        }
    }
    
    func setUpAndAddScoreView(){
        view.addSubview(scoreView)
        scoreView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        scoreView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        scoreView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 50).isActive = true
        scoreView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setUpAndAddPreviewView(){
        view.addSubview(previewView)
        previewView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        previewView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        previewView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 50).isActive = true
        previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setUpSurroundingDetection(anchor:ARPlaneAnchor)->SCNNode{
        var planeNode = SCNNode()
        //transform setting
        planeNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        planeNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        //physics collision
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: planeNode, options: nil))
        //MARK: occlusion
        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor.white
        maskMaterial.colorBufferWriteMask = []
        
        // occlude (render) from both sides please
        maskMaterial.isDoubleSided = true
        //assign material
        planeNode.geometry?.firstMaterial? = maskMaterial
        planeNode.categoryBitMask = 0
        return planeNode
    }
    
    lazy var widgetButtonsShimmerStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [helpButtonShimmer,showFeaturePointsButtonShimmer,recordVideoButtonShimmer,screenShotButtonShimmer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    lazy var showFeaturePointsButtonShimmer = ShimmerViewForWidgetButton(corner:showFeaturePointsButton.cornerR)
    
    lazy var recordVideoButtonShimmer = ShimmerViewForWidgetButton(corner:recordVideoButton.cornerR)
    
    lazy var screenShotButtonShimmer = ShimmerViewForWidgetButton(corner:screenShotButton.cornerR)
    
    lazy var helpButtonShimmer = ShimmerViewForWidgetButton(corner:helpButton.cornerR)
    
    func setUpWidgetButtonsStack(){
        view.addSubview(widgetButtonsStack)
        if UIScreen.main.bounds.width < 400{
            NSLayoutConstraint.activate([
                widgetButtonsStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 190),
                widgetButtonsStack.heightAnchor.constraint(equalToConstant: 156),
                widgetButtonsStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-12),
                widgetButtonsStack.widthAnchor.constraint(equalToConstant: 30),
                ]
            )
        }else{
            NSLayoutConstraint.activate([
                widgetButtonsStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 190),
                widgetButtonsStack.heightAnchor.constraint(equalToConstant: 196),
                widgetButtonsStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-12),
                widgetButtonsStack.widthAnchor.constraint(equalToConstant: 40),
                ]
            )
        }
        showFeaturePointsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFeaturePoints)))
        
        recordVideoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recordVideo)))
        
        screenShotButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(screenShot)))
        
        helpButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showHelpViewController)))
        
        view.addSubview(widgetButtonsShimmerStack)
        if UIScreen.main.bounds.width < 400{
            NSLayoutConstraint.activate([
                widgetButtonsShimmerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 190),
                widgetButtonsShimmerStack.heightAnchor.constraint(equalToConstant: 156),
                widgetButtonsShimmerStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-12),
                widgetButtonsShimmerStack.widthAnchor.constraint(equalToConstant: 30),
                ]
            )
        }else{
            NSLayoutConstraint.activate([
                widgetButtonsShimmerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 190),
                widgetButtonsShimmerStack.heightAnchor.constraint(equalToConstant: 196),
                widgetButtonsShimmerStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-12),
                widgetButtonsShimmerStack.widthAnchor.constraint(equalToConstant: 40),
                ]
            )
        }
        
        addGradientLayer(view: view, on: helpButtonShimmer, duration: 6, delayInMilliseconds: 0)
        addGradientLayer(view: view, on: showFeaturePointsButtonShimmer, duration: 6, delayInMilliseconds: 300)
        addGradientLayer(view: view, on: recordVideoButtonShimmer, duration: 6, delayInMilliseconds: 600)
        addGradientLayer(view: view, on: screenShotButtonShimmer, duration: 6, delayInMilliseconds: 900)
    }
    
    @objc func showHelpViewController(){
        let vc = HelpViewController()
        vc.modalPresentationStyle = .overCurrentContext
         present(vc, animated: true, completion: nil)
    }
    
    lazy var isFeaturePointsShown = sceneView.debugOptions.contains(SCNDebugOptions.showFeaturePoints)
    
    @objc func showFeaturePoints(){
        if isFeaturePointsShown{
            sceneView.debugOptions.remove(.showFeaturePoints)
            isFeaturePointsShown = false
        }else{
            sceneView.debugOptions.insert(.showFeaturePoints)
            isFeaturePointsShown = true
        }
    }
    
    var isFirstShoot = true
    
    var isRecording = false
    
    var videoThumbnals = [UIImage]()
    
    @objc func recordVideo(){
        if !isRecording{
            recorder.startRecording { (error) in
                if let error = error{
                    self.showNoticeAndFade(notice: error.localizedDescription)
                }else{
                    DispatchQueue.main.async {
                        self.recordVideoButton.whiteMask!.backgroundColor = UIColor.red
                    }
                    self.isRecording = true
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
                            self.recordVideoButton.whiteMask!.alpha = 0.8
                        }, completion: nil)
                    }
                    self.showNoticeAndFade(notice: "Video Start Recording")
                }
            }
        }else{
            self.recordVideoButton.whiteMask!.alpha = 0
            self.recordVideoButton.whiteMask!.layer.removeAllAnimations()
            self.isRecording = false
            recorder.stopRecording { (previewVC, error) in
                if let error = error{
                    self.showNoticeAndFade(notice: error.localizedDescription)
                }else{
                    if let previewVC = previewVC{
                        self.videoRecordedPreviewController.append(previewVC)
                        self.videoRecordedPreviewController.last!.previewControllerDelegate = self
                        self.showNoticeAndFade(notice: "Video Stop Recording. Remember To View It After Game To Save")
                        let image = self.sceneView.snapshot()
                        self.videoThumbnals.append(image)
                    }
                }
            }
        }
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
    
    var screenShots = [UIImage]()
    
    @objc func screenShot(){
        //Create the UIImage
        let image = sceneView.snapshot()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        screenShots.append(image)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
                self.screenShotButton.whiteMask!.alpha = 0.8
            }, completion: { (_) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
                    self.screenShotButton.whiteMask!.alpha = 0
                }, completion: nil)
            })
        }
        showNoticeAndFade(notice: "Screen Shot Saved To Album")
    }
   
    func setUpAndAddBackButton(){
        view.addSubview(backButton)
        backButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
    }
    
    func setUpAndAddSettingButton(){
        view.addSubview(settingsButton)
        settingsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
    }
    
    func setUpAndAddNoticeLabel(){
        view.addSubview(noticeLabel)
        noticeLabel.preferredMaxLayoutWidth = 300
        noticeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noticeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        noticeLabel.isHidden = true
    }
    
    func setUpAndAddModeLabel(){
        view.addSubview(modeLabel)
        modeLabel.preferredMaxLayoutWidth = 200
        modeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        modeLabel.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: -6).isActive = true
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
    }
    weak var menuViewController:MenuViewController?
    
    var timeSinceStartGame = 0
    
    let timerSinceStartGame = Each.init(1).seconds
    
    @objc func back(){
        
    }
    
    var hasPreviewed = false
    
    func getScoreView(game:GameToPresentOptions,score:Int,scoreForTheOtherPlayer:Int? = nil) {
        sceneView.session.pause()
        let highScore = gameController.highScores[game] ?? 0
        if highScore < score{
            gameController.highScores[game] = score
        }
        gameController.timesOfPlayingGameNotTutorial[game] = gameController.timesOfPlayingGameNotTutorial[game]! + 1
        scoreView = ScoreView(score: game == .pongSinglePlayer ? nil : score,timeOfPlay:self.timeSinceStartGame/30,highScore:gameController.highScores[game] ?? 0, okAction: {
            if !self.hasPreviewed && (self.videoRecordedPreviewController.count > 0 || self.screenShots.count > 0){
                self.previewView = ImageAndVideoHandlingView(videoThumbnails: self.videoThumbnals, previewControllers: self.videoRecordedPreviewController, images: self.screenShots, okAction: {
                    transtitionView(self.previewView, withDuration: 0.5, upWard: false)
                    self.hasPreviewed = true
                }, shareSuccessAction: {
                    self.showAlert(title: "Great, You Have Successfully Shared The Image", message: "You Get 2 Gems For Sharing", buttonTitle: "Done", showCancel: true, buttonHandler: { (_) in
                        self.gameController.gems += 2
                        self.gameController.rawGems += 2
                    })
                })
                self.setUpAndAddPreviewView()
                transtitionView(self.previewView, withDuration: 0.5, upWard: true)
            }else{
                self.dismiss(animated: false)
            }
        }, friendsScore: scoreForTheOtherPlayer)
        if let scoreForTheOtherPlayer = scoreForTheOtherPlayer{
            if score < scoreForTheOtherPlayer{
                gameController.loseTimes += 1
            }else if score == scoreForTheOtherPlayer{
                gameController.drawTimes += 1
            }else{
                gameController.winTimes += 1
            }
        }
        setUpAndAddScoreView()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.menuViewController?.sceneView.session.run(ARWorldTrackingConfiguration())
        super.dismiss(animated: flag, completion: completion)
    }
    
    @objc func openSettings(){
        //not implemented
        showHelpViewController()
    }
    
    /**
        Show a stretchable notice label on the bottom of the screen
        - Duration: Stay for 3 seconds and fade in 1 seconds
        - Parameter notice: notice to give to users
     */
    func showNoticeAndFade(notice:String){
        if shouldAddNewNotice{
            DispatchQueue.main.async {
                self.noticeLabel.isHidden = false
                self.noticeLabel.text = notice
                self.noticeLabel.font = getFont(withSize: 24)
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                UIView.animate(withDuration: 1, animations: {
                    self.noticeLabel.isHidden = true
                })
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }
}
