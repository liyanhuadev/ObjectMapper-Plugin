//
//  Model.swift
//  ObjectMapper-Plugin
//
//  Created by LyhDev on 2016/12/28.
//  Copyright © 2016年 LyhDev. All rights reserved.
//

import Cocoa

enum Metadata {
    case model(range: Range<Int>, elements: [Metadata])
    case closureProperty(range: Range<Int>)
    case method(range: Range<Int>)
    case property(lineNumber: Int)
}
















































