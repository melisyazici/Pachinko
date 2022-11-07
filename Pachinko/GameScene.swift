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
    }
    
}
