//
//  UserService.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/12.
//

import Foundation
import Firebase
import KakaoSDKUser
import KakaoSDKCommon
import GoogleSignIn

// MARK: - UserService
struct UserService {
    // @escaping이 없었는데 추가한 이유: 비동기 처리 후 클로저를 실행하기 위해? 이렇게 안하면 user정보를 가져오기전에 completion이 실행될것이라 생각했음.
    static func uploadKakaoUser(completaion: @escaping ((String) -> Void)) {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print("DEBUG: register Error\(error.localizedDescription)")
                return
            } else {
                guard let user = user,
                      let userId = user.id,
                      let userProfile = user.kakaoAccount?.profile,
                      let userName = userProfile.nickname,
                      let userProfileImageUrl = userProfile.thumbnailImageUrl else { fatalError() }
                USERS_REF.child(String(userId)).child("id").getData { _, snapshot in
                    if snapshot?.value as? String != nil {
                        completaion(String(userId))
                    } else {
                        USERS_REF.child(String(userId)).setValue(["id": String(userId),
                                                               "name": userName,
                                                               "profileImageUrl": userProfileImageUrl.absoluteString,
                                                               "record": ["win": 0, "lose": 0],
                                                               "isLogin": true,
                                                               "isInGame": false,
                                                               "isInvited": false])
                        completaion(String(userId))
                    }
                }
            }
        }
    }
    
    static func uploadGoogleUser(_ credential: AuthCredential, completaion: @escaping ((String) -> Void)) {
        Auth.auth().signIn(with: credential) { (authData, error) in
            
            guard let user = authData?.user,
                  let photoUrl = user.photoURL else { return }
            
            USERS_REF.child(user.uid).child("id").getData { error, snapshot in
                if let error = error {
                    print("uploadGoogleUser error: \(error.localizedDescription)")
                    return
                }
                // 사용자의 id가 존재한다면 이미 가입된 User로 모든 정보를 초기화하지않고 가져와서 그대로 실행시킨다.
                if snapshot?.value as? String != nil {
                    completaion(user.uid)
                } else {
                    USERS_REF.child(user.uid).setValue(["id": user.uid,
                                                        "name": user.displayName ?? "",
                                                        "profileImageUrl": photoUrl.absoluteString,
                                                        "record": ["win": 0, "lose": 0],
                                                        "isLogin": true,
                                                        "isInGame": false,
                                                        "isInvited": false])
                    completaion(user.uid)
                }
            }
        }
    }
    // fetchOpponentData(of:)에서 사용하기 위함.
    static func fetchUser(id: String, completion: @escaping (User) -> Void) {
        
        USERS_REF.child(id).getData { (error, snapshot) in
            if let error = error {
                print("fetch error: \(error.localizedDescription)")
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
            if let error = error {
                print("fetch error: \(error.localizedDescription)")
                return
            }
            guard let usersData = snapshot?.value as? [String: Any] else {
                fatalError("DEBUG: user data is nil")
            }
            let users = usersData.map { (_, userData) in
                User(data: userData as! [String : Any])
            }
            completion(users)
        }
    }
    
    static func fetchOpponentData(of user: User, _ completion: @escaping (User) -> Void) {
        USERS_REF.child(user.id).child("opponent").child("id").getData { (_, snapshot) in
            guard let opponentId = snapshot?.value as? String else { return }
            UserService.fetchUser(id: opponentId) { user in
                completion(user)
            }
        }
    }
    
    static func connectGamer(guest: User, host: User) {
        USERS_REF.child(guest.id).child("opponent").setValue(["name": host.name,
                                                                   "id": host.id,
                                                                   "choice": nil,
                                                                   "wantsGameStart": nil])
        USERS_REF.child(host.id).child("opponent").setValue(["name": guest.name,
                                                                   "id": guest.id,
                                                                   "choice": nil,
                                                                   "wantsGameStart": nil])
    }
    
    static func disConnectGamer(guest: User, host: User) {
        USERS_REF.child(guest.id).child("opponent").removeValue()
        USERS_REF.child(host.id).child("opponent").removeValue()
    }
}
