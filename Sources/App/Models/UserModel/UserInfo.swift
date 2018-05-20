//
//  UserInfo.swift
//  App
//
//  Created by SuperT on 2018/5/16.
//

import Foundation
import Vapor
import FluentMySQL


final class UserInfo : MySQLModel {
    static var entity = "user_info"
    
    var id: Int?
    var username    :   String?
    var nickname    :   String?
    var headpic    :   String?
    var six         :   String?
    var note        :   String?
}


extension UserInfo{
    func mergeUser(orginUser : UserInfo) -> UserInfo{
        if nil == self.id {
            self.id = orginUser.id
        }
        if nil == self.username {
            self.username = orginUser.username
        }
        if nil == self.nickname {
            self.nickname = orginUser.nickname
        }
        if nil == self.headpic {
            self.headpic = orginUser.headpic
        }
        if nil == self.six {
            self.six = orginUser.six
        }
        if nil == self.note {
            self.note = orginUser.note
        }
        return self;
    }
}


extension UserInfo : Migration { }

extension UserInfo : Content { }
