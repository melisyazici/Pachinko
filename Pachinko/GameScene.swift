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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // to pull out any of the screen touches from the touches set
        let location = touch.location(in: self) // use its location(in:) method to find out where the screen was touched in relation to self - i.e. the game scene
        
        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.position = location
        addChild(ball)
    }
    
}
