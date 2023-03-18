//
//  ChartCollectionViewCell.swift
//  SmokeApp
//
//  Created by Лев Куликов on 14.02.2023.
//

import UIKit
import Charts

/// Types of action to interacte with chart button
enum ChartButtonActionType: CaseIterable {
    /// Case when chart is opened
    case open
    /// Case when chart is being cloesed
    case close
}

/// Protocl to conform ChartCollectionViewCell delegate
protocol ChartCollectionViewCellDelegate: AnyObject {
    /// Called when user presses reset button
    func resizeChartButtonDidPress(withAction action: ChartButtonActionType)
}

/// Cell to display timeline chart with ability to set start and end days
final class ChartCollectionViewCell: UICollectionViewCell {
    //MARK: Properties
    static let identifier = "ChartCollectionViewCell"
    
    /// Chart Cell delegate
    public weak var delegate: ChartCollectionViewCellDelegate?
    
    /// Data for chart to display
    private var chartsData: [SmokeItem] = [] {
        didSet {
            setDataToChart(chartsData)
        }
    }
    
    /// LineChart to display timeline statistics about smokes
    private lazy var lineChart: LineChartView = {
        let lineChart = LineChartView()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.isUserInteractionEnabled = false
        
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.axisLineWidth = 3
        lineChart.xAxis.drawLabelsEnabled = false
        
        lineChart.leftAxis.drawGridLinesEnabled = true
        lineChart.leftAxis.labelFont = .systemFont(ofSize: 15)
        lineChart.leftAxis.labelPosition = .outsideChart
        lineChart.leftAxis.axisLineWidth = 3
        lineChart.leftAxis.axisMinimum = 0
        
        lineChart.rightAxis.enabled = false
        lineChart.legend.enabled = false
        
        return lineChart
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "All times smokes chart"
        return label
    }()
    
    private lazy var chartActionButton: UIButton = {
        var buttonConfig = UIButton.Configuration.bordered()
        buttonConfig.image = UIImage(systemName: "lightswitch.off")
        buttonConfig.cornerStyle = .large
        
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(chartButtonPressed), for: .touchUpInside)
        button.tintColor = .systemGray
        
        return button
    }()
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.shared.statisticsCellCornerRadius
        backgroundColor = Constants.shared.cellBackgroundColor
        contentView.addSubviews(titleLabel, lineChart, chartActionButton)
        contentView.bringSubviewToFront(chartActionButton)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        print("ChartCollectionViewCell init?(coder:) is unsupported")
        return nil
    }
    
    //MARK: Lyfe Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraints()
    }
    
    //MARK: Methods
    /// Sets constraints to all UI elements
    private func setConstraints() {
        //Set titleLabel constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10)
        ])
        
        //Set chartActionButton constraints
        NSLayoutConstraint.activate([
            chartActionButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            chartActionButton.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            chartActionButton.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 2),
            chartActionButton.widthAnchor.constraint(equalTo: chartActionButton.heightAnchor)
        ])
        
        //Set lineChart constraints
        NSLayoutConstraint.activate([
            lineChart.topAnchor.constraint(equalTo: chartActionButton.bottomAnchor, constant: 5),
            lineChart.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            lineChart.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            lineChart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5)
        ])
    }
    
    /// Appropriatly sets data to the chart
    /// - Parameter data: Data which is needed to set
    private func setDataToChart(_ data: [SmokeItem]) {
        var dataEntry = [ChartDataEntry]()
        var xIndex: Double = 1
        for item in data {
            dataEntry.append(ChartDataEntry(x: xIndex, y: Double(item.amount), data: item))
            xIndex += 1
        }

        let chartSet = LineChartDataSet(entries: dataEntry, label: "Smokes amount")
        chartSet.mode = .horizontalBezier
        chartSet.setColor(NSUIColor(cgColor: UIColor.systemBlue.cgColor))
        chartSet.fillColor = NSUIColor(cgColor: UIColor.systemBlue.cgColor)
        chartSet.drawFilledEnabled = true
        chartSet.lineWidth = 4
        chartSet.drawCirclesEnabled = false
        chartSet.drawValuesEnabled = false
        chartSet.highlightLineWidth = 2
        chartSet.highlightColor = NSUIColor(cgColor: UIColor.systemGray3.cgColor)

        let dataToDisplay = LineChartData(dataSet: chartSet)
        lineChart.data = dataToDisplay
    }
    
    @objc private func chartButtonPressed() {
        if lineChart.isUserInteractionEnabled {
            lineChart.isUserInteractionEnabled = false
            lineChart.highlightValue(nil)
            lineChart.zoomAndCenterViewAnimated(scaleX: 1, scaleY: 1, xValue: lineChart.chartXMax, yValue: lineChart.chartYMax/2, axis: .right, duration: 1)
            chartActionButton.setImage(
                UIImage(systemName: "lightswitch.off"),
                for: .normal
            )
            chartActionButton.tintColor = .systemGray
            delegate?.resizeChartButtonDidPress(withAction: .close)
        } else {
            lineChart.isUserInteractionEnabled = true
            chartActionButton.setImage(
                UIImage(systemName: "lightswitch.on"),
                for: .normal
            )
            chartActionButton.tintColor = .systemBlue
            delegate?.resizeChartButtonDidPress(withAction: .open)
        }
    }
    
    /// Configures cell information to display
    /// - Parameter chartsData: data to show in the cell chart
    public func configureCell(chartsData: [SmokeItem]) {
        self.chartsData = chartsData
    }
}
