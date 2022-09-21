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
        let record = data["record"] as? [String: Int] ?? ["win": 0, "lose": 0]
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.profileThumbnailImageUrl = data["profileImageUrl"] as? String ?? ""
        self.record = Record(win: record["win"]!, lose: record["lose"]!)
        self.isLogin = data["isLogin"] as? Bool ?? false
        self.isInGame = data["isInGame"] as? Bool ?? false
        self.isInvited = data["isInvited"] as? Bool ?? false
    }
    
    func sendInvitation(to user: User) {
        USERS_REF.child(user.id).child("opponent").setValue(["name": name,"id": id])
        USERS_REF.child(user.id).child("isInvited").setValue(true)
    }
    
    func rejectInvitation() {
        USERS_REF.child(id).child("isInvited").setValue(false)
    }
    
    func sendRejectMessage(to opponent: User) {
        USERS_REF.child(opponent.id).child("opponent").child("acceptInvitation").setValue(false)
    }
}

struct Record {
    var win: Int
    var lose: Int
}
