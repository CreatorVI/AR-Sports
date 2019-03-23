

import Foundation
import ARKit

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
}

@available(iOS 12.0, *)
extension ARPlaneAnchor.Classification {
    var description: String {
        switch self {
        case .wall:
            return "Wall"
        case .floor:
            return "Floor"
        case .ceiling:
            return "Ceiling"
        case .table:
            return "Table"
        case .seat:
            return "Seat"
        case .none(.unknown):
            return "Unknown"
        default:
            return ""
        }
    }
}

extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = float3(max) - float3(min)
        simdPivot = float4x4(translation: ((extents / 2) + float3(min)))
    }
}

extension float4x4 {
    init(translation vector: float3) {
        self.init(float4(1, 0, 0, 0),
                  float4(0, 1, 0, 0),
                  float4(0, 0, 1, 0),
                  float4(vector.x, vector.y, vector.z, 1))
    }
}


func -(left:SCNVector3,right:SCNVector3)->SCNVector3{
    return SCNVector3(left.x-right.x,left.y-right.y,left.z-right.z)
}

func *(left:SCNVector3,right:Float)->SCNVector3{
    return SCNVector3(left.x*right, left.y*right, left.z*right)
}

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        }
    }
}

extension ARCamera.TrackingState {
    var localizedFeedbackForHost: String {
        switch self {
        case .normal:
            // No planes detected; provide instructions for this app's AR interactions.
            return ""
            
        case .notAvailable:
            return ""
            
        case .limited(.excessiveMotion):
            return "Move The Device More Slowly."
            
        case .limited(.insufficientFeatures):
            return ""
            
        case .limited(.relocalizing):
            return "Resuming Game — Move To Where You Were When The Game Was Interrupted."
            
        case .limited(.initializing):
            return ""
        }
    }
}

extension ARCamera.TrackingState {
    var localizedFeedbackForClient: String {
        switch self {
        case .normal:
            // No planes detected; provide instructions for this app's AR interactions.
            return ""
            
        case .notAvailable:
            return ""
            
        case .limited(.excessiveMotion):
            return "Move The Device More Slowly."
            
        case .limited(.insufficientFeatures):
            return ""
            
        case .limited(.relocalizing):
            return "Resuming Game — Move To Where You Were When The Game Was Interrupted."
            
        case .limited(.initializing):
            return "Initializing..."
        }
    }
}

//Make Vector3 codable
enum SCNVector3CodingKeys:String,CodingKey{
    case x = "x"
    case y = "y"
    case z = "z"
}

extension SCNVector3:Codable{
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SCNVector3CodingKeys.self)
        try container.encode(x, forKey: SCNVector3CodingKeys.x)
        try container.encode(y, forKey: SCNVector3CodingKeys.y)
        try container.encode(z, forKey: SCNVector3CodingKeys.z)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SCNVector3CodingKeys.self)
        self.init()
        x = try values.decode(Float.self, forKey: SCNVector3CodingKeys.x)
        y = try values.decode(Float.self, forKey: SCNVector3CodingKeys.y)
        z = try values.decode(Float.self, forKey: SCNVector3CodingKeys.z)
    }
}

//allow easy combination of position and rotation
extension simd_float4x4{
    func combinePositionAndRotation(position:simd_float4,rotation:simd_float4x4)->simd_float4x4{
        return simd_float4x4(columns: (rotation.columns.0,
                                             rotation.columns.1,
                                             rotation.columns.2,
                                             position))
    }
}

//easy way to show alert
extension UIViewController {
    
    func showAlert(title: String,
                   message: String,
                   buttonTitle: String = "OK",
                   showCancel: Bool = false,
                   buttonHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: buttonHandler))
        if showCancel {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
       
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.gray
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

//allow encoding and decoding of any property to data(unsure if is panacea
extension Data {
    /**
     unsafely encode anything to data
     */
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}

// MARK: - float4x4 extensions

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        get {
            let translation = columns.3
            return float3(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
    
    /**
     Factors out the orientation component of the transform.
     */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

//allow basic calculation between 2 vector3
func +(left:SCNVector3,right:SCNVector3)->SCNVector3{
    return SCNVector3(left.x+right.x,left.y+right.y,left.z+right.z)
}

func /(left:SCNVector3,right:Float)->SCNVector3{
    return SCNVector3(left.x/right, left.y/right, left.z/right)
}

func ==(left:SCNVector3,right:SCNVector3)->Bool{
    return (left.x == right.x && left.y == right.y && left.z == right.z)
}

//
extension ARSCNView{
    func smartHitTest(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: float3? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = [.horizontal]) -> ARHitTestResult? {
        
        // Perform the hit test.
        let results = hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
        
        // 1. Check for a result on an existing plane using geometry.
        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }),
            let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
            return existingPlaneUsingGeometryResult
        }
        
        if infinitePlane {
            
            // 2. Check for a result on an existing plane, assuming its dimensions are infinite.
            //    Loop through all hits against infinite existing planes and either return the
            //    nearest one (vertical planes) or return the nearest one which is within 5 cm
            //    of the object's position.
            let infinitePlaneResults = hitTest(point, types: .existingPlane)
            
            for infinitePlaneResult in infinitePlaneResults {
                if let planeAnchor = infinitePlaneResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                    if planeAnchor.alignment == .vertical {
                        // Return the first vertical plane hit test result.
                        return infinitePlaneResult
                    } else {
                        // For horizontal planes we only want to return a hit test result
                        // if it is close to the current object's position.
                        if let objectY = objectPosition?.y {
                            let planeY = infinitePlaneResult.worldTransform.translation.y
                            if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                                return infinitePlaneResult
                            }
                        } else {
                            return infinitePlaneResult
                        }
                    }
                }
            }
        }
        
        // 3. As a final fallback, check for a result on estimated planes.
        let vResult = results.first(where: { $0.type == .estimatedVerticalPlane })
        let hResult = results.first(where: { $0.type == .estimatedHorizontalPlane })
        switch (allowedAlignments.contains(.horizontal), allowedAlignments.contains(.vertical)) {
        case (true, false):
            return hResult
        case (false, true):
            // Allow fallback to horizontal because we assume that objects meant for vertical placement
            // (like a picture) can always be placed on a horizontal surface, too.
            return vResult ?? hResult
        case (true, true):
            if hResult != nil && vResult != nil {
                return hResult!.distance < vResult!.distance ? hResult! : vResult!
            } else {
                return hResult ?? vResult
            }
        default:
            return nil
        }
    }
}


extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}

