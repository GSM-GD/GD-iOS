//
//  PostListVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/31.
//

import UIKit
import Kingfisher

final class PostListVC: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var posts: [Post] = []{
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        Task {
            do{
                let posts = try await NetworkManager.shared.requestAllPost()
                print(posts)
                self.posts = posts
            }catch{
                self.showAlert(title: "GD", message: "게시물 불러오기에 실패했습니다", completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}
extension PostListVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dkanxmscell", for: indexPath) as! PostListTableViewCell
        let model = posts[indexPath.row]
        cell.nameLabel.text = model.writer
        cell.titleLabel.text = model.title
        cell.postImageView.kf.setImage(with: URL(string: "http://10.120.74.91:8000/post\(model.image)") ?? .none)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "postDetailVC") as! DetailPostVC
        let model = posts[indexPath.row]
        vc.model = model
        self.navigationController?.pushViewController(vc, animated: true)
    }
}









final class PostListTableViewCell: UICollectionViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
}
