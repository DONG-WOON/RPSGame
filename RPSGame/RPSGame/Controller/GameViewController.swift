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
    var opponent: User?
    var myChoice: RPS?
    
// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
// MARK: - Actions
    
    @IBAction func goChat(_ sender: Any) {
        
    }
    
    @IBAction func startGame(_ sender: Any) {
        showMessage(title: "게임 시작", message: "게임을 시작할까유?", firstAction: "네") { [self] alertAction in
            switch alertAction.style {
                case .default:
                    print("네를 눌렀구만")
                    gamePlay()
                case .cancel:
                    print("아니오를 눌렀구만")
                case .destructive:
                    break
                @unknown default:
                    break
            }
        }
    }
    
    @IBAction func rockPaperScissors(_ sender: Any) {
        guard let mychoice = sender as? RPS else { return }
        switch mychoice {
            case .rock:
                print("rock")
            case .paper:
                print("paper")
            case .scissor:
                print("scissor")
        }
        self.myChoice = mychoice
    }
    
    private func gamePlay() {
        
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
