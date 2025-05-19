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
        
        switch currentSender {
        case .Rotate:
            let radians = currentRotation * CGFloat.pi / 180
            currentRotation += radians
            self.testingImageView.transform = CGAffineTransform(rotationAngle: currentRotation)
            return
        case .Scale:
            self.testingImageView.contentMode = .scaleAspectFit
            self.testingImageView.center = self.view.center
            self.testingImageView.transform = self.testingImageView.transform.scaledBy(x: currentScaleX, y: currentScaleY)
            return

        case .Translate:
                let translationTransform = CGAffineTransform(translationX: currentValueOfX, y: currentValueOfY)
                self.testingImageView.transform = self.testingImageView.transform.concatenating(translationTransform)
                return
        case .RESET:
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
            return
        }
    }
    
    private func setupUI() {
        self.testingImageView.backgroundColor = .red
        self.testingImageView.contentMode = .scaleAspectFit
        transformXTextField.delegate = self
        transformYTextField.delegate = self
        scaleXTextField.delegate = self
        scaleYTextField.delegate = self
        rotateTextField.delegate = self
        
        debugPrint("Center of ImageView -> \(self.testingImageView.center)")
        
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
    case Translate = "Translate"
    case RESET = "RESET"
}
