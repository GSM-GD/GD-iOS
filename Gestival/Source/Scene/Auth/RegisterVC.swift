//
//  RegisterVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/27.
//

import UIKit

final class RegisterVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.textColor = .black
        emailTextField.textColor = .black
        passwordTextField.textColor = .black
    }
    
    @IBAction func registerDidTap(_ sender: UIButton) {
        let user = registerRequestUser(name: nameTextField.text ?? "",
                                       email: emailTextField.text ?? "",
                                       password: passwordTextField.text ?? "")
        Task{
            do{
                _ = try await NetworkManager.shared.requestRegister(user)
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main") as? ViewController else { return }
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }catch{
                self.showAlert(title: "GD", message: "E-mail 또는 Nickname이 중복되었습니다.", completion: nil)
            }
        }
    }
}
