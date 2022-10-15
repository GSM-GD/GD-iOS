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
    @IBOutlet weak var saveButton: UIButton!
    
    var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = false
        Task{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "게시", style: .plain, target: self, action: #selector(postButtonDidTap))
        }
        print("AS")
        self.hideKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.imageVIew.image = image
    }
    
    // MARK: - Selector
    @objc private func postButtonDidTap(){
        
        let req = requestPost(imageData: image?.jpegData(compressionQuality: 0.95) ?? .init())
        Task{
            do{
                _ = try await NetworkManager.shared.requestPost(req)
                self.showAlert(title: "GD", message: "게시물 업로드를 성공했습니다.") { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                self.navigationController?.popViewController(animated: true)
            }catch{
                self.showAlert(title: "GD", message: "게시물 업로드를 실패했습니다", completion: nil)
            }
            
        }
    }
    
    @IBAction func saveButtonDidTap(_ sender: UIButton) {
        guard let image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(successToSave), nil)
    }
    
    @IBAction func shareButtonDidTap(_ sender: UIButton) {
        guard let image else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        vc.excludedActivityTypes = [.saveToCameraRoll]
        present(vc, animated: true, completion: nil)
    }
    
    @objc func successToSave() {
        self.showAlert(title: "GD", message: "이미지가 저장되었습니다") { _ in }
    }
}
