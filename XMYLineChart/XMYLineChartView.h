//
//  XMYLineChartView.h
//  Refer to the address:https://github.com/Boris-Em/BEMSimpleLineGraph#project-details
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



@import UIKit;
@import Foundation;
@import CoreGraphics;

#import "XMYLine.h"
#import "XMYPopUpView.h"
#import "XMYLinkGraphs.h"
#import "XMYAverageLine.h"

@protocol lineGraphDelegate;
@protocol lineGraphDataSource;
@protocol lineGraphPopoverProtocol;

extern const CGFloat XMYNullGraphValue;
NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE @interface XMYLineChartView : UIView<UIGestureRecognizerDelegate>

///////////////////////////////////
///////////DELEGATE////////////////
///////////////////////////////////

///折线图委托，提供外观的改变、接手触摸事件等
@property (nonatomic, weak, nullable) IBOutlet id <lineGraphDelegate> delegate;

///////////////////////////////////
/////////DATA SOURCE///////////////
///////////////////////////////////

///接收数据源
@property (nonatomic, weak, nullable) IBOutlet id <lineGraphDataSource> dataSource;

///////////////////////////////////
///////////METHODS/////////////////
///////////////////////////////////

///刷新
- (void)reloadGraph;

///截图（对折线图）
- (UIImage *)graphSnapshotImage NS_AVAILABLE_IOS(7_0);

///截图（是否全屏由appIsInBackground控制）
- (UIImage *)graphSnapshotImageRenderedWhileInBackground:(BOOL)appIsInBackground NS_AVAILABLE_IOS(7_0);

///计算所有点值的一个平均值
- (NSNumber *)calculatePointValueAverage;

///计算所有点的值的和
- (NSNumber *)calculatePointValueSum;

///计算所有点值的中位数
- (NSNumber *)calculatePointValueMedian;

///通过模式计算得出平均线值（mode:NSExpression统计的一种）
- (NSNumber *)calculatePointValueMode;

///计算标准差
- (NSNumber *)calculateLineGraphStandardDeviation;

///计算最小的点
- (NSNumber *)calculateMinimumPointValue;

///计算最大的点
- (NSNumber *)calculateMaximumPointValue;

///X轴显示值的数组
- (nullable NSArray *)graphValuesForX;

///折线图点的数组（从左到右）
- (nullable NSArray *)graphValuesForDataPoints;

///Y轴显示值的数组
- (nullable NSArray *)graphLabelsForX;

///////////////////////////////////
/////////PROPERTIES////////////////
///////////////////////////////////

///XY轴标签字体的大小
@property (strong, nonatomic, nullable) UIFont *labelFont;

///动画时长
@property (nonatomic, assign) CGFloat animationTime;

///动画类型
@property (nonatomic, assign) XMYLineAnimation animationType;

///是否显示离触摸点最近的点
@property (nonatomic, assign) BOOL displayTouchReport;

///触摸手指的数量
@property (nonatomic, assign) NSInteger touchFingersNumber;

///是否展示弹出框（展示当前点值）
@property (nonatomic, assign) BOOL displayPopUpView;

///是否以贝塞尔曲线的方式展现
@property (nonatomic, assign) IBInspectable BOOL bezierCurve;

///是否展示Y轴标签值
@property (nonatomic, assign) IBInspectable BOOL displayYLabel;

///是否展示X轴标签值
@property (nonatomic, assign) IBInspectable BOOL displayXLabel;

///存在负值的时候是否自调整（默认自动调整），如果不进行调整可能会出现一些错误
@property (nonatomic, assign) BOOL autoScaleY;

///平均线
@property (nonatomic, strong) XMYAverageLine *averageLine;

///是否展示X轴参考线
@property (nonatomic, assign) BOOL displayReferenceXLines;

///是否展示Y轴参考线
@property (nonatomic, assign) BOOL displayReferenceYLines;

///是否展示参考线
@property (nonatomic, assign) BOOL displayReference;

///是否展示左侧参考线
@property (nonatomic, assign) BOOL displayLeftReferenceLine;

///是否展示底部参考线
@property (nonatomic, assign) BOOL displayBottomReferenceLine;

///是否展示右侧参考线
@property (nonatomic, assign) BOOL displayRightReferenceLine;

///是否展示上部参考线
@property (nonatomic, assign) BOOL displayTopReferenceLine;

///连接处图形是否一直展现
@property (nonatomic, assign) BOOL alwaysDisplayDots;

///连接处图形是否随着动画展现
@property (nonatomic, assign) BOOL displayDotsWhileAnimating;

///弹出label是否总是展示
@property (nonatomic, assign) BOOL alwaysDisplayPopUpLabels;

///折线底部颜色
@property (nonatomic, strong) IBInspectable UIColor *colorBottom;

///折线底部透明度
@property (nonatomic, assign) IBInspectable CGFloat alphaBottom;

///折线底部渐变
@property (nonatomic, assign) CGGradientRef gradientBottom;

///折线上部颜色
@property (nonatomic, strong) IBInspectable UIColor *colorTop;

///折线上部透明度
@property (nonatomic, assign) IBInspectable CGFloat alphaTop;

///折线上部渐变
@property (nonatomic, assign) CGGradientRef gradientTop;

///折线颜色
@property (nonatomic, strong) IBInspectable UIColor *colorLine;

///折线颜色数组，优先级大于colorLine，参考线颜色默认数组第一个。数组count值必须与折线数量相等！
@property (nonatomic, strong) NSArray *colorLineArray;

///折线渐变
@property (nonatomic, assign) CGGradientRef gradientLine;

///折线渐变方向
@property (nonatomic, assign) XMYLineGradientDirection gradientLineDirection;

///折线透明度
@property (nonatomic, assign) IBInspectable CGFloat alphaLine;

///折线宽度
@property (nonatomic, assign) IBInspectable CGFloat widthLine;

///参考线的宽度默认是折线宽度的1/2
@property (nonatomic, assign) IBInspectable CGFloat widthReferenceLines;

///参考线的颜色
@property (nonatomic, strong) UIColor *colorReferenceLines;

///连接图形的大小默认10
@property (nonatomic, assign) IBInspectable CGFloat sizeLinkGraph;

///连接图形的颜色默认白色0.7透明度
@property (nonatomic, strong) IBInspectable UIColor *colorLinkGraph;

///触摸辅助线的颜色
@property (nonatomic, strong) UIColor *colorTouchInputLine;

///触摸辅助线的透明度
@property (nonatomic, assign) CGFloat alphaTouchInputLine;

///触摸辅助线的宽度
@property (nonatomic, assign) CGFloat widthTouchInputLine;

///X轴标签的字体颜色
@property (nonatomic, strong) IBInspectable UIColor *colorXLabel;

///X轴标签的背景色
@property (nonatomic, strong, nullable) UIColor *colorBackgroundX;

///X轴索背景颜色的透明度
@property (nonatomic, assign) CGFloat alphaBackgroundX;

///Y轴标签的背景颜色
@property (nonatomic, strong, nullable) UIColor *colorBackgroundY;

///Y轴标签背景颜色的透明度
@property (nonatomic, assign) CGFloat alphaBackgroundYaxis;

///Y轴标签的字体颜色
@property (nonatomic, strong) IBInspectable UIColor *colorYLabel;

///弹出信息框的背景颜色
@property (nonatomic, strong) UIColor *colorBackgroundPopUplabel;

///Y轴是否放在是右侧
@property (nonatomic, assign) BOOL positionYRight;

///X轴参考线的虚线数组
@property (nonatomic, strong) NSArray *linePatternForReferenceXLines;

///Y轴参考线的虚线数组
@property (nonatomic, strong) NSArray *linePatternForReferenceYLines;

///没有数据时文字的颜色
@property (nonatomic, strong) UIColor *noDataLabelColor;

///没有数据时文字的大小
@property (nonatomic, strong) UIFont *noDataLabelFont;

///展示数据到小数点后几位
@property (nonatomic, strong) NSString *formatStringForValues;

///当出现控制的时候是否插入一个辅助值
@property (nonatomic, assign) BOOL interpolateNullValues;

///动画时是否只显示连接图形
@property (nonatomic) BOOL displayDotsOnly;

@end

@interface PopoverGraphView : UIView

@end

@protocol lineGraphDataSource <NSObject>
@required

///折线代理的数量
- (NSInteger)numberOfLineGraph:(XMYLineChartView *)graph;

///折线点对应值（从左到右）
- (NSArray *)lineGraph:(XMYLineChartView *)graph valueForPointAtIndex:(NSInteger)index;

@optional

///X轴标签值
- (nullable NSString *)lineGraph:(nonnull XMYLineChartView *)graph labelOnXAxisForIndex:(NSInteger)index;

@end

@protocol lineGraphDelegate <NSObject>
@optional

///开始加载折线图形
- (void)lineGraphDidBeginLoading:(XMYLineChartView *)graph;

///加载图形和数据但图像可能还未完全加载出来
- (void)lineGraphDidFinishLoading:(XMYLineChartView *)graph;

///折线图的绘画和动画都已经加载完成，图像完全展示出来
- (void)lineGraphDidFinishDrawing:(XMYLineChartView *)graph;

///////////////////////////////////
/////////CUSTOMIZATION/////////////
///////////////////////////////////

///弹出框信息的后缀
- (NSArray *)popUpSuffixForlineGraph:(XMYLineChartView *)graph;

///弹出框信息的前缀
- (NSArray *)popUpPrefixForlineGraph:(XMYLineChartView *)graph;

///alwaysDisplayPopUpLabels为YES的时候，根据index展示弹出框
- (BOOL)lineGraph:(XMYLineChartView *)graph alwaysDisplayPopUpAtIndex:(CGFloat)index;

///设置折线图中Y轴的最大值（如果没有默认数据的最大值）
- (CGFloat)maxValueForLineGraph:(XMYLineChartView *)graph;

///设置折线图中Y轴的最小值（如果没有默认数据的最小值）
- (CGFloat)minValueForLineGraph:(XMYLineChartView *)graph;

///没有数据时是否展示“No Data”
- (BOOL)noDataLabelEnableForLineGraph:(XMYLineChartView *)graph;

///没有数据时展示自定义字符串
- (NSString *)noDataLabelTextForLineGraph:(XMYLineChartView *)graph;

///折线图上部空出部分大小（最大的一个点距离顶部的距离）
- (CGFloat)staticTopPaddingForLineGraph:(XMYLineChartView *)graph;

///折线图下部空出部分大小（最小的一个点距离底部的距离）
- (CGFloat)staticBottomPaddingForLineGraph:(XMYLineChartView *)graph;

///自定义一个信息弹出框（前提：displayPopUpView=YES，alwaysDisplayPopUpLabels=NO）
- (UIView *)popUpViewForLineGraph:(XMYLineChartView *)graph;

///对自定义的信息弹出框根据index做不同的处理
- (void)lineGraph:(XMYLineChartView *)graph modifyPopupView:(UIView *)popupView forIndex:(NSUInteger)index;

///////////////////////////////////
//////////TOUCH EVENTS/////////////
///////////////////////////////////

///用户触摸开始（displayTouchReport=YES）
- (void)lineGraph:(XMYLineChartView *)graph didTouchGraphWithClosestIndex:(NSInteger)index;

///用户触摸结束（displayTouchReport=YES）
- (void)lineGraph:(XMYLineChartView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index;

///////////////////////////////////
////////////X AXIS/////////////////
///////////////////////////////////

///为了避免X轴标签发生重叠：0标签全部显示，1每隔一个显示...类推，等于点数量的时候显示第一个和最后一个
- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(XMYLineChartView *)graph;

///自定义X轴标签从第几个位置开始
- (NSInteger)baseIndexForXAxisOnLineGraph:(XMYLineChartView *)graph;

///在baseIndexForXAxisOnLineGraph实现的情况下，两个点之间隔了多少个点
- (NSInteger)incrementIndexForXAxisOnLineGraph:(XMYLineChartView *)graph;

///定制化X轴标签显示的数组实现这个方法以后numberOfGapsBetweenLabelsOnLineGraph将没有意义
- (NSArray *)incrementPositionsForXAxisOnLineGraph:(XMYLineChartView *)graph;

///////////////////////////////////
////////////Y AXIS/////////////////
///////////////////////////////////

///Y轴标签的显示数量
- (NSInteger)numberOfYAxisLabelsOnLineGraph:(XMYLineChartView *)graph;

///Y轴标签的前缀
- (NSString *)yAxisPrefixOnLineGraph:(XMYLineChartView *)graph;

///Y轴标签的后缀
- (NSString *)yAxisSuffixOnLineGraph:(XMYLineChartView *)graph;

///自定义Y轴标签从第几个位置开始
- (CGFloat)baseValueForYAxisOnLineGraph:(XMYLineChartView *)graph;

///在baseIndexForXAxisOnLineGraph实现的情况下，两个点之间隔了多少个点
- (CGFloat)incrementValueForYAxisOnLineGraph:(XMYLineChartView *)graph;

NS_ASSUME_NONNULL_END

@end
