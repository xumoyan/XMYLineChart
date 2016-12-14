//
//  ViewController.m
//  LineChartDemo
//
//  Created by 张冠清 on 2016/12/14.
//  Copyright © 2016年 张冠清. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<lineGraphDelegate,lineGraphDataSource>
///折线点数组
@property (nonatomic, strong) NSMutableArray *linePointArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.linePointArray = [NSMutableArray array];
    self.lineChart.delegate = self;
    self.lineChart.dataSource = self;
    
    self.lineChart.displayTouchReport = YES;
    self.lineChart.displayPopUpView = YES;
    self.lineChart.animationType = XMYLineAnimationDraw;
    self.lineChart.formatStringForValues = @"%.2f";
    self.lineChart.widthReferenceLines = 2.0f;
    self.lineChart.colorReferenceLines = [UIColor whiteColor];
    self.lineChart.colorLinkGraph = [UIColor whiteColor];
    
    self.lineChart.displayReference = YES;
    self.lineChart.displayReferenceXLines = YES;
    self.lineChart.displayLeftReferenceLine = YES;
    self.lineChart.displayBottomReferenceLine = YES;
    self.lineChart.displayReferenceYLines = YES;
    self.lineChart.displayRightReferenceLine = YES;
    self.lineChart.displayTopReferenceLine = YES;
    
    self.lineChart.averageLine.displayAverageLine = YES;
    self.lineChart.averageLine.averageAlpha = 0.6;
    self.lineChart.averageLine.averageLineColor = [UIColor darkGrayColor];
    self.lineChart.averageLine.averageWidth = 2.5;
    self.lineChart.averageLine.averageLinePattern = @[@(2),@(2)];
    
    [self reload:self.reloadButton];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

-(void)randomDatasets{
    [self.linePointArray removeAllObjects];
    CGFloat lineNumber = [self.lineNumber.text intValue];
    if (lineNumber <= 0) {
        lineNumber = 1;
    }
    NSMutableArray *colorArray = [NSMutableArray array];
    for (int i = 0; i < lineNumber; i ++) {
        NSMutableArray *array = [NSMutableArray array];
        for (int j = 0; j < 10; j ++) {
            float number = (float)(arc4random() % 100000) / 100 ;
            [array addObject:@(number)];
        }
        int R = (arc4random() % 256) ;
        int G = (arc4random() % 256) ;
        int B = (arc4random() % 256) ;
        [colorArray addObject:[UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]];
        [self.linePointArray addObject:array];
    }
    self.lineChart.colorLineArray = colorArray;
}

- (IBAction)bezier:(UISegmentedControl *)sender {
    self.lineChart.bezierCurve = sender.selectedSegmentIndex;
    [self.lineChart reloadGraph];
}

- (IBAction)yAxis:(UISegmentedControl *)sender {
    self.lineChart.displayYLabel = YES;
    self.lineChart.displayXLabel = YES;
    self.lineChart.positionYRight = sender.selectedSegmentIndex;
    [self.lineChart reloadGraph];
}

- (IBAction)reload:(id)sender {
    if ([self.maxData.text floatValue] <= 0)
        self.maxData.text = @"1000";
    if ([self.averageValue.text floatValue] <= 0 || [self.averageValue.text floatValue] >= 1000)
        self.averageValue.text = @"500";
    if ([self.lineNumber.text floatValue] <= 0)
        self.lineNumber.text = @"1";
    
    if ([self.lineNumber.text floatValue] == 1) {
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        size_t num_locations = 2;
        CGFloat locations[2] = { 0.0, 1.0 };
        CGFloat components[8] = {
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 0.0
        };
        
        self.lineChart.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    }else{
        self.lineChart.gradientBottom = CGGradientCreateWithColorComponents(nil, nil, nil, 1);
    }
    
    [self randomDatasets];
    [self.lineChart reloadGraph];
}
#pragma mark - lineChart datasource
///折线数量
- (NSInteger)numberOfLineGraph:(XMYLineChartView *)graph{
    if ([self.lineNumber.text integerValue] >= 0)
        return [self.lineNumber.text integerValue];
    else return 1;
}
///折线点数组
- (NSArray *)lineGraph:(XMYLineChartView *)graph valueForPointAtIndex:(NSInteger)index{
    return self.linePointArray[index];
}
///X轴标签展示信息
- (nullable NSString *)lineGraph:(nonnull XMYLineChartView *)graph labelOnXAxisForIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%ld",index];
}

#pragma mark - lineChart delegate
///为了避免X轴标签发生重叠：0标签全部显示，1每隔一个显示...类推，等于点数量的时候显示第一个和最后一个
- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(XMYLineChartView *)graph{
    return 0;
}
///Y轴标签的显示数量
- (NSInteger)numberOfYAxisLabelsOnLineGraph:(XMYLineChartView *)graph{
    return 3;
}

///Y轴标签的前缀
- (NSString *)yAxisPrefixOnLineGraph:(XMYLineChartView *)graph{
    return @"S";
}

///Y轴标签的后缀
- (NSString *)yAxisSuffixOnLineGraph:(XMYLineChartView *)graph{
    return @"S";
}

///计算所有点值的一个平均值
- (NSNumber *)calculatePointValueAverage{
    return [NSNumber numberWithInteger:[self.averageValue.text integerValue]];
}

///设置折线图中Y轴的最大值（如果没有默认数据的最大值）
- (CGFloat)maxValueForLineGraph:(XMYLineChartView *)graph{
    return [self.maxData.text integerValue];
}

///设置折线图中Y轴的最小值（如果没有默认数据的最小值）
- (CGFloat)minValueForLineGraph:(XMYLineChartView *)graph{
    return [self.minData.text integerValue];
}

///折线图上部空出部分大小（最大的一个点距离顶部的距离）
- (CGFloat)staticTopPaddingForLineGraph:(XMYLineChartView *)graph{
    return [self.topPadding.text integerValue];
}

///折线图下部空出部分大小（最小的一个点距离底部的距离）
- (CGFloat)staticBottomPaddingForLineGraph:(XMYLineChartView *)graph{
    return [self.bottomPadding.text integerValue];
}

///弹出框信息的后缀
- (NSArray *)popUpSuffixForlineGraph:(XMYLineChartView *)graph{
    NSMutableArray *suffixArray = [NSMutableArray array];
    for (int i = 0; i < self.linePointArray.count; i ++) {
        [suffixArray addObject:[NSString stringWithFormat:@"suf%d",i]];
    }
    return suffixArray;
}

///弹出框信息的前缀
- (NSArray *)popUpPrefixForlineGraph:(XMYLineChartView *)graph{
    NSMutableArray *prefixArray = [NSMutableArray array];
    for (int i = 0; i < self.linePointArray.count; i ++) {
        [prefixArray addObject:[NSString stringWithFormat:@"pre%d",i]];
    }
    return prefixArray;
}

@end
