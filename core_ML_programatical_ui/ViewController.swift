//
//  ViewController.swift
//  core_ML_programatical_ui
//
//  Created by Rumesh Buddhike on 8/16/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    // Image picker controller
    let imagePicker = UIImagePickerController()
    
    // UIOutlets
    let chooseImageBtn : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemOrange
        btn.setTitle("Take Image", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    let imageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "scribble.variable")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        return imgView
    }()
    
    let resultLabel : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        chooseImageBtn.addTarget(self, action: #selector(chooseBtnPressed), for: .touchUpInside)
        
    }
    
    @objc func chooseBtnPressed(){
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func setupUI(){
        
        let upperView = UIView()
        let bottomView = UIView()
        
        upperView.translatesAutoresizingMaskIntoConstraints = false
        upperView.backgroundColor = .systemGray4
        
        view.addSubview(upperView)
        upperView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        upperView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        upperView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        upperView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75).isActive = true
        
        upperView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: upperView.topAnchor, constant: 20).isActive = true
        imageView.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 20).isActive = true
        imageView.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: -20).isActive = true
        imageView.heightAnchor.constraint(equalTo: upperView.heightAnchor, multiplier: 0.6).isActive = true
        
        upperView.addSubview(resultLabel)
        resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        resultLabel.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 20).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: -20).isActive = true
        resultLabel.heightAnchor.constraint(equalTo: upperView.heightAnchor, multiplier: 0.15).isActive = true
        
        bottomView.backgroundColor = .systemGroupedBackground
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomView)
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
        
        bottomView.addSubview(chooseImageBtn)
        chooseImageBtn.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        chooseImageBtn.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        chooseImageBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        chooseImageBtn.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.6).isActive = true
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        
        // Convert the image for CIImage
        if let ciImage = CIImage(image: image) {
            processImage(ciImage: ciImage)
        }else {
            print("CIImage convert error")
        }
        
        
    }
    
    // Process Image output
    func processImage(ciImage: CIImage){
        
        do{
            let model = try VNCoreMLModel(for: MobileNetV2().model)
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                self.processClassifications(for: request, error: error)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
                do {
                    try handler.perform([request])
                } catch {
                    
                    print("Failed to perform classification.\n\(error.localizedDescription)")
                }
            }
            
        }catch {
            print(error.localizedDescription)
        }
        
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to classify image.\n\(error!.localizedDescription)")
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            self.resultLabel.text = classifications.first?.identifier.uppercased()
        }
        
    }
    
    
}

