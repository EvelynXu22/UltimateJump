//
//  GameScene.swift
//  UltimateJump
//
//  Created by Yiwen Xu on 12/8/21.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    var motionManager: CMMotionManager!
    var ball = SKSpriteNode(imageNamed: "renwu1")
    var platforms = [SKSpriteNode]()
    var bottom = SKShapeNode()
    let stick = SKSpriteNode(imageNamed: "stickscore")
    let scoreLabel = SKLabelNode(text: "🌟0")
    var score = 0
    var highestScore = 0
    
    var isGameStarted = false
    var isSuperJumpOn = false
    
    let playJumpSound = SKAction.playSoundFileNamed("jump", waitForCompletion: false)
    let playBreakSound = SKAction.playSoundFileNamed("break", waitForCompletion: false)
   
    var superJumpCounter: CGFloat = 0
    let progressView = UIProgressView(progressViewStyle: UIProgressView.Style.default)
    
    var characterStage:Character = .char1 {
        didSet{
            switch characterStage{
            case .char1:
                
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu1")
                }
                break
            case .char2:
             
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu2")
                }
                break
            case .char3:
              
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu3")
                }
                break
            case .char4:
               
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu4")
                }
                break
            case .char5:
          
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu5")
                }
                break
            case .char6:
                
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu6")
                }
                break
            case .char7:
           
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu7")
                }
                break
            case .char8:
               
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu8")
                }
                break
            case .char9:
               
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu9")
                }
                break
            case .char10:
               
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu10")

                }
                break
            case .char11:
                
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu11")
                }
                break
            case .char12:
              
                DispatchQueue.main.async(){
                    self.ball.texture = SKTexture(imageNamed: "renwu12")
                }
                break
            }
            is_switch = false
        }
    }
    
    func nextCharacterStage(){
        switch self.characterStage {
        case .char1:
            self.characterStage = .char2
            break
        case .char2:
            self.characterStage = .char3
            break
        case .char3:
            self.characterStage = .char4
            break
        case .char4:
            self.characterStage = .char5
            break
        case .char5:
            self.characterStage = .char6
            break
        case .char6:
            self.characterStage = .char7
            break
        case .char7:
            self.characterStage = .char8
            break
        case .char8:
            self.characterStage = .char9
            break
        case .char9:
            self.characterStage = .char10
            break
        case .char10:
            self.characterStage = .char11
            break
        case .char11:
            self.characterStage = .char12
            break
        case .char12:
            self.characterStage = .char1
            break
        }
    }

    
    
    override func didMove(to view: SKView) {
        is_switch = false
        is_ah = false
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        layoutScene()
    }
    
    func layoutScene() {
        addBackground()
        addScoreCounter()
        spawnBall()
        addBottom()
        makePlatforms()
        makeEnergyBar()
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background-1")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = background.texture!.size()
        background.zPosition = ZPositions.background
        addChild(background)
    }
    
    func addScoreCounter() {
        stick.texture = SKTexture(imageNamed: "stickscore")
        stick.position = CGPoint(x: 20 + stick.size.width/2, y: frame.height - (view?.safeAreaInsets.top ?? 10) - 20)
        stick.zPosition = ZPositions.stick
        addChild(stick)
        
        scoreLabel.fontSize = 24.0
        scoreLabel.fontName = "HelveticaNeue-Bold"
        scoreLabel.fontColor = UIColor.init(red: 0, green: 153/255, blue: 73/255, alpha: 1)
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: stick.position.x + stick.frame.width/2 + 10, y: stick.position.y)
        scoreLabel.zPosition = ZPositions.scoreLabel
        addChild(scoreLabel)
    }
    
    func spawnBall() {
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: 20 + ball.size.height/2)
        ball.zPosition = ZPositions.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory | PhysicsCategories.deerWithSanta | PhysicsCategories.tweet
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
    }
    
    func addBottom() {
        bottom = SKShapeNode(rectOf: CGSize(width: frame.width*2, height: 20))
        bottom.position = CGPoint(x: frame.midX, y: 10)
        bottom.fillColor = UIColor.init(red: 25/255, green: 105/255, blue: 81/255, alpha: 1)
        bottom.strokeColor = bottom.fillColor
        bottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 20))
        bottom.physicsBody?.affectedByGravity = false
        bottom.physicsBody?.isDynamic = false
        bottom.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        addChild(bottom)
    }
    
    func makePlatforms() {
        let spaceBetweenPlatforms = frame.size.height/15
        for i in 0..<Int(frame.size.height/spaceBetweenPlatforms) {
            let x = CGFloat.random(in: 0...frame.size.width)
            let y = CGFloat.random(in: CGFloat(i)*spaceBetweenPlatforms+15...CGFloat(i+1)*spaceBetweenPlatforms-15)
            spawnPlatform(at: CGPoint(x: x, y: y))
        }
    }
    
    func spawnPlatform(at position: CGPoint) {
        var platform = SKSpriteNode()
        if position.x < frame.midX {
            platform = SKSpriteNode(imageNamed: "tileLeft")
        }
        else {
            platform = SKSpriteNode(imageNamed: "tileRight")
        }
        platform.position = position
        platform.zPosition = ZPositions.platform
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platforms.append(platform)
        addChild(platform)
    }
    
    func makeEnergyBar(){
      
//        set position
        progressView.center = CGPoint(x: frame.size.width/7*2, y: frame.size.height/20)
//        set size
        progressView.transform = CGAffineTransform(scaleX: 1.5, y: 3.0)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 5
        progressView.progressImage = UIImage(named:"bar")
        progressView.trackImage = UIImage(named: "bg")
        view?.addSubview(progressView)
        
//        initiate start state
        progressView.progress = 0.0
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkPhoneTilt()
        if isGameStarted {
            checkBallPosition()
            checkBallVelocity()
            updatePlatformsPositions()
            checkSwitch()
//            checkAh()
        }
    }
    func checkSwitch(){
        if is_switch == true{
//            Test: switch monster here
            print("----SWITCh----")
            is_switch = false
            nextCharacterStage()
            
        }
    }
    
    func checkPhoneTilt() {
        var defaultAcceleration = 9.8
        if let accelerometerData = motionManager.accelerometerData {
            var xAcceleration = accelerometerData.acceleration.x * 10
            if xAcceleration > defaultAcceleration {
                xAcceleration = defaultAcceleration
            }
            else if xAcceleration < -defaultAcceleration {
                xAcceleration = -defaultAcceleration
            }
            ball.run(SKAction.rotate(toAngle: CGFloat(-xAcceleration/5), duration: 0.1))
            if isGameStarted {
                if isSuperJumpOn {
                    defaultAcceleration = -0.1
                }
                physicsWorld.gravity = CGVector(dx: xAcceleration, dy: -defaultAcceleration)
            }
        }
    }
    
    func checkBallPosition() {
        let ballWidth = ball.size.width
        if ball.position.y+ballWidth < 0 {
            run(SKAction.playSoundFileNamed("gameOver", waitForCompletion: false))
            saveScore()
            progressView.removeFromSuperview()
            let menuScene = MenuScene.init(size: view!.bounds.size)
            view?.presentScene(menuScene)
            
            
        }
        setScore()
        if ball.position.x-ballWidth >= frame.size.width || ball.position.x+ballWidth <= 0 {
            fixBallPosition()
        }
    }
    
    func saveScore() {
        UserDefaults.standard.setValue(highestScore, forKey: "LastScore")
        if highestScore > UserDefaults.standard.integer(forKey: "HighScore") {
            UserDefaults.standard.setValue(highestScore, forKey: "HighScore")
        }
    }
    var reScore:Float = 0.0
    var is_energyfill = false
    
    func setScore() {
        let oldScore = score
        score = (Int(ball.position.y) - Int(ball.size.height/2)) - (Int(bottom.position.y) - Int(bottom.frame.size.height)/2)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.progressView.setProgress((Float(oldScore)-self.reScore)/3000, animated:true)
            if(self.progressView.progress == 1.0){
                self.is_energyfill = true
                
            }
        }
        
        score = score < 0 ? 0 : score
        if score > oldScore {
            stick.texture = SKTexture(imageNamed: "stickscore")
            scoreLabel.fontColor = UIColor.init(red: 0, green: 153/255, blue: 73/255, alpha: 1)
            if score > highestScore {
                highestScore = score
            }
        }
        else {
            stick.texture = SKTexture(imageNamed: "stickscorebreak")
            scoreLabel.fontColor = UIColor.init(red: 255, green: 87/255, blue: 87/255, alpha: 1)
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        let formattedScore = numberFormatter.string(from: NSNumber(value: score))
        scoreLabel.text = "🌟" + (formattedScore ?? "0")
        
    
        
    }
    
    func checkBallVelocity() {
        if let ballVelocity = ball.physicsBody?.velocity.dx {
            if ballVelocity > 1000 {
                ball.physicsBody?.velocity.dx = 1000
            }
            else if ballVelocity < -1000 {
                ball.physicsBody?.velocity.dx = -1000
            }
        }
    }
    
    func updatePlatformsPositions() {
        var minimumHeight: CGFloat = frame.size.height/2
        guard let ballVelocity = ball.physicsBody?.velocity.dy else {
            return
        }
        var distance = ballVelocity/50
        if isSuperJumpOn {
            minimumHeight = 0
            distance = 30 - superJumpCounter
            superJumpCounter += 0.16
        }
        if ball.position.y > minimumHeight && ballVelocity > 0 {
            for platform in platforms {
                platform.position.y -= distance
                if platform.position.y < 0-platform.frame.size.height/2 {
                    update(platform: platform, positionY: platform.position.y)
                }
            }
            bottom.position.y -= distance
        }
    }
    
    func update(platform: SKSpriteNode, positionY: CGFloat) {
        platform.position.x = CGFloat.random(in: 0...frame.size.width)
        
        var direction = "Left"
        if platform.position.x > frame.midX {
            direction = "Right"
        }
        
        platform.removeAllActions()
        platform.alpha = 1.0
        if Int.random(in: 1...35) == 1 {
            platform.texture = SKTexture(imageNamed: "bouncy")
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.tweet
        }
        else if Int.random(in: 1...5) == 1 {
            platform.texture = SKTexture(imageNamed: "stickcandymove" + direction)
            
//            print("strapOfDollars" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
            if direction == "Left" {
                platform.position.x = 0
                animate(platform: platform, isLeft: true)
            }
            else {
                platform.position.x = frame.size.width
                animate(platform: platform, isLeft: false)
            }
        }
        else if Int.random(in: 1...5) == 1 {
            platform.texture = SKTexture(imageNamed: "deer" + direction)
            
            
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.deerWithSanta
        }
        else {
            platform.texture = SKTexture(imageNamed: "tile" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        }
        
        platform.position.y = frame.size.height + platform.frame.size.height/2 + platform.position.y
    }
    
    func updateSizeOf(platform: SKSpriteNode) {
        if let textureSize = platform.texture?.size() {
            platform.size = CGSize(width: textureSize.width, height: textureSize.height)
            platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.affectedByGravity = false
        }
    }
    
    func animate(platform: SKSpriteNode, isLeft: Bool) {
        let distanceX = isLeft ? frame.size.width : -frame.size.width
        platform.run(SKAction.moveBy(x: distanceX, y: 0, duration: 2)) {
            platform.run(SKAction.moveBy(x: -distanceX, y: 0, duration: 2)) {
                self.animate(platform: platform, isLeft: isLeft)
            }
        }
    }
    
    func fixBallPosition() {
        let ballWidth = ball.size.width
        if ball.position.x >= frame.size.width {
            ball.position.x = 0 - ballWidth/2+1
        }
        else {
            ball.position.x = frame.size.width + ballWidth/2-1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameStarted {
            ball.physicsBody?.velocity.dy = frame.size.height*1.2 - ball.position.y
            is_gamestart = true
            isGameStarted = true
            run(playJumpSound)
        }
    }

}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if let ballVelocity = ball.physicsBody?.velocity.dy {
            if ballVelocity < 0 {

                if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.platformCategory {
                    run(playJumpSound)
                    ball.physicsBody?.velocity.dy = frame.size.height*1.2 - ball.position.y
//                    print("ContacatMask:",contactMask)
                }
                else if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.deerWithSanta {
                    run(playJumpSound)
                    run(playBreakSound)
//                    print("ContacatMask:",contactMask)
                    ball.physicsBody?.velocity.dy = frame.size.height*1.2 - ball.position.y
                    if let platform = (contact.bodyA.node?.name != "Ball") ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                        platform.physicsBody?.categoryBitMask = PhysicsCategories.none
                        platform.run(SKAction.fadeOut(withDuration: 0.5))
                    }
                }
                else if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.tweet {
                    run(SKAction.playSoundFileNamed("superJump", waitForCompletion: false))
                    ball.physicsBody?.velocity.dy = 10
                    isSuperJumpOn = true
//                    print("ContacatMask:",contactMask)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isSuperJumpOn = false
                        self.superJumpCounter = 0
                    }
                }
//                Energy filled, shouted Ah--- and contact with tile
                if contactMask != PhysicsCategories.ballCategory{
                    if is_ah == true && is_energyfill == true{
//                    Test
//                      if is_energyfill == true{
                        run(SKAction.playSoundFileNamed("superJump", waitForCompletion: false))
                        
//                        Test
//                        is_switch = true
                        print("----Ah----")
                        
                        ball.physicsBody?.velocity.dy = 10
                        isSuperJumpOn = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            self.isSuperJumpOn = false
                            self.superJumpCounter = 0
                            is_ah = false
                            
                            self.progressView.setProgress(0.0, animated: false)
                            self.is_energyfill = false
                            self.reScore = Float(self.score)
                        }
                    }
                    else{
                        is_ah = false
                    }
                        
                }
                
            }
        }
    }
}
