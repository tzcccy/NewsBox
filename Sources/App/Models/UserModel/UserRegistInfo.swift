//
//  UserLoginInfo.swift
//  App
//
//  Created by SuperT on 2018/5/9.
//

import Vapor
import FluentMySQL

final class UserRegistInfo : MySQLModel{
    static var entity = "user_regist_info"
    var id : Int?
    var username    :   String
    var password    :   String?
    var email       :   String?
    var verifycode  :   Int?
    init(_ id : Int?, _ username : String, password : String?, _ email : String?,_ verifycode : Int?) {
        self.id = id
        self.username = username
        self.password = password
        self.email    = email
        self.verifycode = verifycode
    }
}



extension UserRegistInfo : Migration { }
/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension UserRegistInfo: Content { }

