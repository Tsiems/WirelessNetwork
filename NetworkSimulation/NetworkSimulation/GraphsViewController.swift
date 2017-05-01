//
//  GraphsViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 4/2/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import Charts
import UIKit

class GraphsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var barChartView: BarChartView!
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    var chartTitle = ""
    var input_data:[Double] = []
    var input_data2:[Double] = []
    var chartDataLabel = ""
    var chartDataLabel2 = ""
    var chartDescription = ""
    var chartType = "Bar"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.title
        
        if chartType == "Bar" {
            barChartView.isHidden = false
            lineChartView.isHidden = true
            
            barChartView?.noDataText = "UH OH! No Data!"
            barChartView.setNeedsDisplay()
            
            
            setChart(values: input_data, label:chartDataLabel, description:chartDescription)
            chartTitleLabel.text = chartTitle
        } else if chartType == "Line" {
            barChartView.isHidden = true
            lineChartView.isHidden = false
            
            lineChartView?.noDataText = "UH OH! No Data!"
            lineChartView.setNeedsDisplay()
            
            
            setLineChart(values1: input_data, values2: input_data2, label1:chartDataLabel, label2:chartDataLabel2, description:chartDescription)
            chartTitleLabel.text = chartTitle

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setChart(values: [Double],label:String,description:String) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]),data:values[i] as AnyObject)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
        barChartView.data = BarChartData(dataSet: chartDataSet as IChartDataSet)
        
        barChartView.chartDescription?.text = description
    }
    
    func setLineChart(values1: [Double], values2: [Double],label1:String,label2:String,description:String) {
        
        var dataEntries1: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        
        for i in 0..<values1.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values1[i])
            dataEntries1.append(dataEntry)
        }
        
        for i in 0..<values2.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values2[i])
            dataEntries2.append(dataEntry)
        }
        
        
        let lineChartDataSet1 = LineChartDataSet(values: dataEntries1, label: label1)
        lineChartDataSet1.drawCirclesEnabled = false
        lineChartDataSet1.setColor(NSUIColor.red, alpha: 1.0)
        let lineChartDataSet2 = LineChartDataSet(values: dataEntries2, label: label2)
        lineChartDataSet2.drawCirclesEnabled = false
        lineChartDataSet2.setColor(NSUIColor.blue, alpha: 1.0)
        
        let lineChartData = LineChartData(dataSets: [lineChartDataSet1,lineChartDataSet2])
        lineChartView.data = lineChartData
        
        lineChartView.chartDescription?.text = description
    }



}
