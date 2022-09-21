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

// MARK: - Properties
    private let backgroundView = UIImageView()
    private let mainLabel = UILabel()
    private let kakaoLoginButton = UIButton()
    private let loginButtonStack = UIStackView()
    private let googleLoginButton = GIDSignInButton()
    weak var delegate: AuthenticationDelegate?
    
//MARK: - Login
    @objc func signupGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { (user, error) in
            if let error = error {
                print("DEBUG: Google Login Error\(error.localizedDescription)")
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
            
            UserService.uploadGoogleUser(credential) { id in
                self.delegate?.authenticationDidComplete(id: id)
            }
        }
    }
    
    @objc func signupKakao() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("DEBUG: kakaoTalk Login error: \(error)")
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    _ = oauthToken
                    UserService.uploadKakaoUser { id in
                        self.delegate?.authenticationDidComplete(id: id)
                    }
                }
            }
        }
    }
    
// MARK: - Life Cycle
override func viewDidLoad() {
    super.viewDidLoad()
    
    setupBackgroundView()
    setupMainLabel()
    setupStackView()
    setupLoginButtons()
    appear()
}
    
// MARK: - Configure UI
    
    private func setupBackgroundView() {
        view.backgroundColor = .white
        view.addSubview(backgroundView)
        
        backgroundView.center(inView: view, constant: 15)
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
            mainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            mainLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        mainLabel.backgroundColor = UIColor(named: "LightOrange")
        mainLabel.layer.masksToBounds = true
        mainLabel.numberOfLines = 0
        mainLabel.layer.cornerRadius = 10
        mainLabel.text = "가위바위보 게임"
        mainLabel.textColor = UIColor(named: "Title")
        mainLabel.alpha = 0
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont.boldSystemFont(ofSize: 40)
        
        mainLabel.layer.borderColor = UIColor(named: "Background")?.cgColor
        mainLabel.layer.borderWidth = 2
        mainLabel.layer.shadowColor = UIColor.black.cgColor
        mainLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        mainLabel.layer.shadowOpacity = 0.7
        mainLabel.layer.shadowRadius = 4.0
    }
    
    private func setupLoginButtons() {
        
        loginButtonStack.addArrangedSubview(googleLoginButton)
        loginButtonStack.addArrangedSubview(kakaoLoginButton)
        
        
        googleLoginButton.addTarget(self, action: #selector(signupGoogle), for: .touchUpInside)
        googleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        googleLoginButton.style = .wide
        
        kakaoLoginButton.setImage(UIImage(named: "kakaoLogIn"), for: .normal)
        kakaoLoginButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        kakaoLoginButton.addTarget(self, action: #selector(signupKakao), for: .touchUpInside)
    }
    
    private func setupStackView() {
        view.addSubview(loginButtonStack)
        
        loginButtonStack.axis = .vertical
        loginButtonStack.spacing = 10.0
        loginButtonStack.alignment = .center
        loginButtonStack.distribution = .fill
        loginButtonStack.alpha = 0
        
        loginButtonStack.translatesAutoresizingMaskIntoConstraints = false
        loginButtonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        loginButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
    }
    
    private func appear() {
        UIView.animate(withDuration: 2) {
            self.backgroundView.alpha = 1
            self.mainLabel.alpha = 1
            self.loginButtonStack.alpha = 1
        }
    }
}
