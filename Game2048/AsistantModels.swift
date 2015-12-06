//
//  AsistantModels.swift
//  Game2048
//
//  Created by Oyoung on 15/12/6.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

enum MoveDirection {
    case Left
    case Right
    case Up
    case Down
}

struct MoveCmd {
    let direction: MoveDirection
    let completion: (Bool) -> ()
}

enum MoveOrder {
    case OnlyOneMoveOrder(source: Int, destination: Int, value: Int, needMerge: Bool)
    case DoubleMoveOrder(first: Int, second: Int, destination: Int, value: Int)
}

enum Tile {
    case Empty
    case Tile(Int)
}


struct GameBoard<T> {
    let dimension : Int
    var boardArray : [T]
    
    init(dimension d: Int, initValue: T) {
        dimension = d
        boardArray = [T](count: d * d, repeatedValue: initValue)
    }
    
    subscript(row: Int, colunm: Int) -> T {
        get {
            assert(row >= 0 && row < dimension)
            assert(colunm >= 0 && colunm < dimension)
            return boardArray[row * dimension + colunm]
        }
        set {
            assert(row >= 0 && row < dimension)
            assert(colunm >= 0 && colunm < dimension)
            boardArray[row * dimension + colunm] = newValue
        }
    }
    
    mutating func setupAll(item: T) {
        for i in 0..<dimension {
            for j in 0..<dimension {
                self[i, j] = item
            }
        }
        
    }
}


enum ActionToken{
    case NoAction(source: Int, value: Int)
    case Move(source: Int, value: Int)
    case SingleCombine(source: Int, value: Int)
    case DoubleCombine(first: Int, second: Int, value: Int)
    
    func getValue() ->Int {
        switch self {
        case let .NoAction(_, v): return v
        case let .Move(_, v): return v
        case let .SingleCombine(_, v): return v
        case let .DoubleCombine(_, _, v): return v
        }
    }
    
    func getSource() -> Int {
        switch self {
        case let .NoAction(s, _): return s
        case let .Move(s, _): return s
        case let .SingleCombine(s, _): return s
        case let .DoubleCombine(s, _, _): return s
        }
    }
}
