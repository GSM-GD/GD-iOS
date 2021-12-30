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
    
    
    @IBOutlet weak var screenshotButton: UIButton!
    @IBOutlet weak var itemSelectButton: UIButton!
    private var selectedItem: String? = "heart"
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var isDeleteModeLabel: UILabel!
    @IBOutlet weak var planeDetectedLbl: UILabel!
    private var selectedNode: SCNNode?
    private var panStartZ: CGFloat = .zero
    private var panLast: SCNVector3 = .init()
    
    private var isDeleteMode = false
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
            self.sceneView.scene.rootNode.addChildNode(node)
            
        }
    }
    
    // MARK: - Init
    deinit{
        NetworkManager.shared.requestLogout()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        registerGesture()
        self.sceneView.autoenablesDefaultLighting = true
        screenshotButton.layer.cornerRadius = screenshotButton.frame.width / 2
        
        screenshotButton.imageView?.contentMode = .scaleAspectFill
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
        if isDeleteMode { return }
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
        if !isDeleteMode { return }
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
            self.selectedNode = hit.node
        case .changed:
            guard let hit = scene.hitTest(location, options: nil).first else { return }
            
            guard let selectedNode = selectedNode else {
                return
            }

            self.selectedNode!.position = SCNVector3(hit.worldCoordinates.x,
                                                     self.selectedNode!.position.y,
                                                     hit.worldCoordinates.z)
        case .ended, .cancelled, .failed:
            guard let _ = selectedNode else { return }
            self.selectedNode = nil
        default:
            return
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.planeDetectedLbl.text = "Plane"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetectedLbl.text = ""
            }
        }
    }
    // MARK: - IBAction
    
    @IBAction func itemSelectButtonDidTap(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "itemSelectVC") as! ItemVC
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func deleteButtonDidTap(_ sender: UIButton) {
        self.isDeleteMode = !isDeleteMode
        isDeleteModeLabel.text = isDeleteMode ? "Delete Mode" : ""
        
    }
    
}

extension ViewController: itemVCDelegate{
    func itemDidSelected(name: String) {
        self.selectedItem = name
        print(selectedItem)
        itemSelectButton.setImage(UIImage(named: selectedItem ?? "")?.resizableImage(withCapInsets: .init(top: 0, left: 0, bottom: 0, right: 0)), for: .normal)
        itemSelectButton.imageView?.contentMode = .scaleAspectFit
        itemSelectButton.layer.cornerRadius = screenshotButton.frame.width / 2
        itemSelectButton.clipsToBounds = true
        self.dismiss(animated: true)
    }
}
