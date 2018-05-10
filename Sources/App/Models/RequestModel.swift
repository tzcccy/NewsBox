//
//  RequestModel.swift
//  App
//
//  Created by SuperT on 2018/5/10.
//

import Foundation
import Vapor

struct RequestModel : Content{
    var status : Int
    var message : String
}
