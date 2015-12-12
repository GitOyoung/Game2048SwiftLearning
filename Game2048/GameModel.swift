//
//  GameModel.swift
//  Game2048
//
//  Created by Oyoung on 15/12/6.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit



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
            TimerTick()
        }
    }
    
    func TimerTick() {
        if queue.count == 0 {
            return
        }
        
        var changed = false
        while queue.count > 0 {
            let cmd = queue[0]
            queue.removeAtIndex(0)
            changed = performMove(cmd.direction)
            cmd.completion(changed)
            if changed {
                break;
            }
        }
        if changed {
            timer = NSTimer.scheduledTimerWithTimeInterval(queueWait,
                target: self,
                selector: Selector("TimerTick"),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func tileBelowHasSameValue(location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard y != dimension - 1 else {
            return false
        }
        if case let .Tile(v) = gameboard[x, y+1] {
            return v == value
        }
        return false
    }
    
    func tileToRightHasSameValue(location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard x != dimension - 1 else {
            return false
        }
        if case let .Tile(v) = gameboard[x+1, y] {
            return v == value
        }
        return false
    }
    func gameboardEmptySpots() -> [(Int, Int)] {
        var emptyBuffer : [(Int, Int)] = []
        for i in 0..<dimension {
            for j in 0..<dimension {
                if case .Empty = gameboard[i, j] {
                    emptyBuffer += [(i, j)]
                }
            }
        }
        return emptyBuffer
    }
    
    func placeTile(position: (Int, Int), value: Int) {
        let (x, y) = position
        if case .Empty = gameboard[x, y] {
            gameboard[x, y] = Tile.Tile(value)
            delegate.placeTile(position, value: value)
        }
    }
    
    /// Insert a tile with a given value at a random open position upon the gameboard.
    func placeTileAtRandomLocation(value: Int) {
        let openSpots = gameboardEmptySpots()
        if openSpots.isEmpty {
            // No more open spots; don't even bother
            return
        }
        // Randomly select an open spot, and put a new tile there
        let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
        let (x, y) = openSpots[idx]
        placeTile((x, y), value: value)
    }
    
    
    func gameOver() -> Bool {
        guard gameboardEmptySpots().isEmpty else {
            // Player can't lose before filling up the board
            return false
        }
        
        // Run through all the tiles and check for possible moves
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gameboard[i, j] {
                case .Empty:
                    assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
                case let .Tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileToRightHasSameValue((i, j), v) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func win() -> (Bool, (Int, Int)?) {
        for i in 0..<dimension {
            for j in 0..<dimension {
                // Look for a tile with the winning score or greater
                if case let .Tile(v) = gameboard[i, j] where v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
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
                    delegate.moveOneTile(coords[s], to: coords[d], value: v)
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
        var tokenBuffer = [ActionToken]()
        for (idx, tile) in group.enumerate() {
            // Go through all the tiles in 'group'. When we see a tile 'out of place', create a corresponding ActionToken.
            switch tile {
            case let .Tile(value) where tokenBuffer.count == idx:
                tokenBuffer.append(ActionToken.NoAction(source: idx, value: value))
            case let .Tile(value):
                tokenBuffer.append(ActionToken.Move(source: idx, value: value))
            default:
                break
            }
        }
        return tokenBuffer;
    }
    
    class func quiescentTileStillQuiescent(inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool
    {
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }
    
    func collapse(group: [ActionToken]) -> [ActionToken] {
        
        var tokenBuffer = [ActionToken]()
        var skipNext = false
        for (idx, token) in group.enumerate() {
            if skipNext {
                // Prior iteration handled a merge. So skip this iteration.
                skipNext = false
                continue
            }
            switch token {
            case .SingleCombine:
                assert(false, "Cannot have single combine token in input")
            case .DoubleCombine:
                assert(false, "Cannot have double combine token in input")
            case let .NoAction(s, v)
                where (idx < group.count-1
                    && v == group[idx+1].getValue()
                    && GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s)):
                // This tile hasn't moved yet, but matches the next tile. This is a single merge
                // The last tile is *not* eligible for a merge
                let next = group[idx+1]
                let nv = v + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.SingleCombine(source: next.getSource(), value: nv))
            case let t where (idx < group.count-1 && t.getValue() == group[idx+1].getValue()):
                // This tile has moved, and matches the next tile. This is a double merge
                // (The tile may either have moved prevously, or the tile might have moved as a result of a previous merge)
                // The last tile is *not* eligible for a merge
                let next = group[idx+1]
                let nv = t.getValue() + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.DoubleCombine(first: t.getSource(), second: next.getSource(), value: nv))
            case let .NoAction(s, v) where !GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s):
                // A tile that didn't move before has moved (first cond.), or there was a previous merge (second cond.)
                tokenBuffer.append(ActionToken.Move(source: s, value: v))
            case let .NoAction(s, v):
                // A tile that didn't move before still hasn't moved
                tokenBuffer.append(ActionToken.NoAction(source: s, value: v))
            case let .Move(s, v):
                // Propagate a move
                tokenBuffer.append(ActionToken.Move(source: s, value: v))
            default:
                // Don't do anything
                break
            }
        }
        return tokenBuffer
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
