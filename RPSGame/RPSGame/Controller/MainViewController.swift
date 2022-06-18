//
//  MainViewController.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/15.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import GoogleSignIn
import FirebaseAuth

final class MainViewController: UIViewController {
// MARK: - Properties
    private var user: User?
    private var users = [User]()

    private var userTableView = UITableView()
    private let logoutButton = UIButton()
    private let myInformationView = MyInformationView()
    
// MARK: - Actions
    
    @objc func logoutButtonDidTapped() {
        if AuthApi.hasToken() {
            UserApi.shared.logout {(error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("kakao logout() success.")
                    let loginVC = LoginViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
        } else {
            GIDSignIn.sharedInstance.signOut()
            print("google logout() success.")
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    private func fetchUserData() {
        UserService.fetchUser { [weak self] user in
            self?.user = user
        }
    }
    
//    private func checkIfUserIsLoggedIn() {
//        if AuthApi.hasToken() {
//            UserApi.shared.accessTokenInfo { (_, error) in
//                if let error = error {
//                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
//                        //로그인 필요
//                        //로그인 화면을 보여주도록
//                        DispatchQueue.main.async {
//                            let loginVC = LoginViewController()
//                            loginVC.modalPresentationStyle = .fullScreen
//                            self.present(loginVC, animated: true, completion: nil)
//                        }
//                    }
//                    else {
//                        print("login error: \(error.localizedDescription)")
//                        return
//                    }
//                }
//                else {
//                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
//                    self.fetchUserData()
//                }
//            }
//        } else if !GIDSignIn.sharedInstance.hasPreviousSignIn() {
//            DispatchQueue.main.async {
//                let loginVC = LoginViewController()
//                loginVC.modalPresentationStyle = .fullScreen
//                self.present(loginVC, animated: true, completion: nil)
//            }
//        }
//    }
    
// MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
                
        

        view.addSubview(myInformationView)
        setupMyInformationView()
        
        setupTableView()
        view.addSubview(userTableView)
        setupUserTableView()

        view.addSubview(logoutButton)
        setupLogoutButton()

//        checkIfUserIsLoggedIn()
    }
    
// MARK: - Configure
    
    func setupMyInformationView() {

        myInformationView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 75, paddingLeft: 20)
        myInformationView.centerX(inView: view)
    }
    
    func setupLogoutButton() {
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.titleLabel?.textAlignment = .center
        logoutButton.layer.cornerRadius = 3
        logoutButton.addTarget(self, action: #selector(logoutButtonDidTapped), for: .touchUpInside)

        logoutButton.anchor(top: view.layoutMarginsGuide.topAnchor,
                            right: view.rightAnchor,
                            paddingTop: 30,
                            paddingRight: 30)
    }
    
    func setupTableView() {
        
        userTableView.rowHeight = 80
        userTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserTableViewCell")
        userTableView.dataSource = self
        userTableView.layer.cornerRadius = 10
        userTableView.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 109/255, alpha: 1)
        userTableView.layer.borderWidth = 0.2
    }

    func setupUserTableView() {
        
        userTableView.anchor(top: myInformationView.bottomAnchor,
                             left: view.leftAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor,
                             paddingTop: 50,
                             paddingLeft: 20,
                             paddingBottom: 75,
                             paddingRight: 20)
    }
    
}


// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        
        cell.backgroundColor = UIColor(red: 153/255, green: 255/255, blue: 205/255, alpha: 1)
        return cell
    }
}
