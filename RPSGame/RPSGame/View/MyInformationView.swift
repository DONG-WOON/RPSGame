//
//  MyInformationView.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/16.
//

import UIKit

class MyInformationView: UIView {
// MARK: - Properties
    @IBOutlet weak var myProfiileImageView: UIImageView!
    @IBOutlet weak var myNameLabel: UILabel!
    @IBOutlet weak var myGameRecordLabel: UILabel!
    
// MARK: - Actions
    private func loadNib() {
        let view = Bundle.main.loadNibNamed("MyInformationView",
                                            owner: self,
                                            options: nil)?.first as? MyInformationView

        guard let view = view else { return }
        
        view.backgroundColor = UIColor(named: "Background")
        view.layer.borderColor = UIColor(named: "LightOrange")?.cgColor
        view.layer.borderWidth = 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.7
        view.layer.shadowRadius = 4.0
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.frame = self.bounds
        addSubview(view)
        myProfiileImageView.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
    }
// MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
