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
import Firebase

final class MainViewController: UIViewController {
    
// MARK: - Properties
//    private let me: User
    private var users = [User]()
    private var userTableView = UITableView()
    private let logoutButton = UIButton()
    private let reusableTableViewCellIdentifier = "UserTableViewCell"
    private let myInformationView = MyInformationView()
    private var refreshControl: UIRefreshControl!
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            
            // user table에서 내정보가 같이 나오는 것을 없애기 위해 구현./ 애초에 User 데이터를 가져오지말고 Users에서 user만 뽑는게 더 효율적일것 같음.
            if let userIndex = users.firstIndex(where: { $0.name == user.name }) {
                self.users.remove(at: userIndex)
            }
            self.userTableView.reloadData()
            
            // 사용자가 초대를 받았는지 알려주기위한 observer를 등록
            USERS_REF.child(user.id).child("isInvited").observe(.value) { snapshot in
                guard let isInvited = snapshot.value as? Bool else { return }
                self.isInvited = isInvited
            }
            // 초대장을 보낸 상대방이 초대를 수락했는지 알려주기위한 observer를 등록
            USERS_REF.child(user.id).child("opponent").child("acceptInvitation").observe(.value) { snapshot in
                guard let acceptInvitation = snapshot.value as? Bool else { return }
                self.opponentAcceptInvitaion = acceptInvitation
            }
        }
    }
    
    //초대 받았을때 사용되는 flag
    
    var isInvited: Bool? = false {
        didSet {
            guard let guest = user else { return }
            guard isInvited == true else { return }
            
            self.fetchGamerData(guest) { (host) in
                
                self.showMessage(title: "초대장", message: "\(host.name) 님이 게임에 초대했습니다. 입장하시겠습니까?", firstAction: "수락") { alertAction in
                    if alertAction.title == "수락" {
                        self.dismiss(animated: true, completion: nil)
                        
                        UserService.uploadGamerData(guest, host)
                        
                        let storyboard = UIStoryboard(name: "GameViewController", bundle: nil)
                        guard let inGameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
                        inGameVC.opponentInfo = host
                        inGameVC.myInfo = GamerInfo(name: guest.name, id: guest.id, choice: nil, wantsGameStart: false)
                        
                        let nav = UINavigationController(rootViewController: inGameVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    } else {
                        USERS_REF.child(guest.id).child("isInvited").setValue(false)
                        USERS_REF.child(guest.id).child("opponent").removeValue()
                        USERS_REF.child(host.id).child("opponent").removeValue()
                    }
                }
            }
        }
    }
    
    //상대방이 초대를 수락했을때 사용되는 flag
    var opponentAcceptInvitaion: Bool? = false {
        didSet {
            guard let host = user else { return }
            guard opponentAcceptInvitaion == true else { return }
            
            fetchGamerData(host) { opponentInfo in
                self.dismiss(animated: true, completion: nil)

                let storyboard = UIStoryboard(name: "GameViewController", bundle: nil)
                guard let inGameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
                inGameVC.opponentInfo = opponentInfo
                inGameVC.myInfo = GamerInfo(name: host.name, id: host.id, choice: nil, wantsGameStart: false)
                
                let nav = UINavigationController(rootViewController: inGameVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
// MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        checkIfUserIsLoggedIn() { id in
            myID = id
            self.fetchUserDataAndLoadProfileImage(id)
            self.fetchUsersData()
            USERS_REF.child(id).child("isLogin").setValue(true)
        }
        setupRefreshControl()
    }

// MARK: - Actions
    
    private func checkIfUserIsLoggedIn(completion: @escaping(String) -> Void) {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { [self] (tokenInfo, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //로그인 필요
                        //로그인 화면을 보여주도록
                        backToLogin()
                    }
                    else {
                        //SDK에러가 아닌 다른 에러인 경우
                        print("login error: \(error.localizedDescription)")
                        return
                    }
                }
                else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    guard let id = tokenInfo?.id else { return }
                    let userIdToString = String(id)
                    myID = userIdToString
                    completion(userIdToString)
                }
            }
        } else if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            guard let id = Auth.auth().currentUser?.uid else { return }
            completion(id)
        } else {
           backToLogin()
        }
    }
    
    private func backToLogin() {
        DispatchQueue.main.async {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: false, completion: nil)
        }
    }
    
    @objc func logoutButtonDidTapped() {
        if AuthApi.hasToken() {
            UserApi.shared.logout { [self] (error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("kakao logout() success.")
                    UserService.logout(user)
                    backToLogin()
                }
            }
        } else {
            GIDSignIn.sharedInstance.signOut()
            print("google logout() success.")
            UserService.logout(user)
            backToLogin()
        }
    }
    
    private func fetchUserDataAndLoadProfileImage(_ id: String) {
        UserService.fetchUser(id) { [self] user in
            self.user = user
            
            // 이부분 모듈화 해고싶음. 내부 구현 굳이 안보여줘도 이해하는데 충분할 듯
            myInformationView.myName.text = user.name
            
            let record = user.record.win + user.record.lose
            myInformationView.myGameRecord.text = "\(record)전 \(user.record.win)승 \(0)무 \(user.record.lose)패"
            
            guard let url = URL(string: user.profileThumbnailImageUrl) else { fatalError() }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("download Image dataTaskError: \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    guard let data = data else {
                        
                        return
                    }
                    
                    let image = UIImage(data: data)
                    
                    myInformationView.myProfiileImage.image = image
                }
            }.resume()
            self.setupUI()
        }
    }
    
    private func fetchUsersData() {
        UserService.fetchUsers { users in
            self.users = users
        }
    }
    
    private func fetchGamerData(_ user: User, completion: @escaping (GamerInfo) -> Void) {
        UserService.fetchGamerData(user, completion)
    }
    
// MARK: - Configure
    
    private func setupUI() {
        view.addSubview(myInformationView)
        setupMyInformationView()
        
        view.addSubview(userTableView)
        setupUserTableView()

        view.addSubview(logoutButton)
        setupLogoutButton()
    }
    
    private func setupMyInformationView() {

        myInformationView.anchor(top: view.topAnchor, paddingTop: 75)
        myInformationView.centerX(inView: view)
        myInformationView.myProfiileImage.clipsToBounds = true
        myInformationView.myProfiileImage.layer.cornerRadius = 10
    }
    
    private func setupLogoutButton() {
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        logoutButton.setTitleColor(.black, for: .normal)
        logoutButton.titleLabel?.textAlignment = .center
        logoutButton.layer.cornerRadius = 3
        logoutButton.addTarget(self, action: #selector(logoutButtonDidTapped), for: .touchUpInside)

        logoutButton.anchor(top: myInformationView.topAnchor,
                            right: myInformationView.rightAnchor,
                            paddingTop: 3,
                            paddingRight: 7)
    }
    
    private func setupUserTableView() {
        userTableView.dataSource = self
        userTableView.delegate = self
        userTableView.rowHeight = 80
        userTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserTableViewCell")
        userTableView.layer.cornerRadius = 10
        userTableView.backgroundColor = UIColor(red: 153/255, green: 255/255, blue: 205/255, alpha: 1)
        userTableView.layer.borderWidth = 0.2
        
        userTableView.anchor(top: myInformationView.bottomAnchor,
                             left: myInformationView.leftAnchor,
                             bottom: view.bottomAnchor,
                             right: myInformationView.rightAnchor,
                             paddingTop: 50,
                             paddingBottom: 75)
    }
    
    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {
        guard let user = user else { return }
        USERS_REF.child(user.id).child("isInvited").setValue(false)
        USERS_REF.child(user.id).child("opponent").removeValue()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        userTableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc private func onRefresh() {
        
        UserService.fetchUsers(butFor: myID) { users in
            self.users = users
        }
        print(users)
        self.userTableView.reloadData()
        refresh()
    }
    
    private func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    private func refresh() {
        run(after: 1) {
            self.refreshControl.endRefreshing()
        }
    }
}


// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        cell.user = users[indexPath.row]
        
        DispatchQueue.global().async {
            guard let url = URL(string: self.users[indexPath.row].profileThumbnailImageUrl) else { fatalError() }
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let error = error {
                            print("download Image dataTaskError: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.async {
                            guard let data = data else {
                                return
                            }
                            let image = UIImage(data: data)
                            cell.profileImageView.image = image
                        }
                    }.resume()
        }
        
        cell.backgroundColor = UIColor(red: 153/255, green: 255/255, blue: 205/255, alpha: 1)
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let host = user else { return }
        let guest = users[indexPath.row]
        
        UserService.uploadGamerData(guest, host)
        
        USERS_REF.child(guest.id).updateChildValues(["isInvited": true])
        
        self.showMessage(title: "대결 신청", message: "\(guest.name)님의 수락을 기다리는 중") { alertAction in
            if alertAction.style == .cancel {
                USERS_REF.child(guest.id).child("opponent").removeValue()
                USERS_REF.child(host.id).child("opponent").removeValue()
                USERS_REF.child(host.id).child("isInvited").setValue(false)
                USERS_REF.child(guest.id).child("isInvited").setValue(false)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if users[indexPath.row].isLogin == false {
            return nil
        } else {
            return indexPath
        }
    }
}

