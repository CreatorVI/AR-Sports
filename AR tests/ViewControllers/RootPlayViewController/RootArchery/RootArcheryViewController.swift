//
//  RootArcheryViewController.swift
//  AR tests
//
//  Created by Yu Wang on 2/7/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import UIKit
import ARKit
import Foundation

class RootArcheryViewController: RootPlayViewController {
    
    var targetAnchorTransform:matrix_float4x4?
    
    var targetAnchor:ARAnchor?
    
    let targetAnchorName = "target anchor name"
    
    var rootTargetNode = SCNNode()
    
    var targetBodyNode = SCNNode()
    
    var rings = [SCNNode]()
    
    var isHolding = false
    var isShooting = false
    
    let maximumHoldingDistance:Float = 0.55
    
    let holdingPoint:SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: 0.01))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0)
        node.name = "holdingPoint"
        return node
    }()
    
    let holdingPointPosition = SCNVector3(0, 0, 0.1)
    
    let upperAttachingPoint:SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: 0.01))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0)
        node.name = "upperAttachingPoint"
        return node
    }()
    
    let upperAttachingPointPosition = SCNVector3(0.005,0.75,0.1)
    
    let lowerAttachingPoint:SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: 0.01))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0)
        node.name = "lowerAttachingPoint"
        return node
    }()
    
    let lowerAttachingPointPosition = SCNVector3(0.005,-0.75,0.1)
    
    let shootingPoint:SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: 0.01))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0)
        node.name = "shootingPoint"
        return node
    }()
    
    let shootingPointPosition = SCNVector3(0.005, 0, -0.12)
    
    var bow = (SCNScene(named: "Models.scnassets/archery/longBow.scn")?.rootNode.childNode(withName: "bow", recursively: false))!
    
    var arrow = (SCNScene(named: "Models.scnassets/archery/arrow.scn")?.rootNode.childNode(withName: "arrow", recursively: false))!
    
    func getArrow() -> SCNNode{
        let arrow = self.arrow.clone()
        arrow.name = "arrow"
        arrow.position = SCNVector3(0, 0, -0.005)
        arrow.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: arrow, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.convexHull]))
        arrow.physicsBody?.categoryBitMask = catagory.arrow.rawValue
        arrow.physicsBody?.contactTestBitMask = catagory.archeryTargetRings.rawValue
        arrow.physicsBody?.collisionBitMask = catagory.archeryTargetBody.rawValue
        
        arrow.physicsBody?.isAffectedByGravity = false
        return arrow
    }
    
    var currentArrow = SCNNode()
    
    var allArrows = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modeLabel.text = "Archery"
        let recog = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(recog:)))
        recog.minimumPressDuration = 0.01
        sceneView.addGestureRecognizer(recog)
    }
    
    func setUp(){
        bow.scale = SCNVector3(0.5,0.5,0.5)
        sceneView.scene.rootNode.addChildNode(bow)
        sceneView.scene.rootNode.childNode(withName: "bow", recursively: false)!.addChildNode(holdingPoint)
        sceneView.scene.rootNode.childNode(withName: "bow", recursively: false)!.addChildNode(upperAttachingPoint)
        sceneView.scene.rootNode.childNode(withName: "bow", recursively: false)!.addChildNode(lowerAttachingPoint)
        sceneView.scene.rootNode.childNode(withName: "bow", recursively: false)!.addChildNode(shootingPoint)
        currentArrow = getArrow()
        sceneView.scene.rootNode.childNode(withName: "holdingPoint", recursively: true)!.addChildNode(currentArrow)
        allArrows.append(currentArrow)
    }
    
    
    @objc func handleTap(recog:UILongPressGestureRecognizer){
        proceedTap(shouldShootArrow: shouldBeginGame, recog: recog)
    }
    
    func proceedTap(shouldShootArrow:Bool,recog:UILongPressGestureRecognizer){
        numberOfTriesToSetGoal += 1
        if shouldShootArrow{
            holdArrow(recog)
        }else{
            addTargetAnchor(recog: recog)
        }
    }
    
    func addTargetAnchor(recog:UILongPressGestureRecognizer){
        if let sceneView = recog.view as? ARSCNView{
            var hitTestResults = [ARHitTestResult]()
            if planeDetceted{
                hitTestResults = sceneView.hitTest(recog.location(in: sceneView), types: [.existingPlaneUsingExtent])
            }else{
                hitTestResults = sceneView.hitTest(recog.location(in: sceneView), types: [.featurePoint])
            }
            if !hitTestResults.isEmpty{
                //get position
                if let anchor = hitTestResults.first!.anchor as? ARPlaneAnchor,anchor.alignment == .horizontal{
                    let position = hitTestResults.first!.worldTransform.columns.3
                    //rotate so it faces the user
                    let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
                    //make anchor position to be tapped position and rotate it toward the user
                    let anchorTransform = simd_float4x4().combinePositionAndRotation(position: position, rotation: rotate)
                    self.targetAnchorTransform = anchorTransform
                    targetAnchor = ARAnchor(name: targetAnchorName, transform: anchorTransform)
                    //add goal anchor
                    sceneView.session.add(anchor: targetAnchor!)
                    syncGoal(with: targetAnchor!)
                    //set game events
                    shouldBeginGame = true
                    setUp()
                    showNoticeAndFade(notice: "Long Press To Shoot Ball")
                }
            }else{
                if numberOfTriesToSetGoal <= 3{
                    showNoticeAndFade(notice: "Find A Floor First")
                }else{
                    if planeDetceted{
                        showNoticeAndFade(notice: "Tap Within The Floor")
                    }else{
                        showNoticeAndFade(notice: "Floor With Context Is More Detectable, Try Putting A Paper With Text Or A Book On The Ground")
                    }
                }
            }
        }
    }
    
    func syncGoal(with anchor:ARAnchor){
        //
    }
    
    override func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        super.renderer(renderer, didAdd: node, for: anchor)
        //check if the anchor is goal anchor
        guard anchor.name == "target anchor name"
            else { return }
        
        // save the reference to the virtual object anchor when the anchor is added from relocalizing
        if targetAnchor == nil {
            targetAnchor = anchor
            targetAnchorTransform = anchor.transform
        }
        //node's world position is 000
        node.simdTransform = anchor.transform
        proceedTarget(with: node)
    }
    
    func proceedTarget(with node:SCNNode){
        //get scene
        let scene = SCNScene(named: "Models.scnassets/archery/standingTarget.scn")!
        let targetRootNode = scene.rootNode
        
        //        basketballGoalRootNode.simdWorldTransform = goalAnchorTransform!
        self.rootTargetNode = targetRootNode
        
        //get the goal
        let targetNode = targetRootNode.childNode(withName: "TargetBody", recursively: true)!
        targetNode.name = "targetBody"
        self.targetBodyNode = targetNode
        
        for ringIndex in 0...10{
            self.rings.append(targetRootNode.childNode(withName: "Target\(ringIndex)", recursively: false)!)
            let ring = self.rings[ringIndex]
            ring.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: ring, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
            ring.physicsBody?.categoryBitMask = catagory.archeryTargetRings.rawValue
            ring.physicsBody?.contactTestBitMask = catagory.arrow.rawValue
            ring.physicsBody?.collisionBitMask = catagory.arrow.rawValue
        }
        
        //add physics body based on the shape of the basketball goal
        targetBodyNode.name = "targetBodyNode"
        
        //physics
        targetBodyNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: targetBodyNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        targetBodyNode.physicsBody?.categoryBitMask = catagory.archeryTargetBody.rawValue
        targetBodyNode.physicsBody?.contactTestBitMask = catagory.non.rawValue
        targetBodyNode.physicsBody?.collisionBitMask = catagory.arrow.rawValue
        //add the goal and checker to the node associated with the goal anchor
        node.addChildNode(targetRootNode)
        //        syncShootTimer()
    }
    
    
    
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
        bow.scale = SCNVector3(0.5,0.5,0.5)
        if shouldBeginGame{
            shootingPoint.position = shootingPointPosition
            updateString()
            if let currentFrame = sceneView.session.currentFrame{
                //holding the bow
                if isHolding && !isShooting{
                    //                if SCNVector3.distanceFrom(vector: holdingPoint.worldPosition, toVector: shootingPoint.worldPosition) > maximumHoldingDistance{
                    //                    //control pos
                    //                }else{
                    //                    var translation = matrix_identity_float4x4
                    //                    translation.columns.3.z = -0.1
                    //                    holdingPoint.simdWorldTransform = matrix_multiply(currentFrame.camera.transform, translation)
                    //                    bow.look(at: bow.position+bow.position-holdingPoint.worldPosition)
                    //                    holdingPoint.look(at: shootingPoint.worldPosition)
                    //                }
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.1
                    holdingPoint.simdWorldTransform = matrix_multiply(currentFrame.camera.transform, translation)
                    bow.look(at: bow.position+bow.position-holdingPoint.worldPosition)
                    currentArrow.look(at: shootingPoint.worldPosition)
                    
                }else if isShooting && !isHolding{
                    //shooting animaiton
                    let moveBack = SCNAction.move(to: holdingPointPosition, duration: 0.01)
                    moveBack.timingMode = .easeIn
                    let wait = SCNAction.wait(duration: TimeInterval(exactly: 1)!)
                    let sequence = SCNAction.sequence([moveBack,wait])
                    holdingPoint.runAction(sequence) {
                        self.isShooting = false
                    }
                    let orientation = shootingPoint.worldPosition-holdingPoint.worldPosition
                    currentArrow.physicsBody?.isAffectedByGravity = false
                    currentArrow.physicsBody?.applyForce(orientation*10, asImpulse: true)
                    currentArrow.removeFromParentNode()
                    currentArrow = getArrow()
                    sceneView.scene.rootNode.childNode(withName: "holdingPoint", recursively: true)!.addChildNode(currentArrow)
                    allArrows.append(currentArrow)
                }else{
                    //normal
                    holdingPoint.position = holdingPointPosition
                    holdingPoint.eulerAngles = SCNVector3(0, 0, 0)
                    currentArrow.look(at: shootingPoint.worldPosition)
                    
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.7
                    translation.columns.3.x = 0.2
                    bow.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
                    
                    bow.simdLocalRotate(by: simd_quatf(angle: Float.pi/2, axis: float3(0, 0.5, 1)))
                }
            }
        }
    }
    //MARK:Check if arrow hits the rings
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.name == "arrow"{
            if rings.contains(contact.nodeB){
                contact.nodeA.physicsBody?.velocity = SCNVector3(0,0,0)
                contact.nodeA.physicsBody?.isAffectedByGravity = false
            }
        }else if contact.nodeB.name == "arrow"{
            if rings.contains(contact.nodeA){
                contact.nodeB.physicsBody?.velocity = SCNVector3(0,0,0)
                contact.nodeB.physicsBody?.isAffectedByGravity = false
            }
        }
    }
    
    func updateString(){
        upperAttachingPoint.position = upperAttachingPointPosition
        lowerAttachingPoint.position = lowerAttachingPointPosition
        let upperNode = SCNNode().buildLineInTwoPointsWithRotation(from: upperAttachingPoint.worldPosition, to: holdingPoint.presentation.worldPosition, radius: 0.0015, color: UIColor.black)
        let lowerNode = SCNNode().buildLineInTwoPointsWithRotation(from: lowerAttachingPoint.worldPosition, to: holdingPoint.presentation.worldPosition, radius: 0.0015, color: UIColor.black)
        
        upperNode.name = "StringNode"
        lowerNode.name = "StringNode"
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "StringNode"{
                node.removeFromParentNode()
            }
        }
        
        sceneView.scene.rootNode.addChildNode(upperNode)
        sceneView.scene.rootNode.addChildNode(lowerNode)
    }
    
    @objc func holdArrow(_ recog:UILongPressGestureRecognizer){
        switch recog.state {
        case .began:
            isHolding = true
            isShooting = false
        case .cancelled,.ended:
            isHolding = false
            isShooting = true
        default:
            break
        }
    }
}

extension SCNVector3 {
    static func distanceFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> Float {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z
        
        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
    }
}

func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
    let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
    if length == 0 {
        return SCNVector3(0.0, 0.0, 0.0)
    }
    
    return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
    
}

extension SCNNode {
    
    func buildLineInTwoPointsWithRotation(from startPoint: SCNVector3,
                                          to endPoint: SCNVector3,
                                          radius: CGFloat,
                                          color: UIColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
            
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = normalizeVector(av)
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        return self
    }
}


