//
//  ItemVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/30.
//

import UIKit

protocol itemVCDelegate: class{
    func itemDidSelected(name: String)
}

final class ItemVC: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: itemVCDelegate?
    
    private let dataSource: [Item] = [
        Item(imageName: "heart", itemName: "Heart"),
        Item(imageName: "code", itemName: "Code")
    ]
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension ItemVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCell
        let data = dataSource[indexPath.row]
        cell.imageView.image = UIImage(named: data.imageName)
        cell.itemLabel.text = data.itemName
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.itemDidSelected(name: dataSource[indexPath.row].imageName)
    }
    
}
