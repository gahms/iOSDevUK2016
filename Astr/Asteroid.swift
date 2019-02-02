//
//  Asteroid.swift
//  Astr
//
//  Created by Nicolai Henriksen on 05/09/16.
//  Copyright © 2016 Miracle A/S. All rights reserved.
//

import SpriteKit

class Asteroid: SKSpriteNode {
    var velocity = CGVector(dx: 0, dy: 0)
    var rotationSpeec = 0.0
    var spriteScale: CGFloat = 0.2
    
    func setUp(_ location: CGPoint) {
        self.xScale = spriteScale
        self.yScale = spriteScale
        self.position = location
    }
}
