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
    
    private var me: User?
    
    private var users = [User]()
    // refresh할때 users의 변화에 따라 값이 변하지않음 ( 로그인 유저가 로그아웃 했을경우 )
    // ui작업을 동기적으로 하지않고 비동기로 실시함.
    // fetchUsersData안에서 실행할경우 사용자의 데이터를 모두 가져온 후 ui 작업이 실행되므로 전체적으로 느리다.
    // 지금처럼 할 경우 ui먼저 main쓰레드에서 실시하고 users데이터를 모두가져온후 리로드 하여 값이 변경된 화면으로 재구성된다.
    
    private var usersButForMe = [User]()
    
    private var userTableView = UITableView()
    private let tableViewBackgroundView = UIView()
    private let logoutButton = UIButton()
    private let reusableTableViewCellIdentifier = "UserTableViewCell"
    private let myInformationView = MyInformationView()
    private var refreshControl: UIRefreshControl!
    
    // 초대 받았을때 사용되는 flag
    var isInvited: Bool = false {
        didSet {
            guard let me = me else { return }
            if isInvited {
                self.fetchOpponentData(of: me) { (opponent) in
                    
                    self.showMessage(title: "초대장", message: "\(opponent.name) 님이 게임에 초대했습니다. 입장하시겠습니까?", firstAction: .accept, secondAction: .reject, firstActionCompletion: { _ in
                        
                        // 나의 게임상태를 true로 바꿈.
                        USERS_REF.child(me.id).child("isInGame").setValue(true)
                        
                        // 내가 초대장 받았다고 상대방에게 알려줌.
                        USERS_REF.child(opponent.id).child("opponent").child("acceptInvitation").setValue(true)
                        
                        // 초대에 수락했으므로 각 사용자를 Gamer로 만들어 연결시켜줌.
                        UserService.connectGamer(guest: me, host: opponent)
                        
                        self.goToGameVC(opponent, me)
                    }, secondActionCompletion: { _ in
                        
                        // 초대 거절
                        me.rejectInvitation()
                        
                        // 내가 초대장 거절했다고 상대방에게 알려줌.
                        me.sendRejectMessage(to: opponent)
                        
                        // 초대를 거절했으므로 사용자의 연결을 끊어줌.
                        UserService.disConnectGamer(guest: me, host: opponent)
                    })
                }
            } else {
                // 초대장을 받은상태에서 아무것도 누르지않고 있는데 상대방이 취소한경우 알려주기 위함.
                let messageVC = self.presentedViewController as? UIAlertController
                
                if messageVC?.title == "초대장" {
                    self.dismiss(animated: true)
                    showMessage(title: "게임요청 취소", message: "상대방이 게임요청을 취소헀습니다.", action: .ok)
                }
            }
        }
    }
    
    //상대방이 초대를 수락 /거절 했을때 사용되는 flag
    var opponentAcceptInvitaion: Bool = false {
        didSet {
            guard let me = me else { return }
            if opponentAcceptInvitaion {
                
                // 상대방이 초대를 받았다면 상대방의 데이터를 가져와 게임으로 넘어감.
                fetchOpponentData(of: me) { opponent in
                    self.goToGameVC(opponent, me)
                }
            } else {
                
                // 상대방이 거절할경우 게임요청이 거절됬다고 알려주기 위함.
                let messageVC = self.presentedViewController as? UIAlertController
                if messageVC?.title == "대결 신청" {
                    self.dismiss(animated: true)
                    showMessage(title: "게임요청 거절", message: "상대방이 게임요청을 거절헀습니다.", action: .ok)
                    
                    // 초대장을 보낼경우 isInvited값을 바꿀수없어서 이 값을 true로 변경해서
                    // 다른 사용자가 초대를 못하게 만들기 떄문에 초대방이 거절될경우 이 값을 다시 false로 만들어주어야함.
                    USERS_REF.child(me.id).child("isInGame").setValue(false)
                }
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        checkIfUserIsLoggedIn() { id in
            USERS_REF.child(id).child("isLogin").setValue(true)
            self.fetchUsersData()
            self.addObserver(myID!)
        }
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 게임에서 돌아올 경우 업데이트된 사용자의 전적을 불러오기 위해 필요함.
        self.setUpMyInformationView()
    }
    
    // MARK: - Actions
    
    private func checkIfUserIsLoggedIn(completion: @escaping(String) -> Void) {
        //  카카오 로그인
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
            
            //  구글 로그인
        } else if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            guard let id = Auth.auth().currentUser?.uid else { return }
            myID = id
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
        
        USERS_REF.child(myID!).child("isLogin").setValue(false)
        
        kakaoLogOut()
        googleLogOut()
        removeObserver(myID!)
    }
    
    private func kakaoLogOut() {
        if AuthApi.hasToken() {
            UserApi.shared.logout { [self] (error) in
                if let error = error {
                    print("kakaoLogOut Error: \(error.localizedDescription)")
                }
                else {
                    print("kakao logout() success.")
                    backToLogin()
                }
            }
        }
    }
    
    private func googleLogOut() {
        
        GIDSignIn.sharedInstance.signOut()
        print("google logout() success.")
        backToLogin()
    }
    
    private func setUpMyInformationView() {
        
        guard let me = me, let url = URL(string: me.profileThumbnailImageUrl) else {
            return
        }
        
        let sum = me.record.win + me.record.lose
        getMyImages(url)
        myInformationView.myNameLabel.text = me.name
        myInformationView.myGameRecordLabel.text = "\(sum)전 \(me.record.win)승 \(me.record.lose)패"
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
    
    func fetchUsersData() {
        UserService.fetchUsers { users in
            self.users = users
            self.usersButForMe = users.filter{ $0.id != myID }
            self.me = users.first { $0.id == myID }
            self.setUpMyInformationView()
            self.userTableView.reloadData()
        }
    }
    
    private func fetchOpponentData(of user: User, completion: @escaping (User) -> Void) {
        UserService.fetchOpponentData(of: user, completion)
    }
    
    private func addObserver(_ id: String) {
        // 사용자가 초대를 받았는지 알려주기위한 observer를 등록
        USERS_REF.child(id).child("isInvited").observe(.value) { snapshot in
            guard let isInvited = snapshot.value as? Bool else { return }
            self.isInvited = isInvited
        }
        // 초대장을 보낸 상대방이 초대를 수락했는지 알려주기위한 observer를 등록
        USERS_REF.child(id).child("opponent").child("acceptInvitation").observe(.value) { snapshot in
            guard let acceptInvitation = snapshot.value as? Bool else { return }
            self.opponentAcceptInvitaion = acceptInvitation
        }
    }
    
    private func removeObserver(_ id: String) {
        // 사용자가 초대를 받았는지 알려주기위한 observer를 제거
        USERS_REF.child(id).child("isInvited").removeAllObservers()
        // 초대장을 보낸 상대방이 초대를 수락했는지 알려주기위한 observer를 제거
        USERS_REF.child(id).child("opponent").child("acceptInvitation").removeAllObservers()
    }
    
    private func goToGameVC(_ opponent: User, _ me: User) {
        
        self.dismiss(animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "GameViewController", bundle: nil)
        guard let inGameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
        let nav = UINavigationController(rootViewController: inGameVC)
        nav.modalPresentationStyle = .fullScreen
        
        inGameVC.opponent = Gamer(name: opponent.name, id: opponent.id, choice: nil)
        inGameVC.me = Gamer(name: me.name, id: me.id, choice: nil)
        
        self.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Configure
    
    private func setupUI() {
        
        view.addSubview(myInformationView)
        setupMyInformationViewConstraints()
        
        setupUserTableView()
        
        view.addSubview(logoutButton)
        setupLogoutButton()
    }
    
    private func setupMyInformationViewConstraints() {
        
        myInformationView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 75, paddingLeft: 15, paddingRight: 15)
        myInformationView.centerX(inView: view)
        myInformationView.myProfiileImageView.clipsToBounds = true
        myInformationView.myProfiileImageView.layer.cornerRadius = 10
    }
    
    private func setupLogoutButton() {
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        logoutButton.setTitleColor(UIColor(named: "Title"), for: .normal)
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        logoutButton.layer.cornerRadius = 7
        logoutButton.layer.borderColor = UIColor.white.cgColor
        logoutButton.backgroundColor = UIColor(named: "LightOrange")
        logoutButton.addTarget(self, action: #selector(logoutButtonDidTapped), for: .touchUpInside)
        
        logoutButton.anchor(top: myInformationView.topAnchor,
                            right: myInformationView.rightAnchor,
                            paddingTop: 10,
                            paddingRight: 10)
    }
    
    private func setupUserTableView() {
        
        view.addSubview(tableViewBackgroundView)
        
        tableViewBackgroundView.layer.cornerRadius = 10
        tableViewBackgroundView.backgroundColor = UIColor(named: "Background")
        tableViewBackgroundView.layer.borderColor = UIColor(named: "LightOrange")?.cgColor
        tableViewBackgroundView.layer.borderWidth = 2
        tableViewBackgroundView.layer.shadowColor = UIColor.black.cgColor
        tableViewBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        tableViewBackgroundView.layer.shadowOpacity = 0.7
        tableViewBackgroundView.layer.shadowRadius = 4.0
        
        tableViewBackgroundView.anchor(top: myInformationView.bottomAnchor,
                                       left: myInformationView.leftAnchor,
                                       bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                       right: myInformationView.rightAnchor,
                                       paddingTop: 50,
                                       paddingBottom: 75)
        
        
        tableViewBackgroundView.addSubview(userTableView)
        
        userTableView.dataSource = self
        userTableView.delegate = self
        userTableView.rowHeight = 80
        userTableView.separatorStyle = .none
        
        userTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserTableViewCell")
        
        userTableView.layer.cornerRadius = 10
        userTableView.backgroundColor = UIColor(named: "Background")
        
        userTableView.anchor(top: tableViewBackgroundView.topAnchor,
                             left: tableViewBackgroundView.leftAnchor,
                             bottom: tableViewBackgroundView.bottomAnchor,
                             right: tableViewBackgroundView.rightAnchor)
    }
}

// MARK: - Refresh TableView

extension MainViewController {
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        userTableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc private func onRefresh() {
        
        self.fetchUsersData()
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
        
        return usersButForMe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        
        cell.user = usersButForMe[indexPath.row]
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let me = me else { return }
        let opponent = usersButForMe[indexPath.row]
        
        USERS_REF.child(opponent.id).getData { error, snapshot in
            guard let opponentData = snapshot?.value as? [String: Any],
                  let opponentIsInGame = opponentData["isInGame"] as? Bool,
                  let opponentIsInvited = opponentData["isInvited"] as? Bool else { return }
            
            // 초대장을 보내려는 User가 이미 게임중이거나 초대장을 보낸상태일경우
            if opponentIsInGame || opponentIsInvited {
                self.showMessage(title: "초대 불가", message: "사용자가 이미 게임 진행중이거나 다른 사용자에게 초대받은 상태입니다.", action: .ok)
                return
            } else {

                me.sendInvitation(to: opponent)
                USERS_REF.child(me.id).child("isInGame").setValue(true)
                
                self.showMessage(title: "대결 신청", message: "\(opponent.name)님의 수락을 기다리는 중", action: .cancel) { _ in
                    // 초대요청을  바로 취소할경우
                    
                    opponent.rejectInvitation()
                    USERS_REF.child(me.id).child("isInGame").setValue(false)
                    
                    UserService.disConnectGamer(guest: opponent, host: me)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if usersButForMe[indexPath.row].isLogin == false {
            return nil
        } else {
            return indexPath
        }
    }
}

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete(id: String)
}

extension MainViewController: AuthenticationDelegate {
    
    func authenticationDidComplete(id: String) {
        // 메인 -> 로그인 -> 메인 플로우일경우 viewdidLoad가 실행되지않으므로 이 함수가 필요함.
        
        myID = id
        USERS_REF.child(id).child("isLogin").setValue(true)
        self.fetchUsersData()
        self.addObserver(myID!)
        
        self.dismiss(animated: true, completion: nil)
    }
}
