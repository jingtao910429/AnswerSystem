//
//  AnswerSystemConstants.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MMToolHelper

public var JionLineTextBtnWidth = CGFloat(60)
public let JionLineTextBtnHeight = CGFloat(30)
public let JionLineTextBtnMaxWidth = CGFloat(80)
public let JionLineTextBtnMaxHeight = CGFloat(60)
public let JionLineTextBtnVerSpace = CGFloat(30)

public let GoldScale = CGFloat(0.382)
public let AnswerParseBottomControlHeight = CGFloat(28)
public let AnswerParseBottomHeight = CGFloat(-50)
public let iPadTabWidth = CGFloat(70)

public let MMAnswerSystemPhotoBrowserNotification = NSNotification.Name(rawValue: "MMAnswerSystemPhotoBrowserNotification")
public let MMAnswerSystemPhotoPickNotification = NSNotification.Name(rawValue: "MMAnswerSystemPhotoPickNotification")
public let MMAnswerSystemPhotoPickAlbumNotification = NSNotification.Name(rawValue: "MMAnswerSystemPhotoPickAlbumNotification")
public let MMAnswerSystemPhotoPickCameraNotification = NSNotification.Name(rawValue: "MMAnswerSystemPhotoPickCameraNotification")
public let MMAnswerSystemAudioPlayNotification = NSNotification.Name(rawValue: "MMAnswerSystemAudioPlayNotification")
public let MMAnswerSystemAudioStopPlayNotification = NSNotification.Name(rawValue: "MMAnswerSystemAudioStopPlayNotification")
public let MMAnswerSystemExerciseObjectModifyStatusUpdate = NSNotification.Name(rawValue: "MMAnswerSystemExerciseObjectModifyStatusUpdate")

public enum ExerciseStyle: Int {
    case None                                       = -1
    //读短文完成练习 (大题带小题的)
    case ReadPassageFinishExercise                  = 1
    //填空题
    case Fill                                       = 2
    //单选选择题(显示选项编号)
    case ChooseShowCode                             = 3
    //单选选择题(不显示选项编号)
    case ChooseNoShowCode                           = 16
    //单选选择题(显示选项编号，一个选项只能填入一个位置)
    case ChooseShowCodeOnePosition                  = 17
    //单选选择题(不显示选项编号，一个选项只能填入一个位置)
    case ChooseNoShowCodeOnePosition                = 18
    //多选填空题(显示选项编号)
    case ChooseFillShowCode                         = 4
    //多选选择题(不显示选项编号)
    case ChooseFillNoShowCode                       = 19
    //多选选择题(显示选项编号，一个选项只能填入一个位置)
    case ChooseFillShowCodeOnePosition              = 20
    //多选选择题(不显示选项编号，一个选项只能填入一个位置)
    case ChooseFillNoShowCodeOnePosition            = 21
    //圈选
    case CircleChoose                               = 22
    //连一连(2段)
    case MatchLineTwoOption                         = 5
    //连一连(3段)
    case MatchLineThreeOption                       = 6
    //判断题(正误判断,勾选判断)
    case Jude                                       = 7
    //读一读(文字)
    case Read                                       = 8
    //写一写(按笔顺写字)
    case WriteCharacter                             = 9
    //连词成句
    case AppendCharcterProduceSentence              = 10
    //连词成句 condition one
    case AppendCharcterProduceSentenceConditonOne   = 11
    //鸡蛋放入篮子(多个篮子)
    case EggIntoBaskets                             = 12
    //读一读(拼音)
    case PinyinRead                                 = 13
    //写一写(拼音)
    case PinyinWrite                                = 14
    //写一写(编辑文字,上传图片)
    case WriteUploadImage                           = 15
}

public enum QuestionStatus {
    //未开始
    case NoStart
    //未完成
    case NoFinish
    //答对
    case Right
    //答错
    case Wrong
}

public class AnswerSystemConstants: NSObject {
}
