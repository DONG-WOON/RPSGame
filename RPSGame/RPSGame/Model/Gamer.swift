//
//  GameData.swift
//  RPSGame
//
//  Created by 서동운 on 2022/06/05.
//

import Foundation
import Firebase


struct Gamer {
    var name: String
    var id: String
    var choice: RPS?
    var wantsGameStart: Bool
    
    init(data: [String: Any]) {
        let choice = data["choice"] as? Int
        self.name = data["name"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.choice = RPS(rawValue: choice ?? 3)
        self.wantsGameStart = data["wantsGameStart"] as? Bool ?? false
    }
    
    init(name: String, id: String, choice: RPS?, wantsGameStart: Bool) {
        self.name = name
        self.id = id
        self.choice = choice
        self.wantsGameStart = wantsGameStart
    }
}

enum RPS: Int {
    case rock, paper, scissors
}

