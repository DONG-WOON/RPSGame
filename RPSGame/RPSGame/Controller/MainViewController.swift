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

class MainViewController: UIViewController {
// MARK: - Properties
    private var user: User?
    private var users = [User]()
    private var userTableView = UITableView()
    private let logoutButton = UIButton()
    
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
    
    private func checkIfUserIsLoggedIn() {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //로그인 필요
                        //로그인 화면을 보여주도록
                        DispatchQueue.main.async {
                            let loginVC = LoginViewController()
                            loginVC.modalPresentationStyle = .fullScreen
                            self.present(loginVC, animated: true, completion: nil)
                        }
                    }
                    else {
                        print("login error: \(error.localizedDescription)")
                        return
                    }
                }
                else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    self.fetchUserData()
                }
            }
        } else if !GIDSignIn.sharedInstance.hasPreviousSignIn() {
            DispatchQueue.main.async {
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
// MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        
        view.addSubview(userTableView)
        setupUserTableView()
        
        view.addSubview(logoutButton)
        setupLogoutButton()
        
        checkIfUserIsLoggedIn()
    }
    
// MARK: - Configure
    
    func setupTableView() {
        userTableView.rowHeight = 80
        userTableView.register(UserTableViewCell.self, forCellReuseIdentifier: reusableTableViewCellIdentifier)
        userTableView.dataSource = self
        userTableView.layer.cornerRadius = 10
        userTableView.layer.borderColor = CGColor(gray: 0.7, alpha: 1)
        userTableView.layer.borderWidth = 0.2
    }
    
    func setupLogoutButton() {
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.titleLabel?.textAlignment = .center
        logoutButton.layer.cornerRadius = 3
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = CGColor(gray: 0.7, alpha: 0.6)
        logoutButton.addTarget(self, action: #selector(logoutButtonDidTapped), for: .touchUpInside)
        
        logoutButton.anchor(top: view.layoutMarginsGuide.topAnchor,
                            right: view.rightAnchor,
                            paddingTop: 30,
                            paddingRight: 30)
    }
    
    func setupUserTableView() {
        userTableView.anchor(left: view.layoutMarginsGuide.leftAnchor,
                             bottom: view.layoutMarginsGuide.bottomAnchor,
                             right: view.layoutMarginsGuide.rightAnchor,
                             paddingLeft: 30,
                             paddingBottom: 30,
                             paddingRight: 30,
                             height: 400)
    }
}


// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableTableViewCellIdentifier, for: indexPath) as! UserTableViewCell
        
        return cell
    }
    
    
}
