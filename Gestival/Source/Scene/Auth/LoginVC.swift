//
//  LoginVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/27.
//

import UIKit

final class LoginVC: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonDidTap(_ sender: UIButton){
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main") as? ViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}
