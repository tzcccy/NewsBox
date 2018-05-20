//
//  RequestModel.swift
//  App
//
//  Created by SuperT on 2018/5/10.
//

import Foundation
import Vapor
import FluentMySQL
import Crypto
/// 保证接口安全
struct SercretKey : MySQLModel{
    var id: Int?
    var sercretkey : String
}
extension SercretKey : Migration{ }
extension SercretKey{
    /// 检查是否授权
    static func JudgeSercretKey(sercreKey : String,req : Request)throws -> Future<Bool>{
        return try SercretKey.query(on: req).filter(\SercretKey.sercretkey == sercreKey).first().map(){result in
            if result == nil {
                return false
            }
            return true
        }
    }
}


final class RequestModel<T> : Content where T : Codable{
    
    var sercretkey : String
    var timestamp : Int
    var accessToken : String?
    var data : T?
    
    init(sercretkey : String, timestamp : Int) {
        self.sercretkey = sercretkey
        self.timestamp = timestamp
    }
}
