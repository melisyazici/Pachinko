//
//  GameScene.swift
//  Pachinko
//
//  Created by Melis Yazıcı on 07.11.22.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background") // load the file called background.jpg
        background.position = CGPoint(x: 512, y: 384) // to place the background image in the center of a landscape iPad
        background.blendMode = .replace // draw it, ignoring any alpha values -> which makes it fast for things without gaps such as the background
        background.zPosition = -1 // draw this behind everything else
        addChild(background) // to add any node to the current screen
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame) // adds a physics body to the whole scene that is a line on each edge, effectively acting like a container for the scene
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // to pull out any of the screen touches from the touches set
        let location = touch.location(in: self) // use its location(in:) method to find out where the screen was touched in relation to self - i.e. the game scene
        
        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.position = location
        ball.name = "ball"
        addChild(ball)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false // the object will still collide with other things, but it won't ever be moved as a result
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size) // rectangle physics body the size of slot base
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10) // spin by pi degrees so half a circle over 10 seconds
        let spinForever = SKAction.repeatForever(spin) // make it loop forever
        slotGlow.run(spinForever) // apply that to the glow
        
    }
    
}
