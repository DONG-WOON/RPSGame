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
                      let userID = kakaoUser.id,
                      let userName = kakaoUser.kakaoAccount?.name,
                      let userProfileImageUrl = kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl else { return }
                
                USERS_REF.child("\(userID)").setValue(["id": userID,
                                                       "name": userName,
                                                       "profileImageUrl": userProfileImageUrl,
                                                       "record": ["win": 0, "lose": 0],
                                                       "isLogin": true,
                                                       "isInGame": false,
                                                       "isInvited": false])
            }
        }
    }
    
    static func uploadGoogleUser(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (authData, error) in
            
            guard let user = authData?.user else { return }
            
            USERS_REF.child("\(user.uid)").setValue(["id": user.uid,
                                                     "name": user.displayName ?? "",
                                                     "profileImageUrl": user.photoURL ?? "",
                                                     "record": ["win": 0, "lose": 0],
                                                     "isLogin": true,
                                                     "isInGame": false,
                                                     "isInvited": false])
        }
    }
    
    static func fetchUser(completion: @escaping (User) -> Void) {
        
        UserApi.shared.me { (user, error) in
            if let error = error {
                print("DEBUG: fetchUser Error\(error.localizedDescription)")
                return
            } else {
                guard let user = user, let userID = user.id else { return }
                
                USERS_REF.child("\(userID)").getData { (error, snapshot) in
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
