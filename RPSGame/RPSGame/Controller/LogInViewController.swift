//
//  ViewController.swift
//  RPSGame
//
//  Created by EHDOMB on 2022/06/05.
//

import UIKit
import Firebase


final class LoginViewController: UIViewController {

    private let backgroundView = UIImageView()
    private let mainLabel = UILabel()
    private let kakaoLoginButton = UIButton()
    private let loginButtonStack = UIStackView()
    
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
        kakaoLoginButton.alpha = 0

        kakaoLoginButton.translatesAutoresizingMaskIntoConstraints = false
        kakaoLoginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        kakaoLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupStackView() {
        view.addSubview(loginButtonStack)
        
        loginButtonStack.axis = .vertical
        loginButtonStack.spacing = 20.0
        loginButtonStack.alignment = .center
        loginButtonStack.distribution = .fillEqually
        
        loginButtonStack.translatesAutoresizingMaskIntoConstraints = false
        loginButtonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        loginButtonStack.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        
    }
    
    
    private func appear() {
        UIView.animate(withDuration: 3) {
            self.backgroundView.alpha = 1
            self.mainLabel.alpha = 1
            self.kakaoLoginButton.alpha = 1
            self.mainLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
        }
    }
    
    @objc func kakaoLogin() {
        print("dhdld")
    }
}

