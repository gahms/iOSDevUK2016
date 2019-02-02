//
//  Bullet.swift
//  Astr
//
//  Created by Nicolai Henriksen on 05/09/16.
//  Copyright © 2016 Miracle A/S. All rights reserved.
//

import SpriteKit

class Bullet: SKSpriteNode {
    let bulletSpeed: CGFloat = 120.0
    var velocity = CGVector(dx: 0, dy: 0)
    var lifeSpan = 60
}
