//
//  ViewController.swift
//  flowerchart
//
//  Created by drinkius on 21/03/16.
//  Copyright © 2016 Alexander Telegin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var flowerChart: FlowerChart!
    
    @IBOutlet weak var petalCanvas: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.darkGray
        
        let flowerChart = FlowerChart(
            petalCanvas: petalCanvas,
            data: [8.6, 0.0, 4.1, 0.0, 9.2, 0.0, 6.0, 0.0, 9.5, 0.0, 7.3, 0.0],
            labels: ["Title 1", "", "Title 2", "", "Title 3", "", "Title 4", "", "Title 5", "", "Title 6", ""]
        )
        self.flowerChart = flowerChart
        self.flowerChart.delegate = self
        flowerChart.drawFlower()
    }
}

extension ViewController: FlowerChartDelegate {
    func flowerChartTapped(index: Int) {
        print(index)
    }
}

