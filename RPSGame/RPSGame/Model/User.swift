//
//  User.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/05.
//

import Foundation
import Firebase

struct User {
    let ID: String
    let name: String
    let profileThumbnailImageURL: String
    let record: Record

    let def = Database.database()
    
    var isLogin: Bool
    var isInGame: Bool //게임중일땐 초대 못하도록 구현
    var isInvited: Bool  //observe 등록해서 데이터 관찰 / 초대장 구현에 필요
}

struct Record {
    var win: Int
    var lose: Int
}

enum RPS: Int {
    case r
    case p
    case s
}
