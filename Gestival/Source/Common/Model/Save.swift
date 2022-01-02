//
//  Save.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/30.
//

import UIKit

struct Save: Codable{
    let objectName: String
    let x: Double
    let y: Double
    let z: Double
    enum CodingKeys: String, CodingKey{
        case x,y,z
        case objectName = "object_name"
    }
}


struct Load: Codable{
    let objectName: String
    let x: Double
    let y: Double
    let z: Double
    enum CodingKeys: String, CodingKey{
        case x,y,z
        case objectName = "object_name"
    }
}
