//
//  LoginVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/27.
//

import UIKit

final class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginDIdTap(_ sender: UIButton) {
        let user = loginRequestUser(email: emailTextField.text ?? "",
                                    password: passwordTextField.text ?? "")
        Task{
            
            do{
                _ = try await NetworkManager.shared.requestLogin(user)
                
                
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main") as? ViewController else { return }
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
                
                
            }catch{
                DispatchQueue.main.async {
                    self.showAlert(title: "GD", message: "E-mail 또는 Password가 틀렸습니다.", completion: nil)
                }
                
            }
                   
        }
        
        
        
    }
    
    @IBAction func toRegisterDidTap(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "signupVC")
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
}
