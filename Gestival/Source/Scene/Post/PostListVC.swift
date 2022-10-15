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
                self.posts = posts.reversed()
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
        cell.postImageView.kf.setImage(with: URL(string: model.url) ?? .none)
        return cell
    }
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            let index = indexPaths.first ?? .init(row: 0, section: 0)
            let cell = collectionView.cellForItem(at: index) as! PostListTableViewCell
            let edit = UIAction(title: "앨범에 저장", image: UIImage(systemName: "square.and.arrow.down.fill"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                
                UIImageWriteToSavedPhotosAlbum(cell.postImageView.image ?? .init(), self, #selector(self.successToSave), nil)
            }
            let delete = UIAction(title: "공유하기", image: UIImage(systemName: "square.and.arrow.up.fill"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                let vc = UIActivityViewController(activityItems: [cell.postImageView.image ?? .init()], applicationActivities: nil)
                vc.excludedActivityTypes = [.saveToCameraRoll]
                self.present(vc, animated: true, completion: nil)
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
        }
        return context
    }
    @objc func successToSave(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.showAlert(title: "GD", message: "이미지가 저장되었습니다") { _ in }
    }
}

final class PostListTableViewCell: UICollectionViewCell{
    @IBOutlet weak var postImageView: UIImageView!
    
}
