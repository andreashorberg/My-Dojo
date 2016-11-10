//
//  TechniquesTableViewController.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-20.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit
import CoreData

class TechniquesTableViewController: CoreDataTableViewController {
    
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    var isSelectionMode: Bool = false
    
    var isSearchActive: Bool {
        get {
            return searchController != nil ? (searchController?.isActive)! && !(searchController?.searchBar.text?.isEmpty)! : false
        }
    }
    
    var strategyBook: String? {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI()
    {
        if let context = managedObjectContext {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Technique")
            if let book = strategyBook {
                request.predicate = NSPredicate(format: "chapter.strategyBook.japaneseName contains[c] %@", book)
            }
            if isSelectionMode {
                request.sortDescriptors = [NSSortDescriptor(key: "japaneseName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            } else {
                request.sortDescriptors = [NSSortDescriptor(key: "chapter.japaneseName", ascending: true, selector: nil), NSSortDescriptor(key: "japaneseName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "chapter.japaneseName", cacheName: nil)
            }
            
        } else {
            fetchedResultsController = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        addSearchController()
        if isSelectionMode {
            addToolbar()
            
            doneButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(doneButtonAction))
            doneButton?.isEnabled = false
            navigationItem.rightBarButtonItem = doneButton
            
            removeAllButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeSelection))
            removeAllButton?.isEnabled = isTechniqueSelected
        }
        setupTableView()
        if selectedTechniques.isEmpty {
            clearSelection()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !selectedTechniques.isEmpty {
            numberOfSelectedTechniques = selectedTechniques.count
            navigationItem.leftBarButtonItem = removeAllButton
            isEditingSelection = true
        }
    }
    
    // MARK: Search
    
    fileprivate var searchController: UISearchController?
    fileprivate var toolbar: UIToolbar?
    fileprivate var filteredTechniques = [Technique]()
    
    fileprivate func addSearchController() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController!.searchResultsUpdater = self
        searchController!.dimsBackgroundDuringPresentation = false
        
        searchController?.searchBar.barStyle = .black
        searchController?.searchBar.tintColor = .orange
        
        searchController?.loadViewIfNeeded()
        
        definesPresentationContext = true //make sure the searchbar doesn't remain on screen when switching views in the middle of searching
        tableView.tableHeaderView = searchController!.searchBar
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredTechniques = (fetchedResultsController?.fetchedObjects as? [Technique])!.filter { technique in
            return technique.japaneseName!.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    // MARK: Selection
    
    open var selectedTechniques = [Technique]()
    fileprivate var doneButton: UIBarButtonItem?
    fileprivate var removeAllButton: UIBarButtonItem?
    fileprivate var isEditingSelection: Bool = false

    fileprivate var _numberOfSelectedTechniques = 0
    fileprivate var numberOfSelectedTechniques: Int {
        get { return _numberOfSelectedTechniques }
        set {
            _numberOfSelectedTechniques = newValue
            if _numberOfSelectedTechniques == 0 {
                //navigationItem.leftBarButtonItem = nil
                isTechniqueSelected = false
            } else if _numberOfSelectedTechniques > 0 && !isTechniqueSelected {
                isTechniqueSelected = true
            } else {
                navigationItem.leftBarButtonItem = removeAllButton
            }
        }
    }
    
    fileprivate var _isTechniqueSelected: Bool = false
    fileprivate var isTechniqueSelected: Bool {
        get { return _isTechniqueSelected }
        set {
            _isTechniqueSelected = newValue
            clearAllButton?.isEnabled = newValue
            if newValue == false && isEditingSelection {
                removeAllButton?.isEnabled = true
            } else if newValue == false && !isEditingSelection {
                navigationItem.leftBarButtonItem = nil
            } else if newValue == true {
                if navigationItem.leftBarButtonItem == nil {
                    navigationItem.leftBarButtonItem = removeAllButton
                }
                removeAllButton?.isEnabled = newValue
            }
            doneButton?.isEnabled = newValue
        }
    }

    fileprivate var clearAllButton: UIBarButtonItem?
    
    fileprivate func addToolbar() {
        var toolbarFrame = CGRect.zero
        toolbarFrame.size.height = Constants.minButtonHeight
        
        toolbar = UIToolbar(frame: toolbarFrame)
        toolbar?.barStyle = .black
        toolbar?.tintColor = .orange
        
        clearAllButton = UIBarButtonItem(title: "Clear all", style: .plain, target: self, action: #selector(clearSelection))
        clearAllButton?.isEnabled = isTechniqueSelected
    
        
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar!.setItems([space, clearAllButton!], animated: false)
    }
    
    func clearSelection() {
        if isSearchActive {
            for technique in filteredTechniques {
                if technique.isSelected { technique.isSelected = false }
            }
        } else {
            if fetchedResultsController != nil {
                for technique in (fetchedResultsController?.fetchedObjects as? [Technique])! {
                    if technique.isSelected { technique.isSelected = false }
                }
            }
        }
        isTechniqueSelected = false
        selectedTechniques.removeAll()
        tableView.reloadData()
    }
    
    func removeSelection() {
        let alert = UIAlertController(title: "Remove techniques", message: "This action will remove all your selected techniques, are you sure?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Yes", style: .destructive, handler: { [unowned self] _ in
            self.clearSelection()
            self.doneButtonAction()
        })
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func doneButtonAction() {
        debugPrint("doneButtonAction called")
        
        DispatchQueue.main.async { [unowned self] in
            self.performSegue(withIdentifier: Constants.selectTechniquesSegue, sender: self)
        }
        
    }
    
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationvc = segue.destination
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        
        if let techdetailsvc = destinationvc as? TechniqueDetailViewController {
            guard let cell = sender as? UITableViewCell else { return }
            
            let rowTitle = cell.textLabel?.text
            techdetailsvc.navigationItem.title = rowTitle
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            self.navigationItem.backBarButtonItem = backItem
            
            if isSearchActive {
                let technique = filteredTechniques[self.tableView.indexPath(for: cell)!.row]
                techdetailsvc.technique = technique
            } else if let technique = fetchedResultsController?.object(at: self.tableView.indexPath(for: cell)!) as? Technique {
                techdetailsvc.technique = technique
            } else {
                return
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if isSelectionMode {
            return false
        }
        return true
    }
    
    // MARK: TableView
    
    fileprivate var cellAccessoryType = UITableViewCellAccessoryType.disclosureIndicator
    
    fileprivate func setupTableView() {
        tableView.sectionIndexBackgroundColor = UIColor.clear // the right side index for sections covers the searchbar, this is a decent trade off
        
        if isSelectionMode {
            tableView.allowsMultipleSelection = true
            cellAccessoryType = .none
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TechniqueCell", for: indexPath)
        
        let cellTechnique: Technique
        
        if isSearchActive {
            cellTechnique = filteredTechniques[indexPath.row]
        } else {
            guard let technique = fetchedResultsController?.object(at: indexPath) as? Technique else { return cell }
            cellTechnique = technique
        }
        
        var name: String? = ""
        var strategyBook: String? = ""
        cellTechnique.managedObjectContext?.performAndWait {
            name = cellTechnique.japaneseName
            strategyBook = cellTechnique.chapter?.strategyBook?.japaneseName!
        }
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = strategyBook
        if cellTechnique.isSelected {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = cellAccessoryType
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filteredTechniques.count
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSelectionMode || isSearchActive {
            return 1
        } else {
            return super.numberOfSections(in: tableView)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isSelectionMode {
            return isSearchActive ? nil : toolbar
        } else {
            return super.tableView(tableView, viewForFooterInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isSelectionMode {
            return isSearchActive ? 0 : Constants.minButtonHeight
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearchActive {
            if let searchText = searchController?.searchBar.text {
                return "Results for \"\(searchText)\""
            }
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), isSelectionMode {
            cell.accessoryType = .checkmark
            let selectedTechnique: Technique = isSearchActive ? filteredTechniques[indexPath.row] : (fetchedResultsController?.object(at: indexPath) as! Technique)
            
            if !isTechniqueSelected { isTechniqueSelected = true }
            
            if !selectedTechnique.isSelected {
                selectedTechnique.isSelected = true
                numberOfSelectedTechniques += 1
                selectedTechniques.append(selectedTechnique)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), isSelectionMode {
            cell.accessoryType = .none
            let deselectedTechnique: Technique = isSearchActive ? filteredTechniques[indexPath.row] : (fetchedResultsController?.object(at: indexPath) as! Technique)
            deselectedTechnique.isSelected = false
            
            numberOfSelectedTechniques -= 1
            if let techniqueIndex = selectedTechniques.index(of: deselectedTechnique) {
                selectedTechniques.remove(at: techniqueIndex)
            }
        }
    }

    //    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //        return nil
    //    }
}

// MARK: UISearchResultsUpdating

extension TechniquesTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
