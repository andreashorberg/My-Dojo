//
//  NewTrainingViewController.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-31.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit

class NewTrainingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var destinationvc = segue.destination
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        if let destinationvc = segue.destination as? TechniquesTableViewController {
            destinationvc.isSelectionMode = true
        }
    }
    

    
    // MARK: - DatePicker
    @IBOutlet weak var dateTextField: UITextField!
    var datePicker: UIDatePicker?
    var dateFormatter: DateFormatter?
    var datePickerToolbar: UIToolbar?
    
    func setupDatePicker(_ sender: UITextField) {
        datePicker = UIDatePicker()
        datePicker!.datePickerMode = .date
        datePicker!.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        var toolBarFrame = CGRect.zero
        toolBarFrame.size.height = Constants.minButtonHeight
        
        datePickerToolbar = UIToolbar(frame: toolBarFrame)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        datePickerToolbar!.setItems([space, doneButton], animated: false)
        
        sender.inputView = datePicker
        sender.inputAccessoryView = datePickerToolbar
    }
    
    @IBAction func dateTextFieldEditing(_ sender: UITextField) {
        setupDatePicker(sender)
        
        dateFormatter = DateFormatter()
        dateFormatter!.dateStyle = .medium
        dateFormatter!.timeStyle = .none
        
        dateTextField.text = dateFormatter!.string(from: datePicker!.date)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        dateTextField.text = dateFormatter!.string(from: sender.date)
    }
    
    func datePickerDone() {
        dateTextField.resignFirstResponder()
    }
    
    // MARK: Techniques
    var selectedTechniques = [Technique]()
}

// Unwind segue to get back to main menu from different places
extension NewTrainingViewController {
    @IBAction func unwindToNewTraining(sender: UIStoryboardSegue)
    {
        if let source = sender.source as? TechniquesTableViewController {
            selectedTechniques = source.selectedTechniques
            debugPrint(selectedTechniques)
        }
    }
}
