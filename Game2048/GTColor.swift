//
//  GTColor.swift
//  Game2048
//
//  Created by oyoung on 15/12/10.
//  Copyright © 2015年 Oyoung. All rights reserved.
//

import UIKit

class GTColor: NSObject {
    
    class func colorWithHexString(hex: String, alpha: CGFloat) -> UIColor {
        let newString = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        let newHex = NSString(string: newString)
        
        if newHex.length != 6 {
            return UIColor.clearColor()
        }
        
        var range: NSRange = NSRange()
        range.location = 0
        range.length = 2
        
        let redString: NSString = newHex.substringWithRange(range)
        
        range.location = 2
        let greenString: NSString = newHex.substringWithRange(range)
        
        range.location = 4
        let blueString: NSString = newHex.substringWithRange(range)
        var r : UInt32 = UInt32(0)
        var g : UInt32 = UInt32(0)
        var b : UInt32 = UInt32(0)
        NSScanner(string: redString as String).scanHexInt(&r)
        NSScanner(string: greenString as String).scanHexInt(&g)
        NSScanner(string: blueString as String).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }

}
