//
//  ViewController.swift
//  Gestival
//
//  Created by 최형우 on 2021/12/16.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController, ARSCNViewDelegate {
    // MARK: - Properties
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var screenshotButton: UIButton!
    
    @IBOutlet weak var planeDetectedLbl: UILabel!
    private var selectedItem: String?
    
    private var selectedNode: SCNNode?
    private var panStartZ: CGFloat = .zero
    private var panLast: SCNVector3 = .init()
    
    private let itemList: [String] = ["code","heart"]
    
    // MARK: - Helpers
    func registerGesture(){
        let tapG = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        let pinG = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        let rotateG = UILongPressGestureRecognizer(target: self, action: #selector(rotateAction(_:)))
        rotateG.minimumPressDuration = 0.1
        let deleteG = UITapGestureRecognizer(target: self, action: #selector(deleteAction(_:)))
        deleteG.numberOfTapsRequired = 2
        let panG = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        [tapG, pinG, rotateG, deleteG, panG].forEach{ sceneView.addGestureRecognizer($0) }
    }
    
    func addItem(_ res: SCNHitTestResult) {
        if let selectedItem = selectedItem {
             
            let scene = SCNScene(named: "art.scnassets/\(selectedItem).scn")
            let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
            
            let transform = res.worldCoordinates
            
            node.position = SCNVector3(x: transform.x, y: transform.y, z: transform.z)
//            node.scale = SCNVector3(1, 1, 1)
//            node.boundingBox = (SCNVector3(1, 1, 1), SCNVector3(1, 1, 1))
            self.sceneView.scene.rootNode.addChildNode(node)
            
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        collectionView.delegate = self
        collectionView.dataSource = self
        registerGesture()
        self.sceneView.autoenablesDefaultLighting = true
        screenshotButton.layer.cornerRadius = screenshotButton.frame.width / 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
    
    // MARK: - Selector
    @objc func tapAction(_ sender: UITapGestureRecognizer){
        print("ASDAF")
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        let hit = sceneView.hitTest(location, options: [:])
        if !hit.isEmpty {
            self.addItem(hit.first!)
        }
    }
    
    
    @objc func pinchAction(_ sender: UIPinchGestureRecognizer){
        print("pinch")
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        let hit = sceneView.hitTest(location, options: [:])
        if !hit.isEmpty{
            let res = hit.first!
            let node = res.node
            let action = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(action)
            sender.scale = 1.0
        }
    }
    @objc func rotateAction(_ sender: UILongPressGestureRecognizer){
        print("LOTATE")
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        let hit = sceneView.hitTest(location, options: [:])
        if !hit.isEmpty{
            let res = hit.first!
            if sender.state == .began{
                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degressToRadians), z: 0, duration: 0.8)
                let forever = SCNAction.repeatForever(rotation)
                res.node.runAction(forever)
            } else if sender.state == .ended{
                res.node.removeAllActions()
            }
        }
    }
    
    @objc func deleteAction(_ sender: UITapGestureRecognizer){
        print("DELETE")
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        guard let hit = sceneView.hitTest(location, options: nil).first else { return }
        hit.node.removeFromParentNode()
    }
    
    @objc func panAction(_ sender: UIPanGestureRecognizer){
        print("PAN")
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        switch sender.state{
        case .began:
            guard let hit = scene.hitTest(location, options: nil).first else { return }
            panStartZ = CGFloat(scene.projectPoint(panLast).z)
            panLast = hit.worldCoordinates
        case .changed:
            guard let hit = scene.hitTest(location, options: nil).first else { return }
            let worldPosition = scene.unprojectPoint(SCNVector3(location.x, location.y, panStartZ))
            let movement = SCNVector3(
                worldPosition.x - panLast.x,
                worldPosition.y - panLast.y,
                worldPosition.z - panLast.z
            )
            hit.node.localTranslate(by: movement)
            self.panLast = movement
        default:
            return
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.planeDetectedLbl.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetectedLbl.isHidden = true
            }
        }
    }
    // MARK: - IBAction
    @IBAction func screenshotButtonDidTap(_ sender: UIButton) {
        
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ItemCell else { return .init() }
        cell.imageView.image = UIImage(named: itemList[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemList[indexPath.row]
        cell?.backgroundColor = .orange
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .clear
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout{
    
}
