//
//  TileHelper.swift
//  Game2048
//
//  Created by oyoung on 15/12/10.
//  Copyright © 2015年 Oyoung. All rights reserved.
//



import UIKit

protocol TileHelperProtocol: class {
    func tileColor(value: Int) -> UIColor
    func numberColor(value: Int) -> UIColor
    func fontForNumbers() -> UIFont
}

class TileHelper: TileHelperProtocol {
    
    // Provide a tile color for a given value
    func tileColor(value: Int) -> UIColor {
        switch value {
        case 2:
            return GTColor.colorWithHexString("EEE4DA", alpha: 1.0)
        case 4:
            return GTColor.colorWithHexString("EDE0C8", alpha: 1.0)
        case 8:
            return GTColor.colorWithHexString("F2B179", alpha: 1.0)
        case 16:
            return GTColor.colorWithHexString("F59563", alpha: 1.0)
        case 32:
            return GTColor.colorWithHexString("F67C5F", alpha: 1.0)
        case 64:
            return GTColor.colorWithHexString("F65E3B", alpha: 1.0)
        case 128, 256, 512, 1024, 2048:
            return GTColor.colorWithHexString("EDCF72", alpha: 1.0)
        default:
            return UIColor.whiteColor()
        }
    }
    
    // Provide a numeral color for a given value
    func numberColor(value: Int) -> UIColor {
        switch value {
        case 2, 4:
            return GTColor.colorWithHexString("776E64", alpha: 1.0)
        default:
            return UIColor.whiteColor()
        }
    }
    
    // Provide the font to be used on the number tiles
    func fontForNumbers() -> UIFont {
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 20) {
            return font
        }
        return UIFont.systemFontOfSize(20)
    }
}

