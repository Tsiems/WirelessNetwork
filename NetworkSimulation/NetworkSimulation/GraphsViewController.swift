//
//  GraphsViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 4/2/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//
import Charts
//#import "BarChartViewController.h"
import UIKit


class GraphsViewController: UIViewController {

    @IBOutlet var barChartView: BarChartView!
    
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    var chartTitle = ""
    var input_data:[Double] = []
    var chartDataLabel = ""
    var chartDescription = ""
//    var months:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView?.noDataText = "UH OH! No Data!"
        barChartView.setNeedsDisplay()
        
//        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        setChart(dataPoints: input_data, values: input_data, label:chartDataLabel, description:chartDescription)
        chartTitleLabel.text = chartTitle
        
        
//        var entries:[ChartDataEntry] = []
//
//        var data = BarChartData.
//        
//        var dataSet = BarChartDataSet(values: entries, label: "THE TEST")
//
//        (self.view as! BarChartView). = BarChartData(dataSet)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setChart(dataPoints: [Double], values: [Double],label:String,description:String) {
        var dataEntries: [BarChartDataEntry] = []
        
//        let formato:BarChartFormatter = BarChartFormatter()
//    let xaxis:XAxis = XAxis()
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]),data:dataPoints[i] as AnyObject)
//            let dataEntry = BarChartDataEntry(x: Double(i),y:Double(i), data: values[i] as AnyObject)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
        barChartView.data = BarChartData(dataSet: chartDataSet as IChartDataSet)
        
        barChartView.chartDescription?.text = description
        //barChartView.xAxis.valueFormatter valueFormatter
//        barChartView
//        barChartView.noDataText = "You need to provide data for the chart."
//        var dataEntries: [BarChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
//            let dataEntry = BarChartDataEntry(x: Double(i),y:Double(i), data: values[i] as AnyObject)
//            dataEntries.append(dataEntry)
//        }
//        
//        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Units Sold")
//        let chartData = BarChartData(dataSets: IChartDataSet(chartDataSet) )
//        barChartView.data = chartData
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
