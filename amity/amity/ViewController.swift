//
//  ViewController.swift
//  amity
//
//  Created by Annette Chen on 10/19/17.
//  Copyright © 2017 Annette Chen. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stepNumber: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let healthStore = HKHealthStore()
    
    @IBAction func getTodaysSteps() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount = 0.0
            self.stepNumber.text = "in query"
            guard let result = result else {
//                log.error("Failed to fetch steps = \(error?.localizedDescription ?? "N/A")")
                return
            }
            
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }
            
            DispatchQueue.main.async {
//                completion(resultCount)
            }
        }
        healthStore.execute(query)
    }

    @IBAction func getSteps(){
        let healthStore: HKHealthStore? = {
            if HKHealthStore.isHealthDataAvailable() {
                return HKHealthStore()
            } else {
                return nil
            }
        }()
        
        let stepsCount = HKQuantityType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let dataTypesToWrite = NSSet(object: stepsCount)
        let dataTypesToRead = NSSet(object: stepsCount)
        
        healthStore?.requestAuthorization(toShare: dataTypesToWrite as! Set<HKSampleType>,
                                          read: dataTypesToRead as! Set<HKObjectType>,
                                                      completion: { [unowned self] (success, error) in
                                                        if success {
                                                            print("SUCCESS")
                                                        } else {
                                                            print(error.debugDescription)
                                                        }
        })
        
        let stepsSampleQuery = HKSampleQuery(sampleType: stepsCount!,
                                             predicate: nil,
                                             limit: 100,
                                             sortDescriptors: nil)
        { [unowned self] (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                print(results)
                self.stepNumber.text = "weee"
                //self.steps = results
                //self.tableView.reloadData()
            }
            //self.activityIndicator.stopAnimating()
        }

        healthStore?.execute(stepsSampleQuery)
    }
}

