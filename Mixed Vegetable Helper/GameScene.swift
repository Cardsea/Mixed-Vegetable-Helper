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
    private var trailNodes: [SKShapeNode] = []
    private var maxTrailLength = 10
    private let followSpeed: CGFloat = 0.2
    private var colorChangeSpeed: CGFloat = 12.0
    
    // Settings UI
    private var settingsButton: SKLabelNode?
    private var settingsPanel: SKNode?
    private var lengthSlider: SKShapeNode?
    private var speedSlider: SKShapeNode?
    private var isSettingsOpen = false
    
    private var isDraggingSlider: SKShapeNode?
    
    override func didMove(to view: SKView) {
        // Enable physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
        }
        
        setupSettingsUI()
    }
    
    private func setupSettingsUI() {
        // Settings button
        settingsButton = SKLabelNode(text: "⚙️ SETTINGS")
        if let settingsButton = settingsButton {
            settingsButton.position = CGPoint(x: size.width - 100, y: size.height - 50)
            settingsButton.fontSize = 32
            settingsButton.fontColor = .white
            settingsButton.name = "settingsButton"
            
            // Add background to button
            let buttonBg = SKShapeNode(rectOf: CGSize(width: 150, height: 50), cornerRadius: 10)
            buttonBg.fillColor = .black
            buttonBg.alpha = 0.8
            buttonBg.strokeColor = .white
            buttonBg.position = CGPoint(x: 0, y: 0)
            settingsButton.addChild(buttonBg)
            settingsButton.zPosition = 1
            
            addChild(settingsButton)
            
            // Debug info
            let debugLabel = SKLabelNode(text: "Screen size: \(size.width) x \(size.height)")
            debugLabel.position = CGPoint(x: size.width/2, y: size.height - 20)
            debugLabel.fontSize = 16
            debugLabel.fontColor = .white
            addChild(debugLabel)
        }
        
        // Settings panel
        settingsPanel = SKNode()
        if let settingsPanel = settingsPanel {
            settingsPanel.position = CGPoint(x: size.width/2, y: size.height/2)
            settingsPanel.zPosition = 100
            settingsPanel.isHidden = true
            
            // Background
            let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 200), cornerRadius: 10)
            bg.fillColor = .black
            bg.alpha = 0.8
            bg.strokeColor = .white
            settingsPanel.addChild(bg)
            
            // Title
            let title = SKLabelNode(text: "Settings")
            title.position = CGPoint(x: 0, y: 70)
            title.fontSize = 24
            settingsPanel.addChild(title)
            
            // Trail Length Slider
            let lengthLabel = SKLabelNode(text: "Trail Length: \(maxTrailLength)")
            lengthLabel.position = CGPoint(x: 0, y: 20)
            lengthLabel.fontSize = 18
            lengthLabel.name = "lengthLabel"
            settingsPanel.addChild(lengthLabel)
            
            // Slider track
            let lengthTrack = SKShapeNode(rectOf: CGSize(width: 200, height: 4))
            lengthTrack.position = CGPoint(x: 0, y: -20)
            lengthTrack.fillColor = .gray
            lengthTrack.strokeColor = .white
            settingsPanel.addChild(lengthTrack)
            
            // Slider handle
            lengthSlider = SKShapeNode(circleOfRadius: 10)
            if let lengthSlider = lengthSlider {
                lengthSlider.position = CGPoint(x: -100 + (200 * CGFloat(maxTrailLength) / 50), y: -20)
                lengthSlider.fillColor = .white
                lengthSlider.strokeColor = .white
                lengthSlider.name = "lengthSlider"
                settingsPanel.addChild(lengthSlider)
            }
            
            // Color Speed Slider
            let speedLabel = SKLabelNode(text: "Color Speed: \(Int(colorChangeSpeed))")
            speedLabel.position = CGPoint(x: 0, y: -60)
            speedLabel.fontSize = 18
            speedLabel.name = "speedLabel"
            settingsPanel.addChild(speedLabel)
            
            // Slider track
            let speedTrack = SKShapeNode(rectOf: CGSize(width: 200, height: 4))
            speedTrack.position = CGPoint(x: 0, y: -100)
            speedTrack.fillColor = .gray
            speedTrack.strokeColor = .white
            settingsPanel.addChild(speedTrack)
            
            // Slider handle
            speedSlider = SKShapeNode(circleOfRadius: 10)
            if let speedSlider = speedSlider {
                speedSlider.position = CGPoint(x: -100 + (200 * CGFloat(colorChangeSpeed) / 24), y: -100)
                speedSlider.fillColor = .white
                speedSlider.strokeColor = .white
                speedSlider.name = "speedSlider"
                settingsPanel.addChild(speedSlider)
            }
            
            addChild(settingsPanel)
        }
    }
    
    private func updateColorAction(for node: SKShapeNode) {
        node.removeAllActions()
        let colors: [SKColor] = [.red, .orange, .yellow, .green, .blue, .purple]
        let colorAction = SKAction.customAction(withDuration: 0.5) { node, time in
            if let shapeNode = node as? SKShapeNode {
                let colorIndex = Int(time * self.colorChangeSpeed) % colors.count
                shapeNode.strokeColor = colors[colorIndex]
            }
        }
        node.run(SKAction.repeatForever(colorAction))
    }
    
    private func createNewTrailNode(at pos: CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            updateColorAction(for: n)
            
            // Add physics body
            n.physicsBody = SKPhysicsBody(circleOfRadius: n.frame.width / 2)
            n.physicsBody?.isDynamic = false  // Start as static
            n.physicsBody?.restitution = 0.5  // Bouncy
            n.physicsBody?.friction = 0.2     // Slippery
            n.physicsBody?.mass = 0.1         // Light
            
            self.addChild(n)
            trailNodes.append(n)
            
            // Keep trail at max length
            if trailNodes.count > maxTrailLength {
                let oldNode = trailNodes.removeFirst()
                oldNode.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let settingsButton = settingsButton, settingsButton.contains(location) {
            toggleSettings()
            return
        }
        
        if isSettingsOpen {
            if let settingsPanel = settingsPanel, settingsPanel.contains(location) {
                let localPos = settingsPanel.convert(location, from: self)
                
                // Check if we're touching a slider handle
                if let lengthSlider = lengthSlider, lengthSlider.contains(localPos) {
                    isDraggingSlider = lengthSlider
                    return
                }
                if let speedSlider = speedSlider, speedSlider.contains(localPos) {
                    isDraggingSlider = speedSlider
                    return
                }
            }
            return
        }
        
        self.touchDown(atPoint: location)
    }
    
    private func toggleSettings() {
        isSettingsOpen.toggle()
        settingsPanel?.isHidden = !isSettingsOpen
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isSettingsOpen, let settingsPanel = settingsPanel, let slider = isDraggingSlider {
            let localPos = settingsPanel.convert(location, from: self)
            
            // Constrain slider movement
            let xPos = max(-100, min(100, localPos.x))
            slider.position.x = xPos
            
            // Update values based on slider position
            if slider == lengthSlider {
                let percentage = (xPos + 100) / 200
                maxTrailLength = max(1, min(50, Int(percentage * 50)))
            } else if slider == speedSlider {
                let percentage = (xPos + 100) / 200
                colorChangeSpeed = max(1, min(24, percentage * 24))
                // Update all existing nodes
                for node in trailNodes {
                    updateColorAction(for: node)
                }
            }
            
            updateSettingsLabels()
            return
        }
        
        self.touchMoved(toPoint: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingSlider = nil
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        self.touchUp(atPoint: location)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingSlider = nil
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        self.touchUp(atPoint: location)
    }
    
    private func updateSettingsLabels() {
        guard let settingsPanel = settingsPanel else { return }
        for child in settingsPanel.children {
            if let label = child as? SKLabelNode {
                if label.text?.contains("Trail Length") == true {
                    label.text = "Trail Length: \(maxTrailLength)"
                } else if label.text?.contains("Color Speed") == true {
                    label.text = "Color Speed: \(Int(colorChangeSpeed))"
                }
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        lastTouchPosition = pos
        createNewTrailNode(at: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        lastTouchPosition = pos
        createNewTrailNode(at: pos)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Make trail nodes follow each other
        for i in 0..<trailNodes.count {
            let node = trailNodes[i]
            let targetPos: CGPoint
            
            if i == trailNodes.count - 1 {
                // Last node follows finger
                targetPos = lastTouchPosition ?? node.position
            } else {
                // Other nodes follow the next node in trail
                targetPos = trailNodes[i + 1].position
            }
            
            // Calculate direction
            let dx = targetPos.x - node.position.x
            let dy = targetPos.y - node.position.y
            let angle = atan2(dy, dx)
            node.zRotation = angle
            
            // Move towards target
            let newX = node.position.x + dx * followSpeed
            let newY = node.position.y + dy * followSpeed
            node.position = CGPoint(x: newX, y: newY)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // Enable physics for all trail nodes
        for node in trailNodes {
            node.physicsBody?.isDynamic = true
        }
        // Clear the array but don't remove nodes
        trailNodes.removeAll()
    }
}
