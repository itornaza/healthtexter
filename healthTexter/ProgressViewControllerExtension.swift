//
//  ProgressViewControllerExtension.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 16/1/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

/// Holds the configuration methods for the UIViews
extension ProgressViewController {
    
    /// Returns the last number of entries from the arrays indicated by the numberOfDays desired. The resulting arrays are a subset of their parents
    func getLastEntries(storedDatesArray: [String], storedRanksArray: [Int], numberOfDays: Int) -> ([String], [Int]) {
        var lastDatesArray = [String]()
        var lastRanksArray = [Int]()
        
        var ix: Int = 0
        
        // The most recent date lies at index 0 since the array is not yet reversed. Just push the 7 first dates to the weekArray
        for date in storedDatesArray {
            if ix < numberOfDays {
                lastDatesArray.append(date)
            } else {
                break
            }
            ix += 1
        }
        
        // Same with the desired rank, keep the 7 most recent from index 0 to 6
        ix = 0
        for rank in storedRanksArray {
            if ix < numberOfDays {
                lastRanksArray.append(rank)
            } else {
                break
            }
            ix += 1
        }
        
        return (lastDatesArray, lastRanksArray)
    }
    
    func configurePainView(numberOfDays: Int) {
        // Make sure the date labels are hidden ix is the index for the x-axis labels
        for ix in 1...7 {
            if let labelView = self.painView.viewWithTag(ix) as? UILabel {
                labelView.hidden = true
            }
        }
        
        // Create two arrays that will hold the X and Y axis data for ploting
        var datesArray: [String] = Array()
        var painRankArray: [Int] = Array()
        
        // Initialize the arrays from Core Data
        for entry in (self.fetchedResultsController.fetchedObjects! as! [Entry]) {
            datesArray.append(Date.getFormatted(entry.date, formatString: Date.dateFormatPlot))
            painRankArray.append(entry.painRank.integerValue)
        }
        
        // If the arrays are empty, fill them with zeros
        if datesArray.count == 0 {
            for _ in 0..<numberOfDays {
                datesArray.append("")
                painRankArray.append(0)
            }
        }
        
        // Keep only the last week or month dates for plotting
        if datesArray.count > numberOfDays {
            (datesArray, painRankArray) = self.getLastEntries(
                datesArray, storedRanksArray: painRankArray, numberOfDays: numberOfDays
            )
        }
        
        // Reverse the arrays to plot the most recent entry to the right
        datesArray = datesArray.reverse()
        painRankArray = painRankArray.reverse()
        
        // Feed the plot data to the PainView class
        self.painView.graphPoints = painRankArray
        
        // Indicate that the graph needs to be redrawn
        self.painView.setNeedsDisplay()
        
        // Max pain label
        self.maxPain.text = "\(self.painView.graphPoints.maxElement()!)"
        
        // Average pain label
        let average = self.painView.graphPoints.reduce(0, combine: +) / self.painView.graphPoints.count
        self.averagePain.text = "\(average)"
        
        // Dates to storyboard labels
        if numberOfDays <= Constants.daysInWeek {
            var ix = 1  // Tag index starts from 1
            for date in datesArray {
                if let labelView = self.painView.viewWithTag(ix) as? UILabel {
                    labelView.text = "\(date)"
                    if ix == 1 || ix == 4 || ix == 7 {
                        labelView.hidden = false
                    }
                }
                ix += 1
            }
        } else {
            var ix = 1
            var iy = 1
            for date in datesArray {
               
                // Assign the dates to the 3 labels
                if iy == 1 || iy == 15 || iy == 30 {
                    
                    // Get the date for the label
                    if let labelView = self.painView.viewWithTag(ix) as? UILabel {
                        labelView.text = "\(date)"
                        
                        // Show the date label
                        if ix == 1 || ix == 4 || ix == 7 {
                            labelView.hidden = false
                            ix = ix + 3
                        }
                    }
                }
                iy += 1
            }
        }
    }
    
    func configureSleepView(numberOfDays: Int) {
        // Make sure the date labels are hidden ix is the index for the x-axis labels
        for ix in 1...7 {
            if let labelView = self.sleepView.viewWithTag(ix) as? UILabel {
                labelView.hidden = true
            }
        }
        
        // Create two arrays that will hold the X and Y axis data for ploting
        var datesArray: [String] = Array()
        var sleepRankArray: [Int] = Array()
        
        // Initialize the arrays from Core Data
        for entry in (self.fetchedResultsController.fetchedObjects! as! [Entry]) {
            datesArray.append(Date.getFormatted(entry.date, formatString: Date.dateFormatPlot))
            sleepRankArray.append(entry.sleepRank.integerValue)
        }
        
        // If the arrays are empty, fill them with zeros
        if datesArray.count == 0 {
            for _ in 0..<numberOfDays {
                datesArray.append("")
                sleepRankArray.append(0)
            }
        }
        
        // Keep only the last week or month dates for plotting
        if datesArray.count > numberOfDays {
            (datesArray, sleepRankArray) = self.getLastEntries(
                datesArray, storedRanksArray: sleepRankArray, numberOfDays: numberOfDays
            )
        }
        
        // Reverse the arrays to plot the most recent entry to the right
        datesArray = datesArray.reverse()
        sleepRankArray = sleepRankArray.reverse()
        
        // Feed the plot data to the PainView class
        self.sleepView.graphPoints = sleepRankArray
        
        // Indicate that the graph needs to be redrawn
        self.sleepView.setNeedsDisplay()
        
        // Max pain label
        self.maxSleep.text = "\(self.sleepView.graphPoints.maxElement()!)"
        
        // Average pain label
        let average = self.sleepView.graphPoints.reduce(0, combine: +) / self.sleepView.graphPoints.count
        self.averageSleep.text = "\(average)"
        
        // Dates to storyboard labels
        if numberOfDays <= Constants.daysInWeek {
            var ix = 1  // Tag index starts from 1
            for date in datesArray {
                if let labelView = self.sleepView.viewWithTag(ix) as? UILabel {
                    labelView.text = "\(date)"
                    if ix == 1 || ix == 4 || ix == 7 {
                        labelView.hidden = false
                    }
                }
                ix += 1
            }
        } else {
            var ix = 1
            var iy = 1
            for date in datesArray {
                
                // Assign the dates to the 3 labels
                if iy == 1 || iy == 15 || iy == 30 {
                    
                    // Get the date for the label
                    if let labelView = self.sleepView.viewWithTag(ix) as? UILabel {
                        labelView.text = "\(date)"
                        
                        // Show the date label
                        if ix == 1 || ix == 4 || ix == 7 {
                            labelView.hidden = false
                            ix = ix + 3
                        }
                    }
                }
                iy += 1
            }
        }
    }
    
    func configureFunctionalityView(numberOfDays: Int) {
        // Make sure the date labels are hidden ix is the index for the x-axis labels
        for ix in 1...7 {
            if let labelView = self.functionalityView.viewWithTag(ix) as? UILabel {
                labelView.hidden = true
            }
        }
        
        // Create two arrays that will hold the X and Y axis data for ploting
        var datesArray: [String] = Array()
        var functionalityRankArray: [Int] = Array()
        
        // Initialize the arrays from Core Data
        for entry in (self.fetchedResultsController.fetchedObjects! as! [Entry]) {
            datesArray.append(Date.getFormatted(entry.date, formatString: Date.dateFormatPlot))
            functionalityRankArray.append(entry.functionalityRank.integerValue)
        }
        
        // If the arrays are empty, fill them with zeros
        if datesArray.count == 0 {
            for _ in 0..<numberOfDays {
                datesArray.append("")
                functionalityRankArray.append(0)
            }
        }
        
        // Keep only the last week or month dates for plotting
        if datesArray.count > numberOfDays {
            (datesArray, functionalityRankArray) = self.getLastEntries(
                datesArray, storedRanksArray: functionalityRankArray, numberOfDays: numberOfDays
            )
        }
        
        // Reverse the arrays to plot the most recent entry to the right
        datesArray = datesArray.reverse()
        functionalityRankArray = functionalityRankArray.reverse()
        
        // Feed the plot data to the PainView class
        self.functionalityView.graphPoints = functionalityRankArray
        
        // Indicate that the graph needs to be redrawn
        self.functionalityView.setNeedsDisplay()
        
        // Max pain label
        self.maxFunctionality.text = "\(self.functionalityView.graphPoints.maxElement()!)"
        
        // Average pain label
        let average = self.functionalityView.graphPoints.reduce(0, combine: +) / self.functionalityView.graphPoints.count
        self.averageFunctionality.text = "\(average)"
        
        // Dates to storyboard labels
        if numberOfDays <= Constants.daysInWeek {
            var ix = 1  // Tag index starts from 1
            for date in datesArray {
                if let labelView = self.functionalityView.viewWithTag(ix) as? UILabel {
                    labelView.text = "\(date)"
                    if ix == 1 || ix == 4 || ix == 7 {
                        labelView.hidden = false
                    }
                }
                ix += 1
            }
        } else {
            var ix = 1
            var iy = 1
            for date in datesArray {
                
                // Assign the dates to the 3 labels
                if iy == 1 || iy == 15 || iy == 30 {
                    
                    // Get the date for the label
                    if let labelView = self.functionalityView.viewWithTag(ix) as? UILabel {
                        labelView.text = "\(date)"
                        
                        // Show the date label
                        if ix == 1 || ix == 4 || ix == 7 {
                            labelView.hidden = false
                            ix = ix + 3
                        }
                    }
                }
                iy += 1
            }
        }
    }

    func configureProgressView(numberOfDays: Int) {
        // Make sure the date labels are hidden ix is the index for the x-axis labels
        for ix in 1...7 {
            if let labelView = self.progressView.viewWithTag(ix) as? UILabel {
                labelView.hidden = true
            }
        }
        
        // Create two arrays that will hold the X and Y axis data for ploting
        var datesArray: [String] = Array()
        var progressRankArray: [Int] = Array()
        
        // Initialize the arrays from Core Data
        for entry in (self.fetchedResultsController.fetchedObjects! as! [Entry]) {
            datesArray.append(Date.getFormatted(entry.date, formatString: Date.dateFormatPlot))
            
            // Progress is inversly proportional to pain
            let reversePain: Int = (10 - entry.painRank.integerValue)
            
            // Progress is the average of all other categories with equal importance
            // and the reverse value of pain
            
            let ranksTotal: Double = Double(
                reversePain + entry.sleepRank.integerValue + entry.functionalityRank.integerValue
            )
            let allCategoriesAverage: Double =  ranksTotal / 3.0
            let progressPoint: Int = Int(round(allCategoriesAverage))
            progressRankArray.append(progressPoint)
        }
        
        // If the arrays are empty, fill them with zeros
        if datesArray.count == 0 {
            for _ in 0..<numberOfDays {
                datesArray.append("")
                progressRankArray.append(0)
            }
        }
        
        // Keep only the last week or month dates for plotting
        if datesArray.count > numberOfDays {
            (datesArray, progressRankArray) = self.getLastEntries(
                datesArray, storedRanksArray: progressRankArray, numberOfDays: numberOfDays
            )
        }
        
        // Reverse the arrays to plot the most recent entry to the right
        datesArray = datesArray.reverse()
        progressRankArray = progressRankArray.reverse()
        
        // Feed the plot data to the ProgressView class
        self.progressView.graphPoints = progressRankArray
        
        // Indicate that the graph needs to be redrawn
        self.progressView.setNeedsDisplay()
        
        // Max progress label
        self.maxProgress.text = "\(self.progressView.graphPoints.maxElement()!)"
        
        // Average progress label
        let average = self.progressView.graphPoints.reduce(0, combine: +) / self.progressView.graphPoints.count
        self.averageProgress.text = "\(average)"
        
        // Dates to storyboard labels
        if numberOfDays <= Constants.daysInWeek {
            var ix = 1  // Tag index starts from 1
            for date in datesArray {
                if let labelView = self.progressView.viewWithTag(ix) as? UILabel {
                    labelView.text = "\(date)"
                    if ix == 1 || ix == 4 || ix == 7 {
                        labelView.hidden = false
                    }
                }
                ix += 1
            }
        } else {
            var ix = 1
            var iy = 1
            for date in datesArray {
                
                // Assign the dates to the 3 labels
                if iy == 1 || iy == 15 || iy == 30 {
                    
                    // Get the date for the label
                    if let labelView = self.progressView.viewWithTag(ix) as? UILabel {
                        labelView.text = "\(date)"
                        
                        // Show the date label
                        if ix == 1 || ix == 4 || ix == 7 {
                            labelView.hidden = false
                            ix = ix + 3
                        }
                    }
                }
                iy += 1
            }
        }
    }
    
}