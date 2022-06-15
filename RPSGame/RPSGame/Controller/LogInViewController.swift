//
//  ViewController.swift
//  RPSGame
//
//  Created by EHDOMB on 2022/06/05.
//

import UIKit
import Firebase
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser


final class LoginViewController: UIViewController {
    
    private let backgroundView = UIImageView()
    private let mainLabel = UILabel()
    private let kakaoLoginButton = UIButton()
    private let loginButtonStack = UIStackView()
    private let googleLoginButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        setupMainLabel()
        setupStackView()
        setupLoginButtons()
        
        appear()
    }
    
    private func setupBackgroundView() {
        view.backgroundColor = .white
        view.addSubview(backgroundView)
        
        backgroundView.frame = view.frame
        backgroundView.image = UIImage(named: "loginBackground")
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.alpha = 0
        
        view.sendSubviewToBack(backgroundView)
    }
    
    private func setupMainLabel() {
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLabel)
        
        let constraints = [
            mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            mainLabel.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            mainLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            mainLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        mainLabel.backgroundColor = .systemGray
        mainLabel.layer.masksToBounds = true
        mainLabel.numberOfLines = 2
        mainLabel.text = "죽음의\n 가위바위보"
        mainLabel.textColor = .systemRed
        mainLabel.alpha = 0
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont.boldSystemFont(ofSize: 50)
    }
    
    private func setupLoginButtons() {
        loginButtonStack.addArrangedSubview(kakaoLoginButton)
        
        kakaoLoginButton.setImage(UIImage(named: "kakaoLogIn"), for: .normal)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
        
        loginButtonStack.addArrangedSubview(googleLoginButton)
        
        googleLoginButton.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        googleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        googleLoginButton.style = .wide
    }
    
    private func setupStackView() {
        view.addSubview(loginButtonStack)
        
        loginButtonStack.axis = .vertical
        loginButtonStack.spacing = 20.0
        loginButtonStack.alignment = .center
        loginButtonStack.distribution = .fill
        loginButtonStack.alpha = 0
        
        loginButtonStack.translatesAutoresizingMaskIntoConstraints = false
        loginButtonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        loginButtonStack.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        
    }
    
    
    private func appear() {
        UIView.animate(withDuration: 2) {
            self.backgroundView.alpha = 1
            self.mainLabel.alpha = 1
            self.loginButtonStack.alpha = 1
            self.mainLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
        }
    }
    
    @objc func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { (user, error) in
            
            if let error = error {
                print("DEBUG Google Login Error\(error.localizedDescription)")
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            UserService.uploadGoogleUser(credential)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func kakaoLogin() {
        print("일단")
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    _ = oauthToken
                    UserService.uploadKakaoUser()
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

