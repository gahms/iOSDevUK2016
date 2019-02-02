//
//  GameScene.swift
//  Astr
//
//  Created by Nicolai Henriksen on 05/09/16.
//  Copyright (c) 2016 Miracle A/S. All rights reserved.
//

import SpriteKit

let Pi = CGFloat(M_PI)

class GameScene: SKScene {
    let spaceship = Spaceship(imageNamed: "Spaceship")
    var asteroids: [Asteroid] = []
    var lastUpdateTime: CFTimeInterval = 0
    var moving = false
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        spaceship.xScale = spaceship.spriteScale
        spaceship.yScale = spaceship.spriteScale
        spaceship.position = CGPoint(x: self.frame.midX,
                                     y: self.frame.midY)
        spaceship.zRotation = 0 // facing up
        self.addChild(spaceship)

        for _ in 1...8 {
            let asteroid = Asteroid(imageNamed:"asteroid")
            let location: CGPoint = CGPoint(x: getRandomAwayFrom(Int(self.frame.midX)),
                                            y: getRandomAwayFrom(Int(self.frame.midY)))
            asteroid.setUp(location)
            asteroid.velocity = CGVector(dx: getRandom(200)-100,
                                         dy: getRandom(200)-100)
            self.addChild(asteroid)
            
            let action = SKAction.rotate(byAngle: CGFloat((getRandom(20)-10.0)/100), duration:0.03)
            asteroid.run(SKAction.repeatForever(action))
            asteroids.append(asteroid)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            if location.x < self.frame.midY * 0.5 {
                if location.y < self.frame.midY {
                    // bullets
                    let angle = spaceship.zRotation + Pi / 2
                    let bullet = Bullet(imageNamed:"Bullet")
                    bullet.xScale = 0.5
                    bullet.yScale = 0.5
                    bullet.position = spaceship.position
                    bullet.position.x = bullet.position.x + cos(angle)*45
                    bullet.position.y = bullet.position.y + sin(angle)*45
                    bullet.name = "bullet"
                    
                    let finalPosition = CGPoint(x: bullet.position.x + cos(angle) * bullet.bulletSpeed, y: bullet.position.y + sin(angle) * bullet.bulletSpeed)
                    
                    let actionMove = SKAction.move(to: finalPosition, duration: 1)
                    let actionDelete = SKAction.removeFromParent()
                    bullet.run(SKAction.sequence([actionMove, actionDelete]))
                    
                    self.addChild(bullet)
                }
                else {
                    spaceship.shipRotation = .right
                }
            }
            else if location.x > self.frame.midX * 1.5 {
                // Touch on right quarter
                if location.y <  self.frame.midY  {
                    // Bottom Right - move ship
                    moving = true
                }
                else {
                    // Top half - rotate anticlockwise
                    spaceship.shipRotation = .left
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y > self.frame.midY {
                spaceship.shipRotation = .none
            } else if location.x  >  self.frame.midX  {
                moving = false
            }
        }
    }
   
    func wrapPosition( _ position: CGPoint, ObjSize: CGSize) -> CGPoint {
        let minHeight = ObjSize.height / 3
        let minWidth = ObjSize.width / 3
        var newPosition = position
        if newPosition.x > self.size.width - minWidth {
            newPosition.x = minWidth
        }
        else if newPosition.x < minWidth {
            newPosition.x = self.size.width - minWidth
        }
        if newPosition.y > self.size.height - minHeight {
            newPosition.y = minHeight
        }
        else if newPosition.y < minHeight {
            newPosition.y = self.size.height - minHeight
        }
        return newPosition
    }

    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        let dTime: CGFloat = CGFloat(max(1.0/30,
            currentTime - lastUpdateTime))
        lastUpdateTime = currentTime
        
        for asteroid in asteroids {
            asteroid.position.x = asteroid.position.x + asteroid.velocity.dx * dTime
            asteroid.position.y = asteroid.position.y + asteroid.velocity.dy * dTime
            asteroid.position = wrapPosition(asteroid.position, ObjSize: asteroid.size)
        }
        
        if moving {
            let angle = spaceship.zRotation + Pi / 2
            let xDiff = cos(angle) * spaceship.shipSpeed * dTime
            let yDiff = sin(angle) * spaceship.shipSpeed * dTime
            spaceship.position.x = spaceship.position.x + xDiff
            spaceship.position.y = spaceship.position.y + yDiff
            spaceship.position = wrapPosition( spaceship.position, ObjSize: spaceship.size )
        }
        
        switch spaceship.shipRotation {
        case .left:
            let action = SKAction.rotate(byAngle: CGFloat(-0.03), duration:0.03)
            spaceship.run(SKAction.repeat(action, count: 1))
        case .right:
            let action = SKAction.rotate(byAngle: CGFloat(0.03), duration:0.03)
            spaceship.run(SKAction.repeat(action, count: 1))
        default:  break
        }
    }
    
    func shipCollision( ) -> Bool {
        var result = false
        for asteroid in asteroids {
            if spaceship.frame.intersects(asteroid.frame.insetBy(dx: 30.0, dy: 30.0)) {
                result = true
            }
        }
        return result
    }

    func shootAsteroids() {
        // Loop through the bullets checking
        enumerateChildNodes(withName: "bullet") {node, _ in
            let bullet = node as! Bullet
            var deadAsteroids: [Asteroid] = []
            var newAsteroids: [Asteroid] = []
            for asteroid in self.asteroids {
                if bullet.frame.intersects(asteroid.frame.insetBy(dx: 30.0, dy: 30.0)) {
                    let actionImpactSound = SKAction.playSoundFileNamed("poom.mp3",waitForCompletion: false)
                    self.spaceship.run(actionImpactSound)
                    if asteroid.spriteScale == 0.2 { //big asteroid - split
                        asteroid.spriteScale = 0.12
                        asteroid.xScale = asteroid.spriteScale
                        asteroid.yScale = asteroid.spriteScale
                        let newAsteroid = Asteroid(imageNamed:"asteroid")
                        newAsteroid.setUp( asteroid.position )
                        newAsteroid.spriteScale = 0.12
                        newAsteroid.xScale = newAsteroid.spriteScale
                        newAsteroid.yScale = newAsteroid.spriteScale
                        asteroid.velocity = CGVector(dx: getRandom(300)-150,
                                                     dy: getRandom(300)-150 )
                        newAsteroid.velocity = CGVector(dx: getRandom(300)-150,
                                                        dy: getRandom(300)-150 )
                        let action = SKAction.rotate(byAngle: CGFloat(getRandom(10)/100),
                                                            duration:0.03)
                        newAsteroid.run(SKAction.repeatForever(action))
                        newAsteroids.append(newAsteroid)
                        self.addChild(newAsteroid)
                    } else {
                        deadAsteroids.append(asteroid)
                    }
                }
            }
            if deadAsteroids.count > 0 {
                var redoneAsteroids: [Asteroid] = []
                for asteroid in self.asteroids {
                    var keepThis = true
                    for deadAsteroid in deadAsteroids {
                        if deadAsteroid == asteroid {
                            keepThis = false
                            asteroid.removeFromParent()
                        }
                    }
                    if keepThis {
                        redoneAsteroids.append(asteroid)
                    }
                }
                self.asteroids = redoneAsteroids
            }
            
            if newAsteroids.count > 0 {
                self.asteroids.append(contentsOf: newAsteroids)
            }
        }
    }
    
    override func didEvaluateActions() {
        shootAsteroids()
        /*
        if shipCollision() {
            spaceship.removeFromParent()
        }
         */
    }
}

func getRandom(_ biggest: Int) -> CGFloat {
    let tmpNum = Int(arc4random_uniform(UInt32(1000)))
    return CGFloat(tmpNum % biggest)
}

func getRandomAwayFrom(_ midValue: Int) -> CGFloat {
    let awayValue = 100 // how far
    let maxValue = midValue - awayValue
    let randValue = getRandom(maxValue*2) - CGFloat(maxValue)
    if randValue > 0.0 {
        return CGFloat(midValue) + randValue + CGFloat(awayValue)
    }
    return CGFloat(midValue) + randValue - CGFloat(awayValue)
}
