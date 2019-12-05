//
//  ViewController.swift
//  SeeFood
//
//  Created by Keishin CHOU on 2019/12/05.
//  Copyright © 2019 Keishin CHOU. All rights reserved.
//

import CoreML
import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView: UIImageView!
    var picker = UIImagePickerController()
    
    override func loadView() {
        view = UIView()
//        view.backgroundColor = .gray
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFit
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhoto))
        
        edgesForExtendedLayout = []
    }
    
    @objc func addPhoto() {

        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didSelectPhoto))
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func didSelectPhoto() {
//        guard let selectedPhoto = imageView.image else { return }
        guard let ciimage = CIImage(image: imageView.image!) else { return }
        detect(using: ciimage)
    }
    
    func detect(using image: CIImage) {
        guard let mlModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError()
        }
        
        let request = VNCoreMLRequest(model: mlModel) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("retriever") {
                    let alert: UIAlertController = UIAlertController(title: "レトリバーだぜ！", message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                } else if firstResult.identifier.contains("cat"){
                    let alert: UIAlertController = UIAlertController(title: "ねこじゃねえかよ！", message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert: UIAlertController = UIAlertController(title: "レトリバーじゃない！", message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)                }
            }
            
            print(results)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }


}

