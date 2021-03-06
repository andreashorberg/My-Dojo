//
//  MyDojoTabBarController.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-09-16.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit

class MyDojoViewController: UIViewController {

    var notificationObservers: [NSObjectProtocol?] = []
    var notificationCenter: NotificationCenter {
        get {
            return NotificationCenter.default
        }
    }

    fileprivate var dojoButtonCell: LargeTileCollectionViewCell?

    @IBOutlet weak var menuCollectionView: UICollectionView!

    fileprivate var mainMenu: Menu? {
        didSet {
            menuCollectionView.reloadData()
        }
    }

    var dojo: Dojo?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.viewTitle
        //        DatabaseManager.populateDatabase(with: "StrategyBooks")
        DatabaseManager.read(propertyList: "StrategyBooks")
        addNotificationObservers()

        DatabaseManager.createMainMenu()

        updateStatisticsLabels(restart: true)
    }

    deinit {
        removeNotificationObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if mainMenu == nil {
            DatabaseManager.getMainMenu(from: self)
        }

        if dojo == nil {
            DatabaseManager.getDojo(from: self)
        }

        debugPrint(StatisticsManager.sharedInstance)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //updateStatisticsLabels()
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationvc = segue.destination
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        destinationvc.navigationItem.title = segue.identifier
        if let sdvc = destinationvc as? SelectedDojoViewController {
            sdvc.navigationItem.title = dojo?.mapItem?.placemark.name
            sdvc.myDojo = dojo
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var shouldPerform = true

        if /*identifier == "Progress" || */identifier == "Suggest Training" {
            let alert = UIAlertController(title: "Not implemented", message: "Woops, this feature is not implemented yet", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Oh well..", style: .default, handler: nil)
            alert.addAction(ok)

            self.present(alert, animated: true, completion: nil)
            shouldPerform = false
        }
        return shouldPerform
    }

    // MARK: - Statistics

    @IBOutlet weak var numberOfTrainingsLabel: CountingLabel!
    @IBOutlet weak var numberOfTrainedTechniquesLabel: CountingLabel!
    @IBOutlet weak var currentStreakLabel: CountingLabel!

    fileprivate func updateStatisticsLabels(restart: Bool) {

        var beginNum: Int = restart == true ? 0 : numberOfTrainingsLabel!.currentValue
        numberOfTrainingsLabel?.beginCounting(from: beginNum, to: StatisticsManager.sharedInstance.getNumberOfTrainings())

        beginNum = restart == true ? 0 : numberOfTrainedTechniquesLabel!.currentValue
        numberOfTrainedTechniquesLabel.beginCounting(from: beginNum, to: StatisticsManager.sharedInstance.getNumberOfTrainedTechniques())

        currentStreakLabel.suffix = "w"
        beginNum = restart == true ? 0 : currentStreakLabel!.currentValue
        currentStreakLabel.beginCounting(from: beginNum, to: StatisticsManager.sharedInstance.getCurrentStreak())

    }
}

// Unwind segue to get back to main menu from different places
extension MyDojoViewController {
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        if sender.source is SelectedDojoViewController {
            self.dojo = nil
        }
    }
}

//Button effects
extension MyDojoViewController {
    func setBlur(for button: UIButton, with visualEffect: UIVisualEffectView, show: Bool, duration: Double) {
        DispatchQueue.main.async { [unowned button, visualEffect] in
            let animations: (() -> Void)? = {
                visualEffect.isHidden = show
            }
            UIView.transition(with: button, duration: duration, options: .transitionCrossDissolve, animations: animations, completion: nil)
        }
    }
}

// MARK: - Notifications
extension MyDojoViewController: ListensForNotifications {
    internal func addNotificationObservers() {
        debugPrint("Add notification observers")
        let dojoRemovedObserver: NSObjectProtocol? = notificationCenter.addObserver(forName: .dojoRemovedNotification,
                                                                                    object: nil,
                                                                                    queue: OperationQueue.main) {
            [unowned self] notification in
            self.dojo = nil
            self.dojoButtonCell?.mapImage = nil
            self.dojoButtonCell?.setNeedsDisplay()
        }

        // Look for notification initiated by DatabaseManager restore(sender:), triggered by button press "My Dojo" or any other source
        let getDojoObserver: NSObjectProtocol? = notificationCenter.addObserver(forName: .getDojoNotification,
                                                                                object: nil,
                                                                                queue: OperationQueue.main) { [unowned self] notification in

            switch notification.userInfo!["sender"] {
            case is MyDojoViewController:
                if let dojo = notification.userInfo?["dojo"] as? Dojo {
                    self.dojo = dojo
                    //self.dojoButtonCell?.setNeedsDisplay()
                }
                break
            case is UIButton:
                if let _ = notification.userInfo?["dojo"] as? Dojo {
                    self.dojo = notification.userInfo!["dojo"] as? Dojo
                    DispatchQueue.main.async { [unowned self] in
                        self.performSegue(withIdentifier: Constants.selectedDojoSegue, sender: self)
                    }
                } else {
                    DispatchQueue.main.async { [unowned self] in
                        self.performSegue(withIdentifier: Constants.newDojoSegue, sender: self)
                    }
                }
                break
            default:
                // where did my notification come from?
                debugPrint("\(Notification.Name.getDojoNotification) from unknown source. \(notification)")
                break
            }

        }

        let getMainMenuObserver: NSObjectProtocol? = notificationCenter.addObserver(forName: .getMainMenuNotification,
                                                                                    object: nil,
                                                                                    queue: OperationQueue.main) { [unowned self] notification in
            if let menu = notification.userInfo?["menu"] as? Menu {
                self.mainMenu = menu
            }

        }

        let plistReadObserver: NSObjectProtocol? = notificationCenter.addObserver(forName: .plistReadNotification,
                                                                                  object: nil,
                                                                                  queue: OperationQueue.main) { notification in
            if let plist = notification.userInfo?["plist"] {
                DatabaseManager.populateDatabase(with: plist)
            }
        }

        let statisticsUpdatedObserver: NSObjectProtocol? = notificationCenter.addObserver(forName: .statisticsUpdatedNotification,
                                                                                          object: nil,
                                                                                          queue: OperationQueue.main) { [unowned self] _ in
            self.updateStatisticsLabels(restart: false)
        }

        notificationObservers.append(getDojoObserver!)
        notificationObservers.append(dojoRemovedObserver!)
        notificationObservers.append(getMainMenuObserver!)
        notificationObservers.append(plistReadObserver!)
        notificationObservers.append(statisticsUpdatedObserver!)
    }

    internal func removeNotificationObservers() {
        if !notificationObservers.isEmpty {
            for observer in notificationObservers {
                notificationCenter.removeObserver(observer!)
            }
            notificationObservers.removeAll()
            debugPrint("Remove notification observers from MyDojo")
        }
        debugPrint("Notification observers are already removed from MyDojo")
    }
}

// MARK: - CollectionView

extension MyDojoViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == menuCollectionView! {
            count = (mainMenu?.menuItems?.count) != nil ? (mainMenu?.menuItems?.count)! : 0
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == menuCollectionView {
            let menuItem = mainMenu?.getMenuItem(at: indexPath.row)
            let identifier = (menuItem?.reusableIdentifier != nil) ? menuItem?.reusableIdentifier : "Cell"

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier!, for: indexPath)

            switch cell {
            case let cell as LargeTileCollectionViewCell:
                if dojo != nil {
                    guard let image = dojo?.mapImage as? UIImage else { fatalError("Couldn't create mapImage for cell") }
                    cell.mapImage = image
                    cell.isDojoSelected = true
                } else {
                    cell.mapImage = nil
                }
                self.dojoButtonCell = cell
                break
            case let cell as SmallTileCollectionViewCell:
                cell.action = menuItem?.action
                cell.delegate = self
                cell.button.setTitle(menuItem?.title, for: .normal)
                if !(menuItem?.imageAsset?.isEmpty)! {
                    let image = UIImage(named: menuItem!.imageAsset!)
                    cell.button.setImage(image, for: .normal)
                    cell.button.imageView?.contentMode = .scaleAspectFit
                }

                break
            default:
                break
            }

            return cell
        } else {
            let identifier = "SpinnerCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGSize = CGSize.zero

        if collectionView == menuCollectionView {
            let menuItem = mainMenu?.getMenuItem(at: indexPath.row)
            switch menuItem!.reusableIdentifier! {
            case Constants.largeTile: size = Constants.largeTileSize; break
            case Constants.smallTile: size = Constants.smallTileSize; break
            default: break
            }
        }
        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        if cell.reuseIdentifier == Constants.smallTile {
            DispatchQueue.main.async { [unowned self] in
                self.performSegue(withIdentifier: (self.mainMenu?.menuItems?.allObjects[indexPath.row] as? MenuItem)!.action!, sender: self)
            }
        }
    }

    // Add this back after fixing the view
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //        let pageNumber = ceil(scrollView.contentOffset.x / scrollView.frame.size.width)
    //        pageControl.currentPage = Int(pageNumber)
    //    }
}
// MARK: - MenuItem

extension MyDojoViewController: MenuItemDelegate {
    func menuButtonAction(with action: String) {
        DispatchQueue.main.async { [unowned self] in
            if self.shouldPerformSegue(withIdentifier: action, sender: self) {
                self.performSegue(withIdentifier: action, sender: self)
            }
        }
    }
}
