//
//  UIViewExt.swift
//  Gestival
//
//  Created by 최형우 on 2022/01/04.
//

import UIKit

extension UIView{
    func asImage() -> UIImage{
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: image!.cgImage!)
    }
}
