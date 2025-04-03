//
//  GameScene.swift
//  Mixed Vegetable Helper
//
//  Created by Cardiff Emde on 4/2/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var spinnyNode : SKShapeNode?
    
    private var lastTouchPosition: CGPoint?
    
    override func didMove(to view: SKView) {
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        lastTouchPosition = pos
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            
            // Add super fast color cycling
            let colors: [SKColor] = [.red, .orange, .yellow, .green, .blue, .purple]
            let colorAction = SKAction.customAction(withDuration: 0.5) { node, time in
                if let shapeNode = node as? SKShapeNode {
                    let colorIndex = Int(time * 12) % colors.count
                    shapeNode.strokeColor = colors[colorIndex]
                }
            }
            n.run(SKAction.repeatForever(colorAction))
            
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            
            // Calculate direction based on last touch position
            if let lastPos = lastTouchPosition {
                let dx = pos.x - lastPos.x
                let dy = pos.y - lastPos.y
                let angle = atan2(dy, dx)
                n.zRotation = angle
            }
            
            // Add super fast color cycling
            let colors: [SKColor] = [.red, .orange, .yellow, .green, .blue, .purple]
            let colorAction = SKAction.customAction(withDuration: 0.5) { node, time in
                if let shapeNode = node as? SKShapeNode {
                    let colorIndex = Int(time * 12) % colors.count
                    shapeNode.strokeColor = colors[colorIndex]
                }
            }
            n.run(SKAction.repeatForever(colorAction))
            
            self.addChild(n)
        }
        lastTouchPosition = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
