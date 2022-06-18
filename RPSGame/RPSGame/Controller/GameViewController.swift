//
//  GameViewController.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/18.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var startButton: UIButton!
    var opponent: User? = nil
    var mycard: RPS?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func goChat(_ sender: Any) {
    }
    
    @IBAction func startGame(_ sender: Any) {
    }
    
    @IBAction func rockPaperScissors(_ sender: Any) {
    }
    
}
