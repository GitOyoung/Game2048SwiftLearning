//
//  GameViewController.swift
//  Game2048
//
//  Created by Oyoung on 15/12/6.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, GameModelProtocol {
    
    var dimension : Int
    var threshold : Int
    
    var gameboard: GameBoardView?
    var gameModel: GameModel?
    
    var scoreView: ScoreView?
    
    let boardWidth: CGFloat = 300
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0
    
    let viewPadding: CGFloat = 40.0
    let verticalViewOffset: CGFloat = 0.0
    
    init(dimension d: Int, threshold t: Int) {
        dimension = d > 4 ? d : 4
        threshold = t > 8 ? t : 8
        
        super.init(nibName: nil, bundle: nil)
        gameModel = GameModel(dimension: d, threshold: t, delegate: self)
        
        view.backgroundColor = UIColor.whiteColor()
        setupSwipGestureRecognizers()
    }
    
    func setupSwipGestureRecognizers() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("up:"))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("down:"))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("left:"))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("right:"))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    
    //分数变化响应
    func scoreChanged(score: Int) {
        guard scoreView != nil else {
            return
        }
        let s = scoreView!
        s.scoreChanged(score)
    }
    //移动一个方块
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        guard gameboard != nil else {
            return
        }
        let b = gameboard!
        b.moveOneTile(from, to: to, value: value)
    }
    //移动两个方块(叠加)
    func moveDoubleTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        guard gameboard != nil else {
            return
        }
        let b = gameboard!
        b.moveTwoTile(from, to: to, value: value)
    }
    //放置一个方块
    func placeTile(location: (Int, Int), value: Int) {
        guard gameboard != nil else {
            return
        }
        let b = gameboard!
        b.insertTile(location, value: value)
    }
    
    func setupGame() {
        let vcHeight = view.bounds.size.height
        let vcWidth = view.bounds.size.width
        
        // This nested function provides the x-position for a component view
        func xPositionToCenterView(v: UIView) -> CGFloat {
            let viewWidth = v.bounds.size.width
            let tentativeX = 0.5*(vcWidth - viewWidth)
            return tentativeX >= 0 ? tentativeX : 0
        }
        // This nested function provides the y-position for a component view
        func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat {
            assert(views.count > 0)
            assert(order >= 0 && order < views.count)
            //      let viewHeight = views[order].bounds.size.height
            let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, combine: { $0 + $1 })
            let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0
            
            // Not sure how to slice an array yet
            var acc: CGFloat = 0
            for i in 0..<order {
                acc += viewPadding + views[i].bounds.size.height
            }
            return viewsTop + acc
        }
        
        // Create the score view
        let scoreView = ScoreView(backgroundColor: UIColor.blackColor(),
            textColor: UIColor.whiteColor(),
            font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFontOfSize(16.0),
            radius: 6)
        scoreView.score = 0
        
        // Create the gameboard
        let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
        let v1 = boardWidth - padding*(CGFloat(dimension + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
        let gameboard = GameBoardView(dimension: dimension,
            tileWidth: width,
            tilePadding: padding,
            cornerRadius: 6,
            backgroundColor: UIColor.blackColor(),
            foregroundColor: UIColor.darkGrayColor())
        let resetButton = UIButton(frame: CGRect(x: 0, y: 0, width: 160, height: 50))
        
        // Set up the frames
        let views = [scoreView, gameboard, resetButton]
        
        var f = scoreView.frame
        f.origin.x = xPositionToCenterView(scoreView)
        f.origin.y = yPositionForViewAtPosition(0, views: views)
        scoreView.frame = f
        
        f = gameboard.frame
        f.origin.x = xPositionToCenterView(gameboard)
        f.origin.y = yPositionForViewAtPosition(1, views: views)
        gameboard.frame = f
        
        f = resetButton.frame
        f.origin.x = xPositionToCenterView(resetButton)
        f.origin.y = yPositionForViewAtPosition(2, views: views)
        resetButton.frame = f
        
        resetButton.setTitle("重新开始", forState: UIControlState.Normal)
        resetButton.backgroundColor = UIColor.greenColor()
        resetButton.addTarget(self, action: Selector("reset:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        // Add to game state
        view.addSubview(gameboard)
        self.gameboard = gameboard
        view.addSubview(scoreView)
        self.scoreView = scoreView
        view.addSubview(resetButton)
        
        assert(gameModel != nil)
        let m = gameModel!
        m.placeTileAtRandomLocation(2)
        m.placeTileAtRandomLocation(2)
    }
    
    @objc(reset:)
    func Reset(r: UIButton) {
        reset()
    }
    
    func reset() {
        assert(gameboard != nil && gameModel != nil)
        let b = gameboard!
        let m = gameModel!
        b.reset()
        m.reset()
        m.placeTileAtRandomLocation(2)
        m.placeTileAtRandomLocation(2)
    }
    private var isWin: Bool = false
    
    func followUp() {
        assert(gameModel != nil)
        let m = gameModel!
        let (userWon, _) = m.win()
        if userWon  && !isWin {
            isWin = true
            // TODO: alert delegate we won
            let alertView = UIAlertView()
            alertView.title = "恭喜"
            alertView.message = "你赢了"
            alertView.addButtonWithTitle("继续")
            alertView.show()
            // TODO: At this point we should stall the game until the user taps 'New Game' (which hasn't been implemented yet)
            return
        }
        
        // Now, insert more tiles
        let randomVal = Int(arc4random_uniform(10))
        m.placeTileAtRandomLocation(randomVal == 1 ? 4 : 2)
        
        // At this point, the user may lose
        if m.gameOver() {
            // TODO: alert delegate we lost
            NSLog("You lost...")
            let alertView = UIAlertView()
            alertView.title = "游戏结束"
            alertView.message = "胜败乃兵家常事，大侠请重新来过"
            alertView.addButtonWithTitle("知道了")
            alertView.show()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc(up:)
    func Up(r: UIGestureRecognizer!) {
        assert(gameModel != nil)
        let m = gameModel!
        m.queueMove(MoveDirection.Up,
            completion:  { finish in
            if finish {
                self.followUp()
            }
        })
    }
    @objc(down:)
    func Down(r: UIGestureRecognizer!) {
        assert(gameModel != nil)
        let m = gameModel!
        m.queueMove(MoveDirection.Down,
            completion:  { finish in
                if finish {
                    self.followUp()
                }
        })
    }
    @objc(left:)
    func Left(r: UIGestureRecognizer!) {
        assert(gameModel != nil)
        let m = gameModel!
        m.queueMove(MoveDirection.Left,
            completion:  { finish in
                if finish {
                    self.followUp()
                }
        })
    }
    @objc(right:)
    func Right(r: UIGestureRecognizer!) {
        assert(gameModel != nil)
        let m = gameModel!
        m.queueMove(MoveDirection.Right,
            completion:  { finish in
                if finish {
                    self.followUp()
                }
        })
    }


}
