//
//  ResponseModel.swift
//  App
//
//  Created by SuperT on 2018/5/9.
//

import Foundation
import Vapor

struct ResponseModel<T> : Content where T : Content{
    var status : Int
    var message : String

    var data : T?
    
}

