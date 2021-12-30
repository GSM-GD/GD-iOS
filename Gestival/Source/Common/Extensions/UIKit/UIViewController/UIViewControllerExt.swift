//
//  UIViewControllerExt.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/29.
//

import UIKit

extension UIViewController{
    func showAlert(title: String?, message: String?, completion: ((UIAlertAction) -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default, handler: completion))
        self.present(alert, animated: true)
    }
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
