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
    @IBOutlet weak var postListButton: UIButton!
    private var selectedItem: String? = "heart"
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var isDeleteModeLabel: UILabel!
    @IBOutlet weak var planeDetectedLbl: UILabel!
    
    private var selectedNode: SCNNode?
    
    private var centerVerticesCount: Int32 = 0
       private var polygonVertices: [SCNVector3] = []
       private var indices: [Int32] = []
    private var drawingNode: SCNNode?
       private var pointTouching: CGPoint = .zero
    private var isDrawing: Bool = false
    
    private var isOnWriting: Bool = false
    private var panStartZ: CGFloat = .zero
    private var panLast: SCNVector3 = .init()
    private lazy var drawG = UILongPressGestureRecognizer(target: self, action: #selector(drawAction(_:)))
    
    private var isDeleteMode = false
    // MARK: - Helpers
    func registerGesture(){
        let tapG = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        let pinG = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        let rotateG = UILongPressGestureRecognizer(target: self, action: #selector(rotateAction(_:)))
        rotateG.minimumPressDuration = 0.3
        let deleteG = UITapGestureRecognizer(target: self, action: #selector(deleteAction(_:)))
        deleteG.numberOfTapsRequired = 2
        let panG = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        
        [tapG, pinG, rotateG, deleteG, panG].forEach{ sceneView.addGestureRecognizer($0) }
    }
    
    func configureScreenshotButton(){
        screenshotButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        screenshotButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        screenshotButton.setTitle("", for: .normal)
        screenshotButton.backgroundColor = .lightGray
        screenshotButton.layer.cornerRadius = 40
        screenshotButton.clipsToBounds = true
        
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
        //        NetworkManager.shared.requestLogout()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        drawG.minimumPressDuration = 0.01
        self.screenshotButton.setBackgroundImage(.init(), for: .normal)
        configureScreenshotButton()
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints
        ]
        
        registerGesture()
        self.sceneView.autoenablesDefaultLighting = true
        screenshotButton.layer.cornerRadius = screenshotButton.frame.width / 2
        screenshotButton.clipsToBounds = true
        screenshotButton.imageView?.contentMode = .scaleAspectFit
        
        postListButton.imageView?.contentMode = .scaleAspectFit
        postListButton.contentMode = .scaleAspectFit
        
        
        deleteButton.setTitleColor(.red, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        itemSelectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemSelectButton.widthAnchor.constraint(equalToConstant: 80),
            itemSelectButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        deleteButton.setTitle("", for: .normal)
        itemSelectButton.contentMode = .scaleAspectFit
        itemSelectButton.imageView?.contentMode = .scaleAspectFit
        itemSelectButton.setTitle("", for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        self.deleteButton.isHidden = false
        
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
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
        if isOnWriting { return }
        print("ASDAF")
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        let hit = sceneView.hitTest(location, options: [:])
        if !hit.isEmpty {
            self.addItem(hit.first!)
        }
    }
    
    @objc func drawAction(_ sender: UILongPressGestureRecognizer){
        let location = sender.location(in: sceneView)
        if !isOnWriting || isDeleteMode { return }
        print("ASD")
        switch sender.state{
        case .began:
            pointTouching = location
            isDrawing = true
            begin()
        case .changed:
            pointTouching = location
        case .ended:
            reset()
            isDrawing = false
        default:
            return
        }
    }
    
    @objc func pinchAction(_ sender: UIPinchGestureRecognizer){
        if isOnWriting { return }
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
        if isOnWriting { return }
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
        if isOnWriting { return }
        print("PAN")
        let scene = sender.view as! ARSCNView
        let location = sender.location(in: scene)
        switch sender.state{
        case .began:
            guard let hit = scene.hitTest(location, options: nil).first else { return }
            self.selectedNode = hit.node
        case .changed:
            guard let hit = scene.hitTest(location, options: nil).first else { return }
            
            guard selectedNode != nil else {
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
        
    }
    // MARK: - IBAction
    
    @IBAction func itemSelectButtonDidTap(_ sender: UIButton) {
        let alert: UIAlertController
        if traitCollection.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: "GD", message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "GD", message: nil, preferredStyle: .actionSheet)
        }
        alert.addAction(.init(title: "오브젝트 선택", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            if self.isOnWriting {
                self.sceneView.removeGestureRecognizer(self.drawG)
            }
            self.isOnWriting = false
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "itemSelectVC") as! ItemVC
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        alert.addAction(.init(title: "직접 그리기", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.itemSelectButton.setImage(UIImage(systemName: "pencil.circle.fill")?.downSample(size: .init(width: 50, height: 50)).tintColor(.white), for: .normal)
            if !self.isOnWriting {
                self.sceneView.addGestureRecognizer(self.drawG)
            }
            self.isOnWriting = true
        }))
        alert.addAction(.init(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func deleteButtonDidTap(_ sender: UIButton) {
        self.isDeleteMode = !isDeleteMode
        drawG.minimumPressDuration = isDeleteMode ? 1 : 0.001
        isDeleteModeLabel.text = isDeleteMode ? "더블 클릭하여 삭제" : ""
        deleteButton.setImage(.init(systemName: "trash")?.tintColor(isDeleteMode ? .red : .white), for: .normal)
        isDeleteModeLabel.isHidden = !isDeleteMode
    }
    @IBAction func screenshotButtonDidTap(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "uploadPostVC") as! UploadPostVC
        
        let image = sceneView.snapshot()
        vc.image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func postListButtonDidTap(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "postListVC") as! PostListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController{
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if isDrawing{
            addPointAndCreateVertices()
        }
    }
}

extension ViewController: itemVCDelegate{
    func itemDidSelected(name: String) {
        self.selectedItem = name
        itemSelectButton.contentMode = .scaleAspectFit
        itemSelectButton.imageView?.contentMode = .scaleAspectFit
        itemSelectButton.setImage(UIImage(named: selectedItem ?? "")?.downSample(size: .init(width: 50, height: 50)), for: .normal)
        
        self.dismiss(animated: true)
    }
    func createBallLine() -> SCNNode {
        let ball = SCNSphere(radius: 0.005)
        ball.firstMaterial?.diffuse.contents = UIColor.black
        
        let node = SCNNode(geometry: ball)
        return node
    }
}

extension ViewController{
    private func begin(){
        drawingNode = SCNNode()
        sceneView.scene.rootNode.addChildNode(drawingNode!)
    }
    
    private func addPointAndCreateVertices() {
        guard let camera: SCNNode = sceneView.pointOfView else {
            return
        }
        
        // world coordinates
        let pointScreen: SCNVector3 = SCNVector3Make(Float(pointTouching.x), Float(pointTouching.y), 0.997)
        let pointWorld: SCNVector3 = sceneView.unprojectPoint(pointScreen)
        let pointCamera: SCNVector3 = camera.convertPosition(pointWorld, from: nil)
        
        // camera coordinates
        let x: Float = pointCamera.x
        let y: Float = pointCamera.y
        let z: Float = -0.2
        let lengthOfTriangle: Float = 0.01
        
        // triangle vertices
        
        // camera coordinates
        let vertice0InCamera: SCNVector3 = SCNVector3Make(
            x,
            y - (sqrt(3) * lengthOfTriangle / 3),
            z
        )
        let vertice1InCamera: SCNVector3 = SCNVector3Make(
            x - lengthOfTriangle / 2,
            y + (sqrt(3) * lengthOfTriangle / 6),
            z
        )
        let vertice2InCamera: SCNVector3 = SCNVector3Make(
            x + lengthOfTriangle / 2,
            y +  (sqrt(3) * lengthOfTriangle / 6),
            z
        )
        
        // world coordinates
        let vertice0: SCNVector3 = camera.convertPosition(vertice0InCamera, to: nil)
        let vertice1: SCNVector3 = camera.convertPosition(vertice1InCamera, to: nil)
        let vertice2: SCNVector3 = camera.convertPosition(vertice2InCamera, to: nil)
        polygonVertices += [vertice0, vertice1, vertice2]
        centerVerticesCount += 1
        
        guard centerVerticesCount > 1 else {
            return
        }
        let n: Int32 = centerVerticesCount - 2
        let m: Int32 = 3 * n
        let nextIndices: [Int32] = [
            m    , m + 1, m + 2, // first
            m    , m + 1, m + 3,
            m    , m + 2, m + 3,
            m + 1, m + 2, m + 4,
            m + 1, m + 3, m + 4,
            m + 1, m + 2, m + 5,
            m + 2, m + 3, m + 5,
            m + 4, m + 3, m + 5, // last
        ]
        indices += nextIndices
        
        updateGeometry()
    }
    
    private func reset() {
        centerVerticesCount = 0
        polygonVertices.removeAll()
        indices.removeAll()
        drawingNode = nil
    }
    
    private func updateGeometry(){
        let source = SCNGeometrySource(vertices: polygonVertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        drawingNode?.geometry = SCNGeometry(sources: [source], elements: [element])
        drawingNode?.geometry?.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        drawingNode?.geometry?.firstMaterial?.isDoubleSided = true
    }
}
