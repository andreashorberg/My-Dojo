//
//  TechniqueDetailViewController.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-10-21.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit

class TechniqueDetailViewController: UIViewController {
    
    var technique: Technique?
    let numberOfSteps = 8 //This should be in Technique later on
    
    @IBOutlet weak var techniqueImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSwitches()
        setupPageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var collection: UICollectionView!
    
    fileprivate func setupPageControl(){
        pageControl.numberOfPages = self.numberOfSteps
        pageControl.currentPage = 0
    }

    
    fileprivate func setupSwitches() {
        warmupSwitch.isOn = technique!.isWarmup
        pairSwitch.isOn = technique!.isTogetherPractice
        aloneSwitch.isOn = technique!.isAlonePractice
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var warmupSwitch: UISwitch!
    @IBAction func switchWarmup(_ sender: AnyObject) {
        technique?.isWarmup = warmupSwitch.isOn
    }
    
    @IBOutlet weak var pairSwitch: UISwitch!
    @IBAction func switchPair(_ sender: AnyObject) {
        technique?.isTogetherPractice = pairSwitch.isOn
    }
    
    @IBOutlet weak var aloneSwitch: UISwitch!
    @IBAction func switchAlone(_ sender: AnyObject) {
        technique?.isAlonePractice = aloneSwitch.isOn
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if technique!.hasPersistentChangedValues {
            do {
                try technique!.managedObjectContext!.save()
                debugPrint ("Context saved")
            } catch let error {
                debugPrint ("Core Data Error: \(error)")
            }
        }
    }
    
}

extension TechniqueDetailViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfSteps
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepCell", for: indexPath) as! StepCollectionViewCell
        
        cell.title.text = "Step " + String(describing: indexPath.row)
        cell.text.text = "Put your left foot forward, put your right arm up, jiggle a little. I have no idea what I'm doing here."
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = ceil(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
