//
//  StartViewController.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 7/11/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    // MARK: - Outlets
    
    // Images
    @IBOutlet weak var writeImage: UIImageView!
    @IBOutlet weak var monitorImage: UIImageView!
    @IBOutlet weak var historyImage: UIImageView!
    @IBOutlet weak var preferencesImage: UIImageView!
    
    // Buttons
    @IBOutlet weak var writeButton: UIButton!
    @IBOutlet weak var monitorButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var preferencesButton: UIButton!

    // Labels
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var banner: UILabel!
    @IBOutlet weak var writeHookText: UILabel!
    @IBOutlet weak var monitorHookLabel: UILabel!
    @IBOutlet weak var historyHookLabel: UILabel!
    @IBOutlet weak var preferencesHookLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }

    // MARK: - Actions
    
    @IBAction func write(sender: UIButton) {
        Theme.segueToTabBarController(self, tabItemIndex: Constants.textTab)
    }
    
    @IBAction func monitor(sender: UIButton) {
        Theme.segueToTabBarController(self, tabItemIndex: Constants.monitorTab)
    }
    
    @IBAction func history(sender: UIButton) {
        Theme.segueToTabBarController(self, tabItemIndex: Constants.historyTab)
    }
    
    @IBAction func preferences(sender: UIButton) {
        Theme.segueToTabBarController(self, tabItemIndex: Constants.preferencesTab)
    }
    
    // MARK: - Configuration
    
    func configure() {
        self.configureImages()
        self.configureTopLabels()
        self.configureButtonLabels()
        self.configureHookLabels()
    }
    
    /// Do not display the start images in devices smaller that iPhone5
    func configureImages() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if screenSize.height < Constants.iPhone5ScreenHeight {
            self.writeImage.hidden = true
            self.monitorImage.hidden = true
            self.historyImage.hidden = true
            self.preferencesImage.hidden = true
        }
    }
    
    func configureTopLabels() {
        self.topLabel.backgroundColor = Theme.htGreen
        self.banner.backgroundColor = Theme.htGreen
    }
    
    func configureButtonLabels() {
        self.writeButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.monitorButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.historyButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.preferencesButton.titleLabel!.adjustsFontSizeToFitWidth = true
    }
    
    func configureHookLabels() {
        Theme.configureHookLabels(self.writeHookText)
        Theme.configureHookLabels(self.monitorHookLabel)
        Theme.configureHookLabels(self.historyHookLabel)
        Theme.configureHookLabels(self.preferencesHookLabel)
    }
}
