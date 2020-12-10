//
//  GameOverScene.swift
//  Breakout
//
//  Created by Dylan Vannatter on 12/10/20.
//

import SpriteKit

class GameOverScene: SKScene {

    init(size: CGSize, playerWon: Bool) {
        super.init(size: size)
        
        let backgroundImage = SKSpriteNode(imageNamed: "bg")
        backgroundImage.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(backgroundImage)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Black")
        gameOverLabel.fontSize = 46
        gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        
        
        if playerWon{
            gameOverLabel.text = "YOU WIN!"
        }
        else{
            gameOverLabel.text = "GAME OVER!"
        }
        
        self.addChild(gameOverLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let breakOutGameScene = GameScene(size: self.size)
        self.view?.presentScene(breakOutGameScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
