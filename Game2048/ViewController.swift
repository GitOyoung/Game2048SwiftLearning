//
//  ViewController.swift
//  Game2048
//
//  Created by Oyoung on 15/12/6.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startGameButtonTouchUpInside(sender: UIButton) {
        let gameView: GameViewController = GameViewController(dimension: 4, threshold: 2048)
        self.presentViewController(gameView, animated: true, completion: nil)
    }

}

