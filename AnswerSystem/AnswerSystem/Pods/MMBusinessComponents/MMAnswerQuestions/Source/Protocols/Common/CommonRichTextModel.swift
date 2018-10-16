//
//  CommonRichTextModel.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/22.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper

// 数据模型不可空字段判断组件
public protocol RichTextNonnilMappable: Mappable {
    var nonnilMapProperties: [String] { get }
    func shouldReturnNil(_ map: Map) -> Bool
}

public extension RichTextNonnilMappable {
    func shouldReturnNil(_ map: Map) -> Bool {
        for property in nonnilMapProperties {
            if map[property].currentValue == nil {
                return true
            }
        }
        return false
    }
}

// 数据处理通用组件
public protocol RichTextMapperModelConvertible {
    static func mapModel(_ dictionary: [String: Any]) -> Self?
}

public extension RichTextMapperModelConvertible where Self: Mappable {
    static func mapModel(_ dictionary: [String: Any]) -> Self? {
        return Mapper<Self>().map(JSON: dictionary)
    }
}

class RichTextTransformInt : TransformType {
    
    typealias Object = Int
    
    typealias JSON = String
    
    func transformFromJSON(_ value: Any?) -> Int? {
        if let value = value as? String {
            return value.intValue()
        }
        
        return nil
    }
    
    func transformToJSON(_ value: Int?) -> String? {
        if let value = value {
            return "\(value)"
        }
        return nil
    }
    
}

class RichTextJsonModelTransform<T: BaseMappable>: TransformType {
    
    typealias Object = T
    
    typealias JSON = String
    
    func transformFromJSON(_ value: Any?) -> T? {
        if let value = value as? String {
            return Mapper<T>().map(JSONString: value)
        }
        
        return nil
    }
    
    func transformToJSON(_ value: T?) -> String? {
        if let value = value {
            return value.toJSONString()
        }
        return nil
    }
    
}

class CommonRichTextModel: NSObject {

}
