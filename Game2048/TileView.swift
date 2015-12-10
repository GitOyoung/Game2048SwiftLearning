//
//  TileView.swift
//  Game2048
//
//  Created by oyoung on 15/12/10.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

class TileView: UIView {
    var value: Int = 0{
        didSet{
            backgroundColor = delegate.tileColor(value)
            numberLabel.textColor = delegate.numberColor(value)
            numberLabel.backgroundColor = delegate.tileColor(value)
            numberLabel.text = "\(value)"
        }
    }
    
    let numberLabel: UILabel
    unowned let delegate: TileHelperProtocol

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: TileHelperProtocol) {
        delegate = d
        numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))
        numberLabel.textAlignment = NSTextAlignment.Center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = delegate.fontForNumbers()
        
        super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))
        layer.cornerRadius = radius
        numberLabel.layer.cornerRadius = radius
        addSubview(numberLabel)
        
        self.value = value
        numberLabel.backgroundColor = delegate.tileColor(value)
        numberLabel.textColor = delegate.numberColor(value)
        numberLabel.text = "\(value)"
        
    }

}
