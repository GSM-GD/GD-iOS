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
        nameTextField.textColor = .black
        emailTextField.textColor = .black
        passwordTextField.textColor = .black
        hideKeyboard()
    }
    
    @IBAction func registerDidTap(_ sender: UIButton) {
        let user = registerRequestUser(name: nameTextField.text ?? "",
                                       email: emailTextField.text ?? "",
                                       password: passwordTextField.text ?? "")
        Task{
            do{
                let res = try await NetworkManager.shared.requestRegister(user)
                UserDefaults.standard.set(res.name, forKey: "UserName")
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main") as? ViewController else { return }
                self.navigationController?.popViewController(animated: true)
            }catch{
                self.showAlert(title: "GD", message: "E-mail 또는 Nickname이 중복되었습니다.", completion: nil)
            }
        }
    }
}
