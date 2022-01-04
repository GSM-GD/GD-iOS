//
//  DetailPostVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/31.
//

import Kingfisher
import UIKit
import ImageViewer_swift

final class DetailPostVC: UIViewController{
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    var model: Post?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shareButton.setTitle("", for: .normal)
        
        self.postImageView.kf.setImage(with: URL(string: "\(Config.url)/post\(model?.image ?? "")"))
        let image = [postImageView.image ?? .init()]
        postImageView.setupImageViewer(images: image)
        self.titleLabel.text = model?.title
        self.contentLabel.text = model?.content
    }
    @IBAction func shareButtonDidTap(_ sender: UIButton) {
        let vc = UIActivityViewController(activityItems: [postImageView.image], applicationActivities: nil)
        vc.excludedActivityTypes = [.saveToCameraRoll]
        present(vc, animated: true, completion: nil)
    }
}
