//
//  User.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/05.
//

import Foundation
import Firebase

var myID: String?

struct User {
    let id: String
    let name: String
    let profileThumbnailImageUrl: String
    let record: Record
    
    var isLogin: Bool
    var isInGame: Bool //게임중일땐 초대 못하도록 구현
    var isInvited: Bool  //observe 등록해서 데이터 관찰 / 초대장 구현에 필요
    
    init(data: [String: Any]) {
        let record = data[Const.record] as? [String: Int] ?? [Const.win: 0, Const.lose: 0]
        self.id = data[Const.id] as? String ?? ""
        self.name = data[Const.name] as? String ?? ""
        self.profileThumbnailImageUrl = data["profileImageUrl"] as? String ?? ""
        self.record = Record(win: record[Const.win
                                        ]!, lose: record[Const.lose]!)
        self.isLogin = data[Const.isLogin] as? Bool ?? false
        self.isInGame = data[Const.isInGame] as? Bool ?? false
        self.isInvited = data[Const.isInvited] as? Bool ?? false
    }
    
    func sendInvitation(to user: User) {
        USERS_REF.child(user.id).child(Const.opponent).setValue([Const.name: name, Const.id: id])
        USERS_REF.child(user.id).child(Const.isInvited).setValue(true)
    }
    
    func rejectInvitation() {
        USERS_REF.child(id).child(Const.isInvited).setValue(false)
    }
    
    func sendRejectMessage(to opponent: User) {
        USERS_REF.child(opponent.id).child(Const.opponent).child("acceptInvitation").setValue(false)
    }
}

struct Record {
    var win: Int
    var lose: Int
}
