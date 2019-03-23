//
//  Mission.swift
//  AR tests
//
//  Created by Yu Wang on 2/15/19.
//  Copyright © 2019 Illumination. All rights reserved.
//

import Foundation

class Mission:Codable{
    var title:String
    var description:String
    var isCompleted = false
    var awards:Int
    
    init(title:String,description:String,awards:Int) {
        self.title = title
        self.description = description
        self.awards = awards
    }
}
