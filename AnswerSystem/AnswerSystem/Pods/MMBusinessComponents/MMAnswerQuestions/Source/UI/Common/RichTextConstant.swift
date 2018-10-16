//
//  RichTextConstant.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MMBaseComponents

#if RELEASE
    let domain = "https://www.jydsapp.com"
#elseif TEST
    let domain = "https://www.jydsapp.com"
#elseif DEV
    let domain = "https://www.jydsapp.com"
#else
    let domain = "https://www.jydsapp.com"
#endif

let writeWebUrl = "/jydsApi/h5/chswriter.html"

let ReadLastViewTag = 88888

func richTextRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat? = 1.0) -> UIColor {
    return UIColor(redColor: red, greenColor: green, blueColor: blue, alpha: alpha!)
}

//深灰色 #333333
let RTGrayColor = UIColor(hexString: "#333333")!
let RTLightGrayColor = UIColor(hexString: "#808080")!
let RTTextColor = UIColor(hexString: "#313131")!
//天蓝色
let RTThemeColor = UIColor(hexString: "#01CBCB")!
//分割线颜色
let RTSeperateColor = UIColor(hexString: "#C6C6C6")!
//背景颜色
let RTBackGroundColor = UIColor(hexString: "#F5F5F5")!
//option
let RTOptionBackGroundColor = UIColor(hexString: "#EDF5F5")!
//option border
let RTOptionBorderColor = UIColor(hexString: "#C9C9C9")!
let RTOrangeRed = UIColor(hexString: "#ff6864")!

//字体
let RTBiggestFont = UIFont.systemFont(ofSize: 22.0)
let RTBigFont = UIFont.systemFont(ofSize: 18.0)
let RTBoldNormalFont = UIFont.boldSystemFont(ofSize: 16.0)
let RTNormalFont = UIFont.systemFont(ofSize: 16.0)
let RTLessNormalFont = UIFont.systemFont(ofSize: 15.0)
let RTSmallFont = UIFont.systemFont(ofSize: 14.0)
let RTSmallLessFont = UIFont.systemFont(ofSize: 13.0)
let RTSmallestFont = UIFont.systemFont(ofSize: 13.0)
