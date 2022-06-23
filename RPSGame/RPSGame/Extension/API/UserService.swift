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
    
    static func uploadKakaoUser() {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print("DEBUG: register Error\(error.localizedDescription)")
                return
            } else {
                guard let kakaoUser = user,
                      let userId = kakaoUser.id ,
                      let userProfile = kakaoUser.kakaoAccount?.profile,
                      let userName = userProfile.nickname,
                      let userProfileImageUrl = userProfile.thumbnailImageUrl else { return }
                
                let userIdToString = String(userId)
                USERS_REF.child("\(userIdToString)").setValue(["id": userIdToString,
                                                       "name": userName,
                                                       "profileImageUrl": userProfileImageUrl.absoluteString,
                                                       "record": ["win": 0, "lose": 0],
                                                       "isLogin": true,
                                                       "isInGame": false,
                                                       "isInvited": false])
            }
        }
    }
    
    static func uploadGoogleUser(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authData, error) in
            
            guard let user = authData?.user,
                  let photoUrl = user.photoURL else { return }
           
            USERS_REF.child("\(user.uid)").setValue(["id": user.uid,
                                                     "name": user.displayName ?? "",
                                                     "profileImageUrl": photoUrl.absoluteString,
                                                     "record": ["win": 0, "lose": 0],
                                                     "isLogin": true,
                                                     "isInGame": false,
                                                     "isInvited": false])
        }
    }
    
    static func fetchUser(_ id: String, completion: @escaping (User) -> Void) {
        DispatchQueue.global().async {
            USERS_REF.child("\(id)").getData { (error, snapshot) in
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
    
    static func fetchGamerData(_ user: User, _ completion: @escaping (GamerInfo) -> Void) {
        USERS_REF.child("\(user.id)").child("opponent").observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else { return }
            let opponentInfo = GamerInfo(data: data)
            completion(opponentInfo)
        }
    }
    
    static func uploadGamerData(_ guest: User, _ host: User) {
        USERS_REF.child("\(guest.id)").child("opponent").setValue(["name": host.name,
                                                                   "id": host.id,
                                                                   "choice": nil,
                                                                   "wantsGameStart": false])
    }
    
    static func uploadGamerData(_ guest: User, _ host: GamerInfo) {
        USERS_REF.child("\(host.id)").child("opponent").setValue(["name": guest.name,
                                                                      "id": guest.id,
                                                                      "choice": nil,
                                                                      "wantsGameStart": false,
                                                                      "acceptInvitation": true])
    }
    static func logout(_ user: User?) {
        guard let id = user?.id else { return }
        USERS_REF.child("\(id)").child("isLogin").setValue(false)
    }
}
