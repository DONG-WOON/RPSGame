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
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var scissorButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var opponentChoiceImageView: UIImageView!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    var opponentInfo: GamerInfo?
    var myInfo: GamerInfo?
    
// MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayers()

        opponentName.text = opponentInfo?.name
        myName.text = myInfo?.name
    }
// MARK: - Actions
    
    func setupPlayers() {
        guard let opponentId = opponentInfo?.id, let myId = myInfo?.id else { return }
    }
    
    @IBAction func goChat(_ sender: Any) {
        let chatVC = ChatViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func startGame(_ sender: Any) {
        showMessage(title: "게임 시작", message: "게임을 시작할까유?", firstAction: "네") { [self] alertAction in
            if alertAction.style == .default {
                gamePlay()
            }
        }
    }
    
    @IBAction func rockPaperScissors(_ sender: Any) {
        guard let mychoice = sender as? RPS else { return }
        switch mychoice {
            case .rock:
                print("rock")
                rockButton.isEnabled.toggle()
            case .paper:
                print("paper")
                paperButton.isEnabled.toggle()
            case .scissor:
                print("scissor")
                scissorButton.isEnabled.toggle()
        }
        self.myInfo?.choice = mychoice
    }
    
    private func gamePlay() {
        rockButton.isEnabled.toggle()
        paperButton.isEnabled.toggle()
        scissorButton.isEnabled.toggle()
    }
    
// MARK: Helpers
   
    private func playSound() {
        
    }
    
    private func showStandByUIView() {
        
    }
    
    private func compareCards(myChoice: RPS, OpponentChoice: RPS) {
        
    }
    
    private func showResult() {
        print("승자는 OO 입니다")
        askGameAgain()
    }
    
    private func askGameAgain() {

    }
}
