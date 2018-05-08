//
//  ImmutableModel.swift
//  ObjectMapper-Plugin
//
//  Created by LyhDev on 2016/12/30.
//  Copyright © 2016年 LyhDev. All rights reserved.
//

import Cocoa
import ObjectMapper


struct ImmutableModel2 {
    
    var prop: AnyObject? = nil
    var prop1: String!
    var prop2: Int?
    var prop3: Double = 0.0
    var prop4: [String: Any]!
    
    let prop5: String
    let prop6: Int
    let prop7: [String: AnyObject]
}

extension ImmutableModel2: ImmutableMappable {

	 init(map: Map) throws {
		prop                 = try map.value("prop")
		prop1                = try map.value("prop1")
		prop2                = try map.value("prop2")
		prop3                = try map.value("prop3")
		prop4                = try map.value("prop4")
		prop5                = try map.value("prop5")
		prop6                = try map.value("prop6")
		prop7                = try map.value("prop7")
	}

	mutating func mapping(map: Map) {
		prop                 <- map["prop"]
		prop1                <- map["prop1"]
		prop2                <- map["prop2"]
		prop3                <- map["prop3"]
		prop4                <- map["prop4"]
		prop5                >>> map["prop5"]
		prop6                >>> map["prop6"]
		prop7                >>> map["prop7"]
	}
}
