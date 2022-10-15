//
//  ItemVC.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/30.
//

import UIKit

protocol itemVCDelegate: AnyObject {
    func itemDidSelected(name: String)
}

final class ItemVC: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: itemVCDelegate?
    
    private let dataSource: [Item] = [
        Item(imageName: "heart", itemName: "Heart"),
        Item(imageName: "code", itemName: "Code"),
        Item(imageName: "box", itemName: "Box"),
        Item(imageName: "cursor", itemName: "Cursor"),
        Item(imageName: "good", itemName: "Good"),
        Item(imageName: "snowman", itemName: "Snowman"),
        Item(imageName: "ok", itemName: "Ok"),
        Item(imageName: "milk", itemName: "Milk"),
        Item(imageName: "pen", itemName: "Pen"),
        Item(imageName: "glass", itemName: "glass")
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
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.itemDidSelected(name: dataSource[indexPath.row].imageName)
    }
    
}
