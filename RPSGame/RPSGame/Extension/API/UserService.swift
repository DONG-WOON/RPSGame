//
//  UserService.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/12.
//

import Foundation
import Firebase
import KakaoSDKUser
import GoogleSignIn

// MARK: - UserService

typealias AuthDataResultCallback = ((AuthDataResult?, Error?) -> Void)?

struct UserService {
    
    //카카오톡으로 로그인 후 에러 없다면 이 메소드 호출해서 사용자 정보를 database에 등록한다.
    static func register() {
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
                                                       "isLogin": false,
                                                       "isInGame": false,
                                                       "isInvited": false])
            }
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
    
    static func googleAuth(_ viewController: UIViewController, completion: AuthDataResultCallback) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
            guard error == nil else { return }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential) { (AuthData, error) in
                completion?(AuthData,error)
            }
        }
    }
}
