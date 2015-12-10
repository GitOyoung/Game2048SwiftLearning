//
//  ScoreView.swift
//  Game2048
//
//  Created by oyoung on 15/12/10.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

protocol ScoreViewProtocol : class {
    func scoreChanged(score: Int);
}

class ScoreView: UIView, ScoreViewProtocol {
    
    let defaultFrame = CGRect(x: 0, y: 0, width: 150, height: 50)

    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var scoreLabel: UILabel
 
    init(backgroundColor bgColor:UIColor, textColor: UIColor, font: UIFont, radius r: CGFloat) {
        scoreLabel = UILabel(frame: defaultFrame)
        super.init(frame: defaultFrame)
        scoreLabel.textColor = textColor
        scoreLabel.backgroundColor = bgColor
        scoreLabel.textAlignment = NSTextAlignment.Center
        backgroundColor = bgColor
        scoreLabel.font = font
        layer.cornerRadius = r
        addSubview(scoreLabel)
    }
    
    func scoreChanged(score: Int) {
        self.score = score
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
