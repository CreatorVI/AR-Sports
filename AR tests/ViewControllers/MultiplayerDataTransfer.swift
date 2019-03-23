
//
//  MultiplayerDataTransfer.swift
//  AR tests
//
//  Created by Yu Wang on 2/5/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation
import ARKit

enum BallBehaviorCodingKeys:String,CodingKey{
    case position = "position"
    case force = "force"
    case orientation = "orientation"
}

class BallBehavior: Codable {
    var position:SCNVector3
    var force:SCNVector3
    var orientation:SCNVector3
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BallBehaviorCodingKeys.self)
        try container.encode(position, forKey: BallBehaviorCodingKeys.position)
        try container.encode(force, forKey: BallBehaviorCodingKeys.force)
        try container.encode(orientation, forKey: BallBehaviorCodingKeys.orientation)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: BallBehaviorCodingKeys.self)
        position = try values.decode(SCNVector3.self, forKey: BallBehaviorCodingKeys.position)
        force = try values.decode(SCNVector3.self, forKey: BallBehaviorCodingKeys.force)
        orientation = try values.decode(SCNVector3.self, forKey: BallBehaviorCodingKeys.orientation)
    }
    
    init(postion:SCNVector3,force:SCNVector3,orientation:SCNVector3) {
        self.position = postion
        self.force = force
        self.orientation = orientation
    }
}

enum SendDataWithCatagoryManagerCodingKeys: String,CodingKey {
    case data = "data"
    case dataType = "dataType"
}

class SendDataWithCatagoryManager: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SendDataWithCatagoryManagerCodingKeys.self)
        try container.encode(dataType, forKey: .dataType)
        try container.encode(data, forKey: .data)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SendDataWithCatagoryManagerCodingKeys.self)
        dataType = try values.decode(DataCategory.self, forKey: .dataType)
        data = try values.decode(Data.self, forKey: .data)
    }
    
    init(type: DataCategory,data:Data) {
        self.dataType = type
        self.data = data
    }
    
    var dataType: DataCategory
    var data: Data
}

enum DataCategory:String,Codable{
    case initialRequestForWorldMap = "initialRequestForWorldMap"
    case worldMap = "worldMap"
    case score = "score"
    case projectBasketBall = "projectBasketBall"
    case leaveSession = "leaveSession"
    case addGoal = "addGoal"
    case syncPinch = "pinch"
    
    case syncBat = "syncBat"
    case syncPingPongBall = "syncPingPongBall"
    case syncTable = "syncTable"
    
    case weather = "weather"
    case pongBallSelection = "pongBallSelection"
    case basketballSelection = "basketballSelection"
    
    case slowTime = "Slow the time to one half"
    case whiteLight = "Blind your friend for 5 seconds"
    case fire = "Fire the play area"
    case love = "Give some love"
    case manyLoves = "Give many loves"
    case angry = "Show your anger"
}
