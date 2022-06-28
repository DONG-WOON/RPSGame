//
//  MyInformationView.swift
//  RPSGame
//
//  Created by 신동훈 on 2022/06/16.
//

import UIKit

class MyInformationView: UIView {

    @IBOutlet weak var myProfiileImageView: UIImageView!
    @IBOutlet weak var myNameLabel: UILabel!
    @IBOutlet weak var myGameRecordLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewLoad()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func viewLoad() {
        let view = Bundle.main.loadNibNamed("MyInformationView",
                                            owner: self,
                                            options: nil)?.first as? MyInformationView

        guard let view = view else { return }
        
        view.backgroundColor = UIColor(red: 255/255, green: 211/255, blue: 110/255, alpha: 1)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.frame = self.bounds
        addSubview(view)
        myProfiileImageView.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
    }
}
