//
//  GameBoardView.swift
//  Game2048
//
//  Created by oyoung on 15/12/10.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

class GameBoardView: UIView {

    var dimension : Int
    var tileWidth : CGFloat
    var tilePadding : CGFloat
    var cornerRadius : CGFloat
    var tiles : [NSIndexPath: TileView]
    
    let helper = TileHelper()
    
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tilePopWait: NSTimeInterval = 0.05
    let tileExpandTime: NSTimeInterval = 0.2
    let tileContractTime: NSTimeInterval = 0.08
    
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: NSTimeInterval = 0.08
    let tileMergeContractTime: NSTimeInterval = 0.08
    
    let perSquareSlideDuration: NSTimeInterval = 0.08
    
    init(dimension  d: Int, tileWidth width: CGFloat, tilePadding padding: CGFloat, cornerRadius radius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor) {
        assert(d > 0)
        dimension = d
        tileWidth = width
        tilePadding = padding
        cornerRadius = radius
        tiles = [NSIndexPath:TileView]()
        let frameWidth = padding + CGFloat(d) * (width + padding)
        super.init(frame: CGRect(x: 0, y: 0, width: frameWidth, height: frameWidth))
        layer.cornerRadius = radius
        setupBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        for (_, tile) in tiles {
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepCapacity: true)
    }
    
    func validPostion(pos: (Int, Int)) ->Bool {
        let (x, y) = pos
        return (x >= 0 && x < dimension && y >= 0 && y < dimension)
    }
    
    func setupBackground(backgroundColor bgColor: UIColor, tileColor: UIColor) {
        backgroundColor = bgColor
        var x = tilePadding
        var y : CGFloat
        let bgRadius = cornerRadius > 2 ? cornerRadius - 2 : 0
        for _ in 0..<dimension {
            y = tilePadding
            for _ in 0..<dimension {
                let background = UIView(frame: CGRect(x: x, y: y, width: tileWidth, height: tileWidth))
                background.layer.cornerRadius = bgRadius
                background.backgroundColor = tileColor
                addSubview(background)
                y += tileWidth + tilePadding
            }
            x += tileWidth + tilePadding
        }
    }
    
    func insertTile(pos:(Int, Int), value: Int) {
        assert(validPostion(pos))
        let (row, col) = pos
        let x = tilePadding + CGFloat(col) * (tileWidth + tilePadding)
        let y = tilePadding + CGFloat(row) * (tilePadding + tileWidth)
        let r = cornerRadius > 2 ? cornerRadius - 2 : 0
        let tile = TileView(position: CGPoint(x: x, y: y), width: tileWidth, value: value, radius: r, delegate: helper)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        
        addSubview(tile)
        bringSubviewToFront(tile)
        
        tiles[NSIndexPath(forRow: row, inSection: col)] = tile
        
        UIView.animateWithDuration(tileExpandTime,
            delay: tilePopWait,
            options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
            tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
            },
            completion: { finish in
                UIView.animateWithDuration(self.tileContractTime,
                    animations: { () -> Void in
                    tile.layer.setAffineTransform(CGAffineTransformIdentity)
            })
        })
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(validPostion(from) && validPostion(to))
        
        let (fromRow, fromCol) = from
        let (toRow, toCol) = to
        let fromKey = NSIndexPath(forRow: fromRow, inSection: fromCol)
        let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
        
        guard let tile = tiles[fromKey] else {
            assert(false, "Placeholder Error")
        }
        let endTile = tiles[toKey]
        
        var frame = tile.frame
        frame.origin.x = tilePadding + CGFloat(toCol) * (tilePadding + tileWidth)
        frame.origin.y = tilePadding + CGFloat(toRow) * (tilePadding + tileWidth)
        
        tiles.removeValueForKey(fromKey)
        tiles[toKey] = tile
        
        let shouldPop =  endTile != nil
        
        UIView.animateWithDuration(perSquareSlideDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                tile.frame = frame
            },  completion: { finish in
                tile.value = value
                endTile?.removeFromSuperview()
                if !shouldPop || !finish
                {
                    return
                }
                
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                
                UIView.animateWithDuration(self.tileMergeExpandTime, animations: { () -> Void in
                        tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    }, completion: { finish in
                        tile.layer.setAffineTransform(CGAffineTransformIdentity)
                })
        })
    }
    
    func moveTwoTile(from: ((Int, Int), (Int, Int)), to:(Int, Int), value: Int) {
        assert(validPostion(from.0) && validPostion(from.1) && validPostion(to))
        
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        
        let fromKeyA = NSIndexPath(forRow: fromRowA, inSection: fromColA)
        let fromKeyB = NSIndexPath(forRow: fromRowB, inSection: fromColB)
        let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
            assert(false, "Placeholder Error")
        }
        guard let tileB = tiles[fromKeyB] else {
            assert(false, "Placeholder Error")
        }
        
        var frame = tileA.frame
        frame.origin.x = tilePadding + CGFloat(toCol) * (tilePadding + tileWidth)
        frame.origin.y = tilePadding + CGFloat(toRow) * (tilePadding + tileWidth)
        
        tiles.removeValueForKey(fromKeyA)
        tiles.removeValueForKey(fromKeyB)
        
        tiles[toKey] = tileA
        
        UIView.animateWithDuration(perSquareSlideDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                tileA.frame = frame
                tileB.frame = frame
            },
            completion: { finish in
                tileA.value = value
                tileB.removeFromSuperview()
                if !finish {
                    return
                }
                tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                UIView.animateWithDuration(self.tileMergeExpandTime,
                    animations: { () -> Void in
                    tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    },
                    completion: { finish in
                        tileA.layer.setAffineTransform(CGAffineTransformIdentity)
                })
        })
    }

}
