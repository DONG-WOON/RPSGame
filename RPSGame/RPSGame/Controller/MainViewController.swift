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
import AVFoundation

final class MainViewController: UIViewController {
    
// MARK: - Properties
//    private let me: User
    private var users = [User]()
    private var userTableView = UITableView()
    private let logoutButton = UIButton()
    private let reusableTableViewCellIdentifier = "UserTableViewCell"
    private let myInformationView = MyInformationView()
    private var refreshControl: UIRefreshControl!
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            addDatabaseObserver(user)
        }
    }
    
    //초대 받았을때 사용되는 flag
    
    var isInvited: Bool? = false {
        didSet {
            guard let guest = user else { return }
            guard isInvited == true else { return }
            
            self.fetchGamerData(of: guest) { (host) in
                
                self.showMessage(title: "초대장", message: "\(host.name) 님이 게임에 초대했습니다. 입장하시겠습니까?", firstAction: "수락") { alertAction in
                    if alertAction.title == "수락" {
                        UserService.uploadGamerData(guest, host)
                        self.goToGameVC(host, guest)
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
            fetchGamerData(of: host) { opponent in
                self.goToGameVC(opponent, host)
            }
        }
    }
    
// MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        checkIfUserIsLoggedIn() { id in
            myID = id
            self.fetchUsersData()
            USERS_REF.child(id).child("isLogin").setValue(true)
        }
        setupRefreshControl()
    }

// MARK: - Actions
    
    private func checkIfUserIsLoggedIn(completion: @escaping(String) -> Void) {
        
//        카카오 로그인
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
                    myID = String(id)
                    completion(String(id))
                }
            }
            
//            구글 로그인
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
            loginVC.delegate = self
            self.present(loginVC, animated: false, completion: nil)
        }
    }
    
    @objc func logoutButtonDidTapped() {
        kakaoLogOut()
        googleLogOut()
    }
    
    private func kakaoLogOut() {
        
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
        }
    }
    
    private func googleLogOut() {
        
        GIDSignIn.sharedInstance.signOut()
        print("google logout() success.")
        UserService.logout(user)
        backToLogin()
    }
    
    private func getMyInfo() -> User? {
        let me = users.first { $0.id == myID }
        
        guard let myInfo = me else { return nil }
        
        return myInfo
    }
    
    private func setUpMyInformationView() {
        
        guard let myInfo = getMyInfo(), let url = URL(string: myInfo.profileThumbnailImageUrl) else { fatalError() }
        let record = myInfo.record.win + myInfo.record.lose
        getMyImages(url)
        myInformationView.myNameLabel.text = myInfo.name
        myInformationView.myGameRecordLabel.text = "\(record)전 \(myInfo.record.win)승 \(0)무 \(myInfo.record.lose)패"
    }
    
    private func getMyImages(_ url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("download Image dataTaskError: \(error.localizedDescription)")
            }
            
            guard let data = data else {
                return
            }
            
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.myInformationView.myProfiileImageView.image = image
            }
        }.resume()
    }
    
    private func fetchUsersData() {
        UserService.fetchUsers { users in
            self.users = users
            self.setUpMyInformationView()
            
            DispatchQueue.main.async {
                self.setupUI()
            }
            users.forEach { user in
                print("😅처음 fetch할때 user들이름:", user.name)
            }
        }
    }
    
    private func fetchGamerData(of user: User, completion: @escaping (Gamer) -> Void) {
        UserService.fetchGamerData(user, completion)
    }
    
    private func addDatabaseObserver(_ user: User) {
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
    
    private func goToGameVC(_ gamer: Gamer, _ user: User) {
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "GameViewController", bundle: nil)
        guard let inGameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
        inGameVC.opponent = gamer
        inGameVC.me = Gamer(name: user.name, id: user.id, choice: nil, wantsGameStart: false)
        
        let nav = UINavigationController(rootViewController: inGameVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
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
        myInformationView.myProfiileImageView.clipsToBounds = true
        myInformationView.myProfiileImageView.layer.cornerRadius = 10
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
    
    
}


// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let me = 1
        return users.count - me
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        let usersButForMe = users.filter { $0.id != myID }
        
        cell.user = usersButForMe[indexPath.row]
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

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete(of id: String)
}

extension MainViewController: AuthenticationDelegate {
    
    func authenticationDidComplete(of id: String) {
        /// 델리게이트를 설정해서 특정부분에서 이 메소드가 항상 호출되므로 user의 정보를 fetch할 수 있다.
        self.fetchUsersData()
        self.dismiss(animated: true, completion: nil)
    }
}

extension MainViewController {
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        userTableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc private func onRefresh() {
        
        UserService.fetchUsers { users in
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
