//
//  ViewController.h
//  LineChartDemo
//
//  Created by 张冠清 on 2016/12/14.
//  Copyright © 2016年 张冠清. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMYLineChartView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet XMYLineChartView *lineChart;
@property (weak, nonatomic) IBOutlet UITextField *lineNumber;
@property (weak, nonatomic) IBOutlet UITextField *averageValue;
@property (weak, nonatomic) IBOutlet UITextField *maxData;
@property (weak, nonatomic) IBOutlet UITextField *minData;
@property (weak, nonatomic) IBOutlet UITextField *topPadding;
@property (weak, nonatomic) IBOutlet UITextField *bottomPadding;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lineStyle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionY;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
- (IBAction)reload:(id)sender;

@end

