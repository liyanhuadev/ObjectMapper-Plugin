//
//  MutableModel.swift
//  ObjectMapper-Plugin
//
//  Created by LyhDev on 2016/12/30.
//  Copyright © 2016年 LyhDev. All rights reserved.
//

import Cocoa
import ObjectMapper

class MutableModel: NSObject {
    
    var prop1: String!
    var prop2: Int?
    var prop3: Double = 0.0
    var prop4: [String: Any]!
    
    static var prop5: AnyObject?

}


struct MutableModel2 {
    
    var prop: MutableModel? = nil
    var prop1: String!
    var prop2: Int?
    var prop3: Double = 0.0
    var prop4: [String: Any]!
}

    
