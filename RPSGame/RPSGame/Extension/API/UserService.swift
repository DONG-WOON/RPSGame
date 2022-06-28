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
    
    static func uploadKakaoUser(completion: ((String) -> Void)?) {
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
            
                USERS_REF.child(String(userId)).setValue(["id": userId,
                                                       "name": userName,
                                                       "profileImageUrl": userProfileImageUrl.absoluteString,
                                                       "record": ["win": 0, "lose": 0],
                                                       "isLogin": true,
                                                       "isInGame": false,
                                                       "isInvited": false])
                completion?(String(userId))
            }
        }
    }
    
    static func uploadGoogleUser(_ credential: AuthCredential, completion: ((String) -> Void)?) {
        Auth.auth().signIn(with: credential) { (authData, error) in
            
            guard let user = authData?.user,
                  let photoUrl = user.photoURL else { fatalError() }
           
            USERS_REF.child(user.uid).setValue(["id": user.uid,
                                                     "name": user.displayName ?? "",
                                                     "profileImageUrl": photoUrl.absoluteString,
                                                     "record": ["win": 0, "lose": 0],
                                                     "isLogin": true,
                                                     "isInGame": false,
                                                     "isInvited": false])
            completion?(user.uid)
        }
    }
    
    static func fetchUser(_ id: String, completion: @escaping (User) -> Void) {
        DispatchQueue.global().async {
            USERS_REF.child(id).getData { (error, snapshot) in
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
    }
    
    static func fetchUsers(butFor mine: String? = nil, completion: @escaping ([User]) -> Void) {
        
        USERS_REF.getData { (error, snapshot) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let usersData = snapshot?.value as? [String: Any] else {
                fatalError("DEBUG: user data is nil")
            }
            let users = usersData.map { (_, userData) in
                User(data: userData as! [String : Any])
            }.filter { user in
                user.id != mine
            }
            completion(users)
        }
    }
    
    static func fetchGamerData(_ user: User, _ completion: @escaping (Gamer) -> Void) {
        USERS_REF.child(user.id).child("opponent").getData() { (_, snapshot) in
            guard let data = snapshot?.value as? [String: Any] else { fatalError() }
            let opponent = Gamer(data: data)
            completion(opponent)
        }
    }
    
    static func uploadGamerData(_ guest: User, _ host: User) {
        USERS_REF.child(guest.id).child("opponent").setValue(["name": host.name,
                                                                   "id": host.id,
                                                                   "choice": nil,
                                                                   "wantsGameStart": false])
    }
    
    static func uploadGamerData(_ guest: User, _ host: Gamer) {
        USERS_REF.child(host.id).child("opponent").setValue(["name": guest.name,
                                                                      "id": guest.id,
                                                                      "choice": nil,
                                                                      "wantsGameStart": false,
                                                                      "acceptInvitation": true])
    }
    static func logout(_ user: User?) {
        guard let id = user?.id else { return }
        USERS_REF.child(id).child("isLogin").setValue(false)
    }
}
