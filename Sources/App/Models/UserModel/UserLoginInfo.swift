//
//  UserLoginInfo.swift
//  App
//
//  Created by SuperT on 2018/5/11.
//

import Foundation
import Vapor
import FluentMySQL


final class UserLoginInfo : Content {
    var username    :   String
    var password    :   String
    
    init(username : String, password : String){
        self.username = username
        self.password = password
    }
}


