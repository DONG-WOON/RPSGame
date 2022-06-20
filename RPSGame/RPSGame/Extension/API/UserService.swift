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
                print(userProfileImageUrl.absoluteString)
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
