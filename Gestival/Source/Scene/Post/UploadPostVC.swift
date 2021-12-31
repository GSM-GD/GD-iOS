//
//  UploadPostVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/31.
//

import UIKit
final class UploadPostVC: UIViewController{
    // MARK: - Properties
    @IBOutlet weak var imageVIew: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    
    var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = false
        Task{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "게시", style: .plain, target: self, action: #selector(postButtonDidTap))
        }
        print("AS")
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.hideKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.imageVIew.image = image
        
    }
    
    
    
    // MARK: - Selector
    @objc private func postButtonDidTap(){
        
        let req = requestPost(title: titleTextField.text ?? "",
                              content: contentTextView.text ?? "",
                              imageData: image?.jpegData(compressionQuality: 0.95) ?? .init())
        print("TEST")
        Task{
            do{
                _ = try await NetworkManager.shared.requestPost(req)
                
            }catch{
                self.showAlert(title: "GD", message: "게시물 업로드를 실패했습니다", completion: nil)
            }
            
        }
        
    }
}
