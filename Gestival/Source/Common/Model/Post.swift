//
//  Post.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/30.
//

import UIKit

struct requestPost: Codable{
    let title: String
    let content: String
    let imageData: Data
}

struct responsePost: Codable{
    let title: String
    let content: String
    let imageData: Data
}
