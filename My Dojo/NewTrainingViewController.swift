//
//  NewTrainingViewController.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-31.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit

class NewTrainingViewController: UIViewController {
    
    var notificationObservers: [NSObjectProtocol?] = []
    var notificationCenter: NotificationCenter {
        get {
            return NotificationCenter.default
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = TimeZone.current
        
        let date = Date()
        
        dateTextField.text = dateFormatter.string(for: date)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addNotificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var addTrainingButton: UIButton!
    
    // This will save the training to Core data, once doing that a notification will be called that changes view
    @IBAction func addNewtrainingToProgress(_ sender: UIButton) {
        DatabaseManager.context.perform { [unowned self] in
            guard let training: Training = Training.createTraining(at: self.dateTextField.text!, journal: self.journalTextField.text!, inManagedObjectContext: DatabaseManager.context) else { return }
            do {
                for technique in self.selectedTechniques! {
                    training.addToTechniques(technique)
                }
                
                try DatabaseManager.context.save()
                
            } catch {
                debugPrint("Error saving training: \(error)")
            }
        }
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
            if !selectedTechniques!.isEmpty {
                destinationvc.selectedTechniques = selectedTechniques!
            } else {
                destinationvc.clearSelection()
            }/*else {
                if !destinationvc.selectedTechniques.isEmpty {
                    destinationvc.clearSelection()
                }
            }*/
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
        
        datePicker!.backgroundColor = Constants.backgroundColor
        datePicker!.setValue(Constants.systemColor, forKey: "textColor")
        
        var toolBarFrame = CGRect.zero
        toolBarFrame.size.height = Constants.minButtonHeight
        
        datePickerToolbar = UIToolbar(frame: toolBarFrame)
        datePickerToolbar?.barStyle = .black
        datePickerToolbar?.backgroundColor = Constants.backgroundColor
        datePickerToolbar?.tintColor = Constants.systemColor
        
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
        
        //dateTextField.text = dateFormatter!.string(from: datePicker!.date)
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker) {
        
        dateTextField.text = dateFormatter!.string(from: sender.date)
    }
    
    func datePickerDone() {
        dateTextField.resignFirstResponder()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Techniques
    var selectedTechniques: [Technique]? = [Technique]()
    
    @IBAction func addTechniques(_ sender: Any) {
        DispatchQueue.main.async { [unowned self] in
            self.performSegue(withIdentifier: Constants.addTechniquesSegue, sender: self)
        }
    }
    
    // MARK: Journal
    @IBOutlet weak var journalTextField: UITextView!
}

// Unwind segue to get back to here from different places
extension NewTrainingViewController {
    @IBAction func unwindToNewTraining(_ sender: UIStoryboardSegue)
    {
        if let source = sender.source as? TechniquesTableViewController {
            selectedTechniques = source.selectedTechniques
            tableView.reloadData()
        }
    }
}

extension NewTrainingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.newTrainingTechniqueCell, for: indexPath) as! NewTrainingTechniqueTableViewCell
        
        let technique = selectedTechniques?[indexPath.row]
        
        cell.techniqueLabel.text = technique?.japaneseName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTechniques != nil ? selectedTechniques!.count : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// MARK: - Notifications

extension NewTrainingViewController: ListensForNotifications {
    
    
    internal func addNotificationObservers() {
        
        let trainingCreatedObserver: NSObjectProtocol? = notificationCenter.addObserver(forName: .newTrainingCreatedNotification, object: nil, queue: OperationQueue.main) { [unowned self] notification in
            
            StatisticsManager.sharedInstance.updateStatistics()
            
            self.selectedTechniques = nil
            DispatchQueue.main.async { [unowned self] in
                self.performSegue(withIdentifier: Constants.unwindToMainSeuge, sender: self)
            }
            
        }
        
        notificationObservers.append(trainingCreatedObserver)
        debugPrint("Add notification observers")
    }
    
    internal func removeNotificationObservers() {
        
        if !notificationObservers.isEmpty {
            for observer in notificationObservers {
                notificationCenter.removeObserver(observer!)
            }
            notificationObservers.removeAll()
            debugPrint("Remove notification observers")
        }
        debugPrint("Notification observers are already removed")
    }
}
