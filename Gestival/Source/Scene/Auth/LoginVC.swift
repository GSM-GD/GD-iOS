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
    
    @IBOutlet weak var toRegisterButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.textColor = .black
        passwordTextField.textColor = .black
        // Do any additional setup after loading the view.
        toRegisterButton.setTitleColor(.black, for: .normal)
        hideKeyboard()
    }
    
    @IBAction func loginDIdTap(_ sender: UIButton) {
        let user = loginRequestUser(email: emailTextField.text ?? "",
                                    password: passwordTextField.text ?? "")
        Task{
            
            do{
                let res = try await NetworkManager.shared.requestLogin(user)
                print(res)
                UserDefaults.standard.set(res.name, forKey: "UserName")
                
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main") as? ViewController else { return }
                let viewCon = UINavigationController(rootViewController: vc)
                viewCon.modalPresentationStyle = .fullScreen
                present(viewCon, animated: true, completion: nil)
                
                
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
