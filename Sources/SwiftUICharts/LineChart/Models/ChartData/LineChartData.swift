//
//  LineChartData.swift
//  
//
//  Created by Will Dale on 23/01/2021.
//

import SwiftUI

/**
 Data for drawing and styling a single line, line chart.
 
 This model contains all the data and styling information for a single line, line chart.
 
 # Example
 ```
 static func makeData() -> LineChartData {
     
     let data = LineDataSet(dataPoints: [
         LineChartDataPoint(value: 20,  xAxisLabel: "M", pointLabel: "Monday"),
         LineChartDataPoint(value: 90,  xAxisLabel: "T", pointLabel: "Tuesday"),
         LineChartDataPoint(value: 100, xAxisLabel: "W", pointLabel: "Wednesday"),
         LineChartDataPoint(value: 75,  xAxisLabel: "T", pointLabel: "Thursday"),
         LineChartDataPoint(value: 160, xAxisLabel: "F", pointLabel: "Friday"),
         LineChartDataPoint(value: 110, xAxisLabel: "S", pointLabel: "Saturday"),
         LineChartDataPoint(value: 90,  xAxisLabel: "S", pointLabel: "Sunday")
     ],
     legendTitle: "Data",
     pointStyle : PointStyle(),
     style      : LineStyle())
     
     let metadata = ChartMetadata(title: "Some Data", subtitle: "A Week")
     
     let labels = ["Monday", "Thursday", "Sunday"]
     
     return LineChartData(dataSets      : data,
                          metadata      : metadata,
                          xAxisLabels   : labels,
                          chartStyle    : LineChartStyle(),
                          noDataText    : Text("No Data"))
 }
 
 ```
 
 ---
 
 # Parts
 
 ## LineDataSet
 ```
 LineDataSet(dataPoints: [LineChartDataPoint],
                         legendTitle: String,
                         pointStyle: PointStyle,
                         style: LineStyle)
 ```
 ### LineChartDataPoint
 ```
 LineChartDataPoint(value: Double,
                    xAxisLabel: String?,
                    pointLabel: String?,
                    date: Date?)
 ```
 
 ### PointStyle
 ```
 PointStyle(pointSize: CGFloat,
            borderColour: Color,
            fillColour: Color,
            lineWidth: CGFloat,
            pointType: PointType,
            pointShape: PointShape)
 ```
 
 ### LineStyle
 ```
 LineStyle(colour: Color,
           ...)
 
 LineStyle(colours: [Color],
           startPoint: UnitPoint,
           endPoint: UnitPoint,
           ...)
 
 LineStyle(stops: [GradientStop],
           startPoint: UnitPoint,
           endPoint: UnitPoint,
           ...)
 
 LineStyle(...,
           lineType: LineType,
           strokeStyle: Stroke,
           ignoreZero: Bool)
 ```
 
 ## ChartMetadata
 ```
 ChartMetadata(title: String?, subtitle: String?)
 ```
 
 ## LineChartStyle
 
 ```
 LineChartStyle(infoBoxPlacement        : InfoBoxPlacement,
                infoBoxValueColour      : Color,
                infoBoxDescriptionColor : Color,
                xAxisGridStyle          : GridStyle,
                xAxisLabelPosition      : XAxisLabelPosistion,
                xAxisLabelColour        : Color,
                xAxisLabelsFrom         : LabelsFrom,
                yAxisGridStyle          : GridStyle,
                yAxisLabelPosition      : YAxisLabelPosistion,
                yAxisLabelColour        : Color,
                yAxisNumberOfLabels     : Int,
                baseline                : Baseline,
                globalAnimation         : Animation)
 ```
 
 ### GridStyle
 ```
 GridStyle(numberOfLines: Int,
           lineColour   : Color,
           lineWidth    : CGFloat,
           dash         : [CGFloat],
           dashPhase    : CGFloat)
 ```
 
 ---
 
 # Also See
 - [LineDataSet](x-source-tag://LineDataSet)
    - [LineChartDataPoint](x-source-tag://LineChartDataPoint)
    - [PointStyle](x-source-tag://PointStyle)
        - [PointType](x-source-tag://PointType)
        - [PointShape](x-source-tag://PointShape)
    - [LineStyle](x-source-tag://LineStyle)
        - [ColourType](x-source-tag://ColourType)
        - [LineType](x-source-tag://LineType)
        - [GradientStop](x-source-tag://GradientStop)
 - [ChartMetadata](x-source-tag://ChartMetadata)
 - [LineChartStyle](x-source-tag://LineChartStyle)
    - [InfoBoxPlacement](x-source-tag://InfoBoxPlacement)
    - [GridStyle](x-source-tag://GridStyle)
    - [XAxisLabelPosistion](x-source-tag://XAxisLabelPosistion)
    - [LabelsFrom](x-source-tag://LabelsFrom)
    - [YAxisLabelPosistion](x-source-tag://YAxisLabelPosistion)

 # Conforms to
 - ObservableObject
 - Identifiable
 - LineChartDataProtocol
 - LineAndBarChartData
 - ChartData
 
 - Tag: LineChartData
 */
public final class LineChartData: LineChartDataProtocol {
    
    // MARK: - Properties
    public let id   : UUID  = UUID()
    
    @Published public var dataSets      : LineDataSet
    @Published public var metadata      : ChartMetadata
    @Published public var xAxisLabels   : [String]?
    @Published public var chartStyle    : LineChartStyle
    @Published public var legends       : [LegendData]
    @Published public var viewData      : ChartViewData
    @Published public var isFilled      : Bool = false
    @Published public var infoView      : InfoViewData<LineChartDataPoint> = InfoViewData()
    
    public var noDataText   : Text
    public var chartType    : (chartType: ChartType, dataSetType: DataSetType)
    
    // MARK: - Initializers
    /// Initialises a Single Line Chart.
    ///
    /// - Parameters:
    ///   - dataSets: Data to draw and style a line.
    ///   - metadata: Data model containing the charts Title, Subtitle and the Title for Legend.
    ///   - xAxisLabels: Labels for the X axis instead of the labels in the data points.
    ///   - chartStyle: The style data for the aesthetic of the chart.
    ///   - noDataText: Customisable Text to display when where is not enough data to draw the chart.
    public init(dataSets    : LineDataSet,
                metadata    : ChartMetadata     = ChartMetadata(),
                xAxisLabels : [String]?         = nil,
                chartStyle  : LineChartStyle    = LineChartStyle(),
                noDataText  : Text              = Text("No Data")
    ) {
        self.dataSets       = dataSets
        self.metadata       = metadata
        self.xAxisLabels    = xAxisLabels
        self.chartStyle     = chartStyle
        self.noDataText     = noDataText
        self.legends        = [LegendData]()
        self.viewData       = ChartViewData()
        self.chartType      = (chartType: .line, dataSetType: .single)
        self.setupLegends()
    }
    
    // MARK: - Labels
    public func getXAxisLabels() -> some View {
        Group {
            switch self.chartStyle.xAxisLabelsFrom {
            case .dataPoint:
                
                HStack(spacing: 0) {
                    ForEach(dataSets.dataPoints) { data in
                        if let label = data.xAxisLabel {
                            Text(label)
                                .font(.caption)
                                .foregroundColor(self.chartStyle.xAxisLabelColour)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        if data != self.dataSets.dataPoints[self.dataSets.dataPoints.count - 1] {
                            Spacer()
                                .frame(minWidth: 0, maxWidth: 500)
                        }
                    }
                }
                .padding(.horizontal, -4)
                
                
            case .chartData:
                if let labelArray = self.xAxisLabels {
                    HStack(spacing: 0) {
                        ForEach(labelArray, id: \.self) { data in
                            Text(data)
                                .font(.caption)
                                .foregroundColor(self.chartStyle.xAxisLabelColour)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            if data != labelArray[labelArray.count - 1] {
                                Spacer()
                                    .frame(minWidth: 0, maxWidth: 500)
                            }
                        }
                    }
                    .padding(.horizontal, -4)
                }
            }
        }
    }
    
    public func getYLabels() -> [Double] {
        var labels      : [Double]  = [Double]()
        let dataRange   : Double = self.getRange()
        let minValue    : Double = self.getMinValue()
        let range       : Double = dataRange / Double(self.chartStyle.yAxisNumberOfLabels)

        labels.append(minValue)
        for index in 1...self.chartStyle.yAxisNumberOfLabels {
            labels.append(minValue + range * Double(index))
        }
        return labels
    }
    
    // MARK: - Touch
    public func getDataPoint(touchLocation: CGPoint, chartSize: GeometryProxy) -> [LineChartDataPoint] {
        var points      : [LineChartDataPoint] = []
        let xSection    : CGFloat = chartSize.size.width / CGFloat(dataSets.dataPoints.count - 1)
        let index       = Int((touchLocation.x + (xSection / 2)) / xSection)
        if index >= 0 && index < dataSets.dataPoints.count {
            points.append(dataSets.dataPoints[index])
        }
        return points
    }

    public func getPointLocation(touchLocation: CGPoint, chartSize: GeometryProxy) -> [HashablePoint] {
        var locations : [HashablePoint] = []
        
        let minValue : Double = self.getMinValue()
        let range    : Double = self.getRange()
            
        let ySection : CGFloat = chartSize.size.height / CGFloat(range)
        let xSection : CGFloat = chartSize.size.width / CGFloat(dataSets.dataPoints.count - 1)
        
        let index    : Int     = Int((touchLocation.x + (xSection / 2)) / xSection)
        if index >= 0 && index < dataSets.dataPoints.count {
            locations.append(HashablePoint(x: CGFloat(index) * xSection,
                                           y: (CGFloat(dataSets.dataPoints[index].value - minValue) * -ySection) + chartSize.size.height))
        }
        return locations
    }
    
    public func touchInteraction(touchLocation: CGPoint, chartSize: GeometryProxy) -> some View {
        let position = self.getIndicatorLocation(rect: chartSize.frame(in: .global),
                                                 dataSet: dataSets,
                                                 touchLocation: touchLocation)
        return ZStack {
        switch self.chartStyle.markerType  {
        case .vertical:
            Vertical(position: position)
                .stroke(Color.primary, lineWidth: 2)
        case .rectangle:
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .fill(Color.clear)
                .frame(width: 100, height: chartSize.frame(in: .local).height)
                .position(x: position.x,
                          y: chartSize.frame(in: .local).midY)
                .overlay(
                    RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .stroke(Color.primary, lineWidth: 2)
                        .shadow(color: .primary, radius: 4, x: 0, y: 0)
                        .frame(width: 50, height: chartSize.frame(in: .local).height)
                        .position(x: position.x,
                                  y: chartSize.frame(in: .local).midY)
                )
        case .full:
            MarkerFull(position: position)
                .stroke(Color.primary, lineWidth: 2)
        case .bottomLeading:
            MarkerBottomLeading(position: position)
                .stroke(Color.primary, lineWidth: 2)
        case .bottomTrailing:
            MarkerBottomTrailing(position: position)
                .stroke(Color.primary, lineWidth: 2)
        case .topLeading:
            MarkerTopLeading(position: position)
                .stroke(Color.primary, lineWidth: 2)
        case .topTrailing:
            MarkerTopTrailing(position: position)
                .stroke(Color.primary, lineWidth: 2)
        }
        
        PosistionIndicator()
            .frame(width: 15, height: 15)
            .position(position)
        }
    }
    
    // MARK: - Legends
    public func setupLegends() {
        
        if dataSets.style.colourType == .colour,
           let colour = dataSets.style.colour
        {
            self.legends.append(LegendData(id         : dataSets.id,
                                           legend     : dataSets.legendTitle,
                                           colour     : colour,
                                           strokeStyle: dataSets.style.strokeStyle,
                                           prioity    : 1,
                                           chartType  : .line))

        } else if dataSets.style.colourType == .gradientColour,
                  let colours = dataSets.style.colours
        {
            self.legends.append(LegendData(id         : dataSets.id,
                                           legend     : dataSets.legendTitle,
                                           colours    : colours,
                                           startPoint : .leading,
                                           endPoint   : .trailing,
                                           strokeStyle: dataSets.style.strokeStyle,
                                           prioity    : 1,
                                           chartType  : .line))

        } else if dataSets.style.colourType == .gradientStops,
                  let stops = dataSets.style.stops
        {
            self.legends.append(LegendData(id         : dataSets.id,
                                           legend     : dataSets.legendTitle,
                                           stops      : stops,
                                           startPoint : .leading,
                                           endPoint   : .trailing,
                                           strokeStyle: dataSets.style.strokeStyle,
                                           prioity    : 1,
                                           chartType  : .line))
        }
    }
    
    // MARK: - Data Functions
    public func getRange() -> Double {
        switch self.chartStyle.baseline {
        case .minimumValue:
            return DataFunctions.dataSetRange(from: dataSets)
        case .minimumWithMaximum(of: let value):
            return DataFunctions.dataSetMaxValue(from: dataSets) - min(DataFunctions.dataSetMinValue(from: dataSets), value)
        case .zero:
            return DataFunctions.dataSetMaxValue(from: dataSets)
        }
    }
    public func getMinValue() -> Double {
        switch self.chartStyle.baseline {
        case .minimumValue:
            return DataFunctions.dataSetMinValue(from: dataSets)
        case .minimumWithMaximum(of: let value):
            return min(DataFunctions.dataSetMinValue(from: dataSets), value)
        case .zero:
            return 0
        }
    }
    
    public typealias Set       = LineDataSet
    public typealias DataPoint = LineChartDataPoint
}
