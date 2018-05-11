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



final class RequestModel<T> : Content where T : Content{
    
    var sercretkey : String
    var timestamp : Int
    var accessToken : String?
    var data : T?
}

extension RequestModel{
    
    /// 检查是否授权
    func JudgeSercretKey(req : Request)throws -> Future<Bool>{
        return try SercretKey.query(on: req).filter(\SercretKey.sercretkey == self.sercretkey).first().map(){result in
            if result == nil {
                return false
            }
            return true
        }
    }
}
