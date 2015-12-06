//
//  GameModel.swift
//  Game2048
//
//  Created by Oyoung on 15/12/6.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

//临时解决警告使用

protocol GameModelProtocol : class {
    func scoreChanged(score: Int)
    func moveOneTile(from:(Int, Int), to:(Int, Int), value:Int)
    func moveDoubleTiles(from:((Int, Int),(Int, Int)), to: (Int, Int), value:Int)
    func placeTile(location:(Int, Int),  value: Int)
}

class GameModel: NSObject {
    let dimension : Int
    let threshold : Int
    
    var gameboard: GameBoard<Tile>
    unowned let delegate : GameModelProtocol
    
    var score : Int = 0 {
        didSet{
            delegate.scoreChanged(score)
        }
    }
    
    var timer: NSTimer
    var queue: [MoveCmd]
    
    let maxCmdCount = 100
    let queueWait = 0.3
    
    init(dimension d: Int, threshold t: Int, delegate: GameModelProtocol) {
        dimension = d
        threshold = t
        self.delegate = delegate
        queue = [MoveCmd]()
        timer = NSTimer()
        gameboard = GameBoard(dimension: d, initValue: Tile.Empty)
        super.init()
    }
    
    func reset() {
        score = 0
        gameboard.setupAll(Tile.Empty)
        queue.removeAll(keepCapacity: true)
        timer.invalidate()
    }
    
    func queueMove(direction: MoveDirection, completion: (Bool) -> ()) {
        guard queue.count <= maxCmdCount else {
            return
        }
        queue.append(MoveCmd(direction: direction, completion: completion))
        if !timer.valid {
            timerFired()
        }
    }
    
    func timerFired() {
        if queue.count == 0 {
            return
        }
        
        var changed = false
        while queue.count > 0 {
            let cmd = queue[0]
            changed = performMove(cmd.direction)
            cmd.completion(changed)
            if changed {
                break;
            }
        }
        if changed {
            timer = NSTimer.scheduledTimerWithTimeInterval(queueWait,
                target: self,
                selector: Selector("timerFired"),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func performMove(direction: MoveDirection) -> Bool {
        
        
        let coordinateGenerator: (Int) -> [(Int, Int)] = { (iter: Int) -> [(Int, Int)] in
            var buffer = Array<(Int, Int)>(count: self.dimension, repeatedValue: (0, 0))
            for i in 0..<self.dimension {
                switch direction {
                case .Left: buffer[i] = (iter, i)
                case .Right:buffer[i] = (iter, self.dimension - i - 1)
                case .Up:   buffer[i] = (i, iter)
                case .Down: buffer[i] = (self.dimension - i - 1, iter)
                }
            }
            return buffer
        }
        
        var atLeastOneMove = false
        for i in 0..<dimension{
            let coords = coordinateGenerator(i)
            
            let tiles = coords.map({ (e: (Int, Int)) -> Tile in
                let (x, y) = e
                return self.gameboard[x, y]
            })
            
            let orders = merge(tiles)
            atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
            
            
            for order in orders {
                switch order {
                case let MoveOrder.OnlyOneMoveOrder(s, d, v, needMerge):
                    
                    let (sx, sy) = coords[s]
                    let (dx, dy) = coords[d]
                    if needMerge {
                        score += v
                    }
                    gameboard[sx, sy] = Tile.Empty
                    gameboard[dx, dy] = Tile.Tile(v)
                    delegate.moveOneTile(coords[s], to: coords[s], value: v)
                case let MoveOrder.DoubleMoveOrder(s1, s2, d, value: v):
                    
                    let (s1x, s1y) = coords[s1]
                    let (s2x, s2y) = coords[s2]
                    let (dx, dy) = coords[d]
                    score += v
                    gameboard[s1x, s1y] = Tile.Empty
                    gameboard[s2x, s2y] = Tile.Empty
                    gameboard[dx, dy] = Tile.Tile(v)
                    delegate.moveDoubleTiles((coords[s1], coords[s2]), to: coords[d], value: v)
                }
            }
        }
        return atLeastOneMove
    }
    
    
    func condense(group: [Tile]) -> [ActionToken] {
        return []
    }
    
    func collapse(group: [ActionToken]) -> [ActionToken] {
        return []
    }
    
    
    func convert(group: [ActionToken]) -> [MoveOrder]{
        
        var moveBuffer = [MoveOrder]()
        let enumerate = group.enumerate()
        for (i, t) in enumerate {
            switch t {
            case let .Move(s, v):
                moveBuffer.append(MoveOrder.OnlyOneMoveOrder(source: s, destination: i, value: v, needMerge: false))
            case let .SingleCombine(s, v):
                moveBuffer.append(MoveOrder.OnlyOneMoveOrder(source: s, destination: i, value: v, needMerge: true))
            case let .DoubleCombine(s1, s2, v):
                moveBuffer.append(MoveOrder.DoubleMoveOrder(first: s1, second: s2, destination: i, value: v))
            default:
                break
            }
        }
        return moveBuffer
    }
    
    func merge(group: [Tile]) -> [MoveOrder] {
        return convert(collapse(condense(group)))
    }
}
