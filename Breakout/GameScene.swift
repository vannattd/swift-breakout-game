//
//  GameScene.swift
//  Breakout
//
//  Created by Dylan Vannatter on 12/10/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var fingerOnPaddle = false
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let blockCategoryName = "block"
    
    let ballCategory:UInt32 = 0x1 << 0
    let bottomCategory:UInt32 = 0x1 << 1
    let blockCategory:UInt32 = 0x1 << 2
    let paddleCategory:UInt32 = 0x1 << 3
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.physicsWorld.contactDelegate = self
        
        let backgroundImage = SKSpriteNode(imageNamed: "bg")
        backgroundImage.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(backgroundImage)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let worldBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
        
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = ballCategoryName
        ball.position = CGPoint(x: self.frame.size.width/2.8, y: self.frame.size.height/2.8)
        self.addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.applyImpulse(CGVector(dx: 2, dy: -2))
        
        let paddle = SKSpriteNode(imageNamed: "paddle")
        paddle.name = paddleCategoryName
        paddle.position = CGPoint(x: self.frame.midX, y: paddle.frame.size.height * 2)
        self.addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.frame.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.isDynamic = false
        
        let bottomRect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        self.addChild(bottom)
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        ball.physicsBody?.contactTestBitMask = bottomCategory | blockCategory
        
        let numRows = 3
        let numBlocks = 6
        let blockWidth = SKSpriteNode(imageNamed: "block").size.width
        let padding:Float = 20
        
        let part1:Float = Float(blockWidth) * Float(numBlocks) + padding * (Float(numBlocks) - 1 )
        let part2:Float = (Float(self.frame.size.width)) - part1
        
        let offset:Float = part2 / 2
        
        for row in 1 ... numRows{
            
            var yOffset:CGFloat{
                switch row {
                case 1:
                    return self.frame.size.height * 0.8
                case 2:
                    return self.frame.size.height * 0.6
                case 3:
                    return self.frame.size.height * 0.4
                default:
                    return 0
                }
            }
            
            for index in 1 ... numBlocks{
                let block = SKSpriteNode(imageNamed: "block")
                
                let calc1:Float = Float(index) - 0.5
                let calc2:Float = Float(index) - 1
                
                block.position = CGPoint(x: CGFloat(calc1 * Float(block.frame.size.width) + calc2 * padding + offset), y: yOffset)
                
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody?.allowsRotation = false
                block.physicsBody?.isDynamic = false
                block.physicsBody?.friction = 0
                block.name = blockCategoryName
                block.physicsBody?.categoryBitMask = blockCategory
                
                self.addChild(block)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.location(in: self)
        
        let body:SKPhysicsBody? = self.physicsWorld.body(at: touchLocation)
        
        if body?.node?.name == paddleCategoryName{
            print("paddle touched")
            fingerOnPaddle = true
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if fingerOnPaddle{
            let touch = touches.first! as UITouch
            let touchLocation = touch.location(in: self)
            let prevTouchLocation = touch.previousLocation(in: self)
            
            let paddle = self.childNode(withName: paddleCategoryName) as! SKSpriteNode
            
            var newX = paddle.position.x + (touchLocation.x - prevTouchLocation.x )
            
            newX = max(newX, paddle.size.width/2)
            newX = min(newX, self.size.width - paddle.size.width/2)
            
            paddle.position = CGPoint(x: newX, y: paddle.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory{
            let gameOverScene = GameOverScene(size: self.frame.size, playerWon: false)
            self.view?.presentScene(gameOverScene)
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blockCategory{
            secondBody.node?.removeFromParent()
            
            if (isGameWon()){
                let youWinScene = GameOverScene(size: self.frame.size, playerWon: true)
                self.view?.presentScene(youWinScene)
            }
        }
        
    }
    
    func isGameWon() -> Bool {
        var numBlocks = 0
        
        for nodeObject in self.children{
            let node = nodeObject as SKNode
            if node.name == blockCategoryName{
                numBlocks += 1
            }
        }
        return numBlocks <= 0
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
