//
//  DetailPostVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/31.
//

import Kingfisher
import UIKit

final class DetailPostVC: UIViewController{
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var model: Post?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.postImageView.kf.setImage(with: URL(string: "http://10.120.74.91:8000/post\(model?.image ?? "")"))
        self.titleLabel.text = model?.title
        self.contentLabel.text = model?.content
    }
}
