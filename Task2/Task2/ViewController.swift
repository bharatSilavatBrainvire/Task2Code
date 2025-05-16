//
//  ViewController.swift
//  Task2
//
//  Created by Bharat Shilavat on 16/05/25.
//

import UIKit
import CoreImage


class ViewController: UIViewController {
    
    @IBOutlet weak var testingImageView: UIImageView!
    @IBOutlet weak var transformXTextField: UITextField!
    @IBOutlet weak var transformYTextField: UITextField!
    @IBOutlet weak var transformButton: UIButton!
    @IBOutlet weak var scaleXTextField: UITextField!
    @IBOutlet weak var scaleYTextField: UITextField!
    @IBOutlet weak var scaleButton: UIButton!
    @IBOutlet weak var rotateTextField: UITextField!
    @IBOutlet weak var rotateButton: UIButton!
    
    
    private var originalImage: UIImage?
    private var cumulativeTransform = CGAffineTransform.identity
    private var currentValueOfX: CGFloat = 0 {
        didSet { print("Transform X updated: \(currentValueOfX)") }
    }
    private var currentValueOfY: CGFloat = 0 {
        didSet { print("Transform Y updated: \(currentValueOfY)") }
    }
    private var currentScaleX: CGFloat = 1 {
        didSet { print("Scale X updated: \(currentScaleX)") }
    }
    private var currentScaleY: CGFloat = 1 {
        didSet { print("Scale Y updated: \(currentScaleY)") }
    }
    private var currentRotation: CGFloat = 0 {
        didSet { print("Rotation value updated: \(currentRotation)") }
    }
    private var context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func aplyFiler(_ sender: UIButton) {
        self.view.endEditing(true)
        
        guard let title = sender.titleLabel?.text,
              let currentSender = operationType(rawValue: title) else {
            print("Invalid or nil button title")
            return
        }
        
        guard let baseImage = testingImageView.image else {
            print("Original image missing.")
            return
        }
        
        switch currentSender {
        case .Rotate:
            let radians = currentRotation * CGFloat.pi / 180
            let center = CGPoint(x: baseImage.size.width / 2, y: baseImage.size.height / 2)
            cumulativeTransform = CGAffineTransform(translationX: center.x, y: center.y)
                .rotated(by: radians)
                .translatedBy(x: -center.x, y: -center.y)
            
        case .Scale:
            self.testingImageView.transform = self.testingImageView.transform.scaledBy(x: currentScaleX, y: currentScaleY)
            return
            
        case .Transform:
            let translation = CGAffineTransform(translationX: currentValueOfX, y: currentValueOfY)
            self.testingImageView.transform = self.testingImageView.transform.concatenating(translation)
            return
        case .RESET:
            cumulativeTransform = .identity
            currentScaleX = 1
            currentScaleY = 1
            currentValueOfX = 0
            currentValueOfY = 0
            currentRotation = 0
            transformXTextField.text = ""
            transformYTextField.text = ""
            scaleXTextField.text = ""
            scaleYTextField.text = ""
            rotateTextField.text = ""
            self.testingImageView.transform = .identity
            self.testingImageView.image = originalImage
            return
        }
        
        let transformToApply = cumulativeTransform
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let inputCIImage = CIImage(image: baseImage) else { return }
            
            let transformedImage = inputCIImage.transformed(by: transformToApply)
            let outputExtent = inputCIImage.extent.union(transformedImage.extent)
            
            if let cgImage = self.context.createCGImage(transformedImage, from: outputExtent) {
                let outputImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.testingImageView.image = outputImage
                }
            } else {
                print("Failed to create CGImage")
            }
        }
    }
    
    private func setupUI() {
        originalImage = testingImageView.image
        transformXTextField.delegate = self
        transformYTextField.delegate = self
        scaleXTextField.delegate = self
        scaleYTextField.delegate = self
        rotateTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let value = Double(text) else {
            print("Invalid input in text field: \(textField.placeholder ?? "")")
            return
        }
        
        switch textField {
        case transformXTextField:
            currentValueOfX = CGFloat(value)
        case transformYTextField:
            currentValueOfY = CGFloat(value)
            
        case scaleXTextField:
            currentScaleX = CGFloat(value)
            
        case scaleYTextField:
            currentScaleY = CGFloat(value)
            
        case rotateTextField:
            currentRotation = CGFloat(value)
            
        default:
            break
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        debugPrint("self.view.frame.origin.y  -> \(self.view.frame.origin.y)")
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardFrame.height / 2 + 60
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}



enum operationType: String {
    case Rotate = "Rotate"
    case Scale = "Scale"
    case Transform = "Transform"
    case RESET = "RESET"
}
