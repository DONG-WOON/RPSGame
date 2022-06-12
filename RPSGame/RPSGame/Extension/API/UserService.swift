//
//  UserService.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/12.
//

import Foundation
import Firebase

// MARK: - UserProtocol

protocol UserProtocol {
    var id: String { get }
    var name: String { get }
    var profileThumbnailImageURL: String { get }
    var record: Record { get }
    var isLogin: Bool { get }
    var isInGame: Bool { get }
    var isInvited: Bool { get }
}

// MARK: - Mock

struct DummyUser: UserProtocol {
    let id: String
    let name: String
    let profileThumbnailImageURL: String
    let record: Record
    var isLogin: Bool
    var isInGame: Bool
    var isInvited: Bool
}

// MARK: - UserService

struct UserService {
    static func Upload(user: UserProtocol) {
        USERS_REF.child(user.id).setValue(["id":user.id,
                                           "name": user.name,
                                           "profileImageURL": user.profileThumbnailImageURL,
                                           "record": ["win": user.record.win, "lose": user.record.lose],
                                           "isLogin": user.isLogin,
                                           "isInGame": user.isInGame,
                                           "isInvited": user.isInvited])
    }
    
    static func fetchUser(completion: @escaping (User) -> Void) {
        //구글이나 카카오의 로그인 아이디를 가져올수 있는 코드 구현
        // -> child의 id에 대입
        
        USERS_REF.child("DKA877JNWR").getData { (error, snapshot) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let userData = snapshot?.value as? [String: Any] else {
                fatalError("DEBUG: user data is nil")
            }
            let user = User(data: userData)
            completion(user)
        }
    }
    
    static func fetchUsers(completion: @escaping ([User]) -> Void) {
        
        USERS_REF.getData { (error, snapshot) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let userList = snapshot?.value as? [String: Any] else {
                fatalError("DEBUG: user data is nil")
            }
            let users = userList.map { (_,userData) in
                User(data: userData as! [String : Any])
            }
            completion(users)
        }
    }
}
