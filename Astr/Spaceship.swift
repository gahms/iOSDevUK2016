//
//  Spaceship.swift
//  Astr
//
//  Created by Nicolai Henriksen on 05/09/16.
//  Copyright © 2016 Miracle A/S. All rights reserved.
//

import SpriteKit

enum Rotation {
    case none
    case left
    case right
}

class Spaceship: SKSpriteNode {
    let shipSpeed: CGFloat = 100.0
    let spriteScale: CGFloat = 0.25
    
    var shipRotation = Rotation.none
}
