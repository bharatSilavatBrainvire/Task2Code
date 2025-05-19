//
//  MatrixPlaygroundViewController.swift
//  Task2
//
//  Created by Bharat Shilavat on 19/05/25.
//

import UIKit

class MatrixPlaygroundViewController: UIViewController {
    
    @IBOutlet weak var aTextField: UITextField!
    @IBOutlet weak var bTextField: UITextField!
    @IBOutlet weak var cTextField: UITextField!
    @IBOutlet weak var dTextField: UITextField!
    @IBOutlet weak var txTextField: UITextField!
    @IBOutlet weak var tyTextField: UITextField!
    @IBOutlet weak var transformableView: UIView!
    @IBOutlet weak var perspective1: UITextField!
    @IBOutlet weak var perspective2: UITextField!
    @IBOutlet weak var isAffineTransform: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set initial values in text fields
        aTextField.text = "1"
        bTextField.text = "0"
        cTextField.text = "0"
        dTextField.text = "1"
        txTextField.text = "0"
        tyTextField.text = "0"
        
        // Add targets to text fields to update on change
        [aTextField, bTextField, cTextField, dTextField, txTextField, tyTextField].forEach {
            $0?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
        // Initial setup of the transformableView
        transformableView.backgroundColor = .systemBlue
        transformableView.frame = CGRect(x: 100, y: 200, width: 100, height: 100)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateTransformableView()
    }
    
    func updateTransformableView() {
        guard let aValue = Double(aTextField.text ?? "1"),
              let bValue = Double(bTextField.text ?? "0"),
              let cValue = Double(cTextField.text ?? "0"),
              let dValue = Double(dTextField.text ?? "1"),
              let txValue = Double(txTextField.text ?? "0"),
              let tyValue = Double(tyTextField.text ?? "0") else {
            print("Invalid input in text fields")
            return
        }
        
        let transform = CGAffineTransform(
            a: CGFloat(aValue),
            b: CGFloat(bValue),
            c: CGFloat(cValue),
            d: CGFloat(dValue),
            tx: CGFloat(txValue),
            ty: CGFloat(tyValue)
        )
        transformableView.transform = transform
    }
}
