//
//  GameScene.swift
//  Pachinko
//
//  Created by Melis Yazıcı on 07.11.22.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let ballColors = ["Blue", "Cyan", "Green", "Grey", "Purple", "Red", "Yellow"]
    
    var RemainingBallsLabel: SKLabelNode!
    
    var remainingBalls = 5 {
        didSet {
            RemainingBallsLabel.text = "Balls: \(remainingBalls)"
        }
    }
    
    var newGameLabel: SKLabelNode!
    
    var resultLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background") // load the file called background.jpg
        background.position = CGPoint(x: 512, y: 384) // to place the background image in the center of a landscape iPad
        background.blendMode = .replace // draw it, ignoring any alpha values -> which makes it fast for things without gaps such as the background
        background.zPosition = -1 // draw this behind everything else
        addChild(background) // to add any node to the current screen
        
        RemainingBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        RemainingBallsLabel.text = "Score: 0"
        RemainingBallsLabel.horizontalAlignmentMode = .right
        RemainingBallsLabel.position = CGPoint(x: 980, y: 700)
        addChild(RemainingBallsLabel)
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "New Game"
        newGameLabel.position = CGPoint(x: 130, y: 700)
        addChild(newGameLabel)
        
        resultLabel = SKLabelNode(fontNamed: "Chalkduster")
        resultLabel.text = ""
        resultLabel.horizontalAlignmentMode = .center
        resultLabel.position = CGPoint(x: 512, y: 700)
        addChild(resultLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame) // adds a physics body to the whole scene that is a line on each edge, effectively acting like a container for the scene
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        newGame()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // to pull out any of the screen touches from the touches set
        let location = touch.location(in: self) // use its location(in:) method to find out where the screen was touched in relation to self - i.e. the game scene
        
        let objects = nodes(at: location)
        
        if objects.contains(newGameLabel) {
            newGame()
        } else if remainingBalls > 0 && !isBallInPlay() {
                let ball = SKSpriteNode(imageNamed: "ball\(ballColors.randomElement()!)")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0 // detect every collision - The collision bitmask determines bounces; the contact test bitmask determines which bounces we get told about
                ball.position = CGPoint(x: location.x, y: 700)
                ball.name = "ball"
                addChild(ball)
            }
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
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "box" {
            object.removeFromParent()
        }
        if object.name == "good" {
            destroy(ball: ball, isGood: true)
            manageResult()
        }
        else if object.name == "bad" {
            destroy(ball: ball, isGood: false)
            remainingBalls -= 1
            manageResult()
        }
    }
    
    func manageResult() {
        if !isRemainingBoxes() {
            resultLabel.fontColor = UIColor.green
            resultLabel.text = "VICTORY"
        }
        else if remainingBalls == 0 {
            resultLabel.fontColor = UIColor.red
            resultLabel.text = "DEFEAT"
        }
    }
    
    func destroy(ball: SKNode, isGood: Bool) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            if isGood {
                fireParticles.particleColorGreenRange = 1
            } else {
                fireParticles.particleColorRedRange = 1
            }
            addChild(fireParticles)
        }
        
        ball.removeFromParent()// removes the node from the game (from the node tree)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func isBallInPlay() -> Bool {
        for node in self.children {
            if node.name == "ball" {
                return true
            }
        }
        return false
    }
    
    func isRemainingBoxes() -> Bool {
        for node in self.children {
            if node.name == "box" {
                return true
            }
        }
        return false
    }
    
    func newGame() {
        remainingBalls = 5
        
        resultLabel.text = ""
        
        // remove remaining boxes and balls
        for node in self.children {
            if node.name == "box" || node.name == "ball" {
                node.removeFromParent()
            }
        }
        
        makeRandomBoxes(number: 15)
    }
    
    func makeRandomBoxes(number: Int) {
        for _ in 1...number {
            let size = CGSize(width: Int.random(in: 16...128), height: 16)
            let color = getBoxColor()
            let rotation = CGFloat.random(in: 0...3)
            let position = CGPoint(x: CGFloat.random(in: 128...896), y: CGFloat.random(in: 200...568))
            
            let box = SKShapeNode(rectOf: size, cornerRadius: 3)
            box.fillColor = color
            box.strokeColor = color
            box.lineWidth = 1
            box.zRotation = rotation
            box.position = position
            box.physicsBody = SKPhysicsBody(rectangleOf: size)
            box.physicsBody?.isDynamic = false
            box.name = "box"
            addChild(box)
        }
    }
    
    func getBoxColor() -> UIColor {
        let colors = [
                UIColor.red,
                UIColor.magenta,
                UIColor.blue,
                UIColor.cyan,
                UIColor.green,
                UIColor.yellow,
                UIColor.orange,
                UIColor.purple,
                UIColor.white
            ]
        return colors.randomElement()!.withAlphaComponent(0.75)
    }
    
}
