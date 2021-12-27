//
//  ItemCell.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/27.
//

import UIKit

final class ItemCell: UICollectionViewCell{
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
