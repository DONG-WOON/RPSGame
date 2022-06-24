//
//  GameViewController.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/18.
//

import UIKit
import KakaoSDKUser

final class GameViewController: UIViewController {
// MARK: - Properties
    
    @IBOutlet weak var gameReadyView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var scissorButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var opponentChoiceImageView: UIImageView!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    private lazy var timerView: UIView = {
        let v = UIView()
        return v
    }()
    
    var opponentInfo: GamerInfo?
    var myInfo: GamerInfo?
    var timer = Timer()
    var timeValue = 7
    
    var startFlag: (Bool,Bool)? = (false, false) {
        didSet {
            if let flag = startFlag, flag == (true, true) {
                self.dismiss(animated: true, completion: nil)
                print("가위바위보 게임 start")
                gamePlay()
            }
        }
    }
    
// MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayers()
    }
// MARK: - Actions
    
    private func gamePlay() {
        startButton.isEnabled.toggle()
        gameReadyView.isHidden = true
        
        guard let opponent = opponentInfo, let my = myInfo else { return }
        USERS_REF.child(opponent.id).child("opponent").child("choice").observe(.value) { snapshot in
            guard let mychoice = snapshot.value as? RPS else{ return }
            self.myInfo?.choice = mychoice
        }
        
        USERS_REF.child(my.id).child("opponent").child("choice").observe(.value) { snapshot in
            guard let opponentChoice = snapshot.value as? RPS else{ return }
            self.opponentInfo?.choice = opponentChoice
        }
        
        buttonisEnabled(true)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerDispatchQueue(timer:)), userInfo: nil, repeats: true)
    }

    @objc func timerDispatchQueue(timer: Timer) {
        timeValue -= 1
        //타이머 보여줄수 있도록 뷰 구현
//        timerView
        print(timeValue)
        
        if timeValue == 0 {
            self.timer.invalidate()
            buttonisEnabled(false)
            guard let opponent = opponentInfo, let my = myInfo else { return }
            
            let winner = compare(myChoice: my.choice, OpponentChoice: opponent.choice)
            showResult(winner: winner)
        }
    }
    // MARK: Configure UI
    
    func setupPlayers() {
        guard let opponent = opponentInfo, let my = myInfo else { return }
        opponentName.text = opponent.name
        myName.text = my.name
    
        USERS_REF.child(opponent.id).child("opponent").child("wantsGameStart").observe(.value) { snapshot in
            guard let iWantGameStart = snapshot.value as? Bool else{ return }
            print(iWantGameStart)
            self.startFlag?.0 = iWantGameStart
        }
        
        USERS_REF.child(my.id).child("opponent").child("wantsGameStart").observe(.value) { snapshot in
            guard let opponentWantsGameStart = snapshot.value as? Bool else{ return }
            print(#function,opponentWantsGameStart)
            self.startFlag?.1 = opponentWantsGameStart
        }
        
    }
    
    @IBAction func goChat(_ sender: Any) {
        
        guard let myInfo = myInfo else { return }
        guard let opponentInfo = opponentInfo else { return }

        let chatRoomID = opponentInfo.id > myInfo.id ? "\(opponentInfo.id)\(myInfo.id)" : "\(myInfo.id)\(opponentInfo.id)"
        CHAT_REF.child("\(chatRoomID)")
        
        let chatVC = ChatViewController()
        
        chatVC.myName = myInfo.name
        chatVC.chatRommID = chatRoomID
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func startGame(_ sender: Any) {
       
        guard let opponentId = opponentInfo?.id else { return }
        showMessage(title: "게임 시작", message: "게임을 시작할까유?", firstAction: "네") { alertAction in
            if alertAction.style == .default {
                USERS_REF.child(opponentId).child("opponent").updateChildValues(["wantsGameStart": true])
                self.showMessage(title: "대기중", message: "상대방을 기다려 주세요", completion: nil)
            } else {
                USERS_REF.child(opponentId).child("opponent").updateChildValues(["wantsGameStart": false])
            }
        }
    }
    
    @IBAction func rockPaperScissors(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        let mychoice = button.tag
        switch mychoice {
            case RPS.rock.rawValue:
                print("rock")
                rockButton.isEnabled = false
                paperButton.isEnabled = true
                scissorButton.isEnabled = true
            case RPS.paper.rawValue:
                print("paper")
                rockButton.isEnabled = true
                paperButton.isEnabled = false
                scissorButton.isEnabled = true
            case RPS.scissor.rawValue:
                print("scissor")
                rockButton.isEnabled = true
                paperButton.isEnabled = true
                scissorButton.isEnabled = false
            default:
                break
        }
        
        self.myInfo?.choice = RPS(rawValue: mychoice)
        guard let opponentId = opponentInfo?.id else { return }
        
        USERS_REF.child(opponentId).child("opponent").updateChildValues(["choice": mychoice])
    }
    
// MARK: Helpers
   
    private func playSound() {
        
    }
    
    private func showStandByUIView() {
        
    }
    
    private func compare(myChoice: RPS?, OpponentChoice: RPS?) -> String {
        if myChoice == nil && OpponentChoice == nil {
            return "무승부"
        } else if myChoice == nil {
            return opponentInfo!.name
        } else if OpponentChoice == nil {
            return myInfo!.name
        } else {
            //두개 비교
            return ""
        }
    }
    
    private func showResult(winner: String) {
        print("승자는 \(winner)입니다")
        
        guard let opponent = opponentInfo, let my = myInfo else { return }
        if winner == opponent.name {
            USERS_REF.child(opponent.id).child("record").child("win").getData { (_, snapshot) in
                guard let winCount = snapshot?.value as? Int else { return }
                USERS_REF.child(opponent.id).child("record").updateChildValues(["win":winCount])
            }
        } else if winner == my.name {
            USERS_REF.child(opponent.id).child("record").child("lose").getData { (_, snapshot) in
                guard let loseCount = snapshot?.value as? Int else { return }
                USERS_REF.child(opponent.id).child("record").updateChildValues(["lose":loseCount])
            }
        }
        
        USERS_REF.child(my.id).child("opponent").updateChildValues(["wantsGameStart": false])
        USERS_REF.child(opponent.id).child("opponent").updateChildValues(["wantsGameStart": false])
        
        gameReadyView.isHidden = false
        askGameAgain()
    }
    
    private func askGameAgain() {
        
    }
    private func exit() {
        //나가기 버튼 누르면
        // 나의 정보가 사라지고
        // 정보가 사라지면서 firebase 초기화 되고
        // observer가 상대방이 나갔는지 알려줌.
    }
}

// MARK: - Helpers

extension GameViewController {
    private func buttonisEnabled(_ bool: Bool) {
        
        rockButton.isEnabled = bool
        paperButton.isEnabled = bool
        scissorButton.isEnabled = bool
    }
}
