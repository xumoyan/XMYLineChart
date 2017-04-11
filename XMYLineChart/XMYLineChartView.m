//
//  XMYLineChartView.m
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

#import "XMYLineChartView.h"

const CGFloat XMYNullGraphValue = CGFLOAT_MAX;

#if !__has_feature(objc_arc)
#error BEMSimpleLineGraph is built with Objective-C ARC. You must enable ARC for these files.
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define DEFAULT_FONT_NAME @"HelveticaNeue-Light"

typedef NS_ENUM(NSInteger, XMYInternalTags)
{
    DotFirstTag100 = 100,
    DotLastTag1000 = 1000,
    LabelYAxisTag2000 = 2000,
    BackgroundYAxisTag2100 = 2100,
    BackgroundXAxisTag2200 = 2200,
    PermanentPopUpViewTag3100 = 3100,
};

@interface XMYLineChartView()
{
    ///折线点的数量
    NSInteger numberOfLines;
    ///每条折线点的数量
    NSInteger numberOfPoints;
    ///所有点的数组
    NSMutableArray *sumPointData;
    ///距离触摸点最近的连接图
    NSMutableArray *closestGraph;
    ///距离触摸点最近的连接图的位置
    CGFloat currentlyCloser;
    ///X轴上所有标签的值
    NSMutableArray *xValues;
    ///X轴上所有标签横坐标
    NSMutableArray *xLabelPoints;
    ///X轴标签横坐标的偏移量
    CGFloat xHorizontalFringeValue;
    ///Y轴上所有标签纵坐标
    NSMutableArray *yLabelPoints;
    ///Y轴上所有标签的偏移量
    NSMutableArray *yValues;
    ///折线上所有的点
    NSMutableArray *dataPoints;
    ///X轴上所有的标签
    NSMutableArray *xLabels;
}
///////////////////////////////////
////////////PROPERTY///////////////
///////////////////////////////////

///用户触摸展示出来的辅助线
@property (nonatomic, strong) UIView *touchLine;
///跟踪用户左右平移手势展示的线
@property (nonatomic, strong, readwrite) UIView *panView;
///没有数据展示的label
@property (nonatomic, strong) UILabel *noDataLabel;
///用户的点击手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
///用户的长按手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
///信息弹出框里的label
@property (nonatomic, strong) UILabel *popUpLabel;
///信息弹出框
@property (nonatomic, strong) UIView *popUpView;
///信息弹出框的x坐标（中心）
@property (nonatomic, assign) CGFloat xCenterLabel;
///信息弹出框的y坐标（中心）
@property (nonatomic, assign) CGFloat yCenterLabel;
///标签在X轴的偏移量
@property (nonatomic, assign) CGFloat xLabelYOffset;
///标签在Y轴的偏移量
@property (nonatomic, assign) CGFloat yLabelXOffset;
///所有数据点的最大值
@property (nonatomic, assign) CGFloat maxValue;
///所有数据点的最小值
@property (nonatomic, assign) CGFloat minValue;
///是否使用自定义的信息弹出框
@property (nonatomic, assign) BOOL usingCustomPopupView;
///当前视图的大小存储在layoutSubviews中，用来检测是否需要重绘
@property (nonatomic, assign) CGSize currentViewSize;
///x轴标签的背景
@property (nonatomic, strong) UIView *backgroundX;

///////////////////////////////////
//////////////METHOD///////////////
///////////////////////////////////

///发现距离触摸点最近的连接图
- (NSArray *)closestDotFromtouchLine:(UIView *)touchLine;
///计算所有点的最大值
- (CGFloat)maxValue;
///计算所有点的最小值
- (CGFloat)minValue;

@end

@implementation XMYLineChartView

#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) [self commonInit];
    return self;
}

- (void)commonInit {
    //字体
    _labelFont = [UIFont fontWithName:DEFAULT_FONT_NAME size:13];
    //动画
    _animationTime = 1.5;
    //默认颜色
    _colorXLabel = [UIColor blackColor];
    _colorYLabel = [UIColor blackColor];
    _colorTop = [UIColor colorWithRed:0 green:122.0/255.0 blue:255/255 alpha:1];
    _colorLine = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    _colorBottom = [UIColor colorWithRed:0 green:122.0/255.0 blue:255/255 alpha:1];
    _colorLinkGraph = [UIColor colorWithWhite:1.0 alpha:0.7];
    _colorTouchInputLine = [UIColor grayColor];
    _colorBackgroundPopUpLabel = [UIColor whiteColor];
    _alphaTouchInputLine = 0.2;
    _widthTouchInputLine = 1.0;
    _colorBackgroundX = nil;
    _alphaBackgroundX = 1.0;
    _colorBackgroundY = nil;
    _alphaBackgroundYaxis = 1.0;
    _displayDotsWhileAnimating = YES;
    //默认透明度
    _alphaTop = 1.0;
    _alphaBottom = 1.0;
    _alphaLine = 1.0;
    //默认宽度
    _widthLine = 1.0;
    _widthReferenceLines = 1.0;
    _sizeLinkGraph = 10.0;
    //默认功能开关
    _displayTouchReport = NO;
    _touchFingersNumber = 1;
    _displayPopUpView = NO;
    _bezierCurve = NO;
    _displayXLabel = YES;
    _displayYLabel = NO;
    _yLabelXOffset = 0;
    _autoScaleY = YES;
    _alwaysDisplayDots = NO;
    _alwaysDisplayPopUpLabels = NO;
    _displayLeftReferenceLine = YES;
    _displayBottomReferenceLine = YES;
    _formatStringForValues = @"%.0f";
    _interpolateNullValues = YES;
    _displayDotsOnly = NO;
    //初始化
    xValues = [NSMutableArray array];
    xHorizontalFringeValue = 0.0;
    xLabelPoints = [NSMutableArray array];
    yLabelPoints = [NSMutableArray array];
    dataPoints = [NSMutableArray array];
    xLabels = [NSMutableArray array];
    yValues = [NSMutableArray array];
    _averageLine = [[XMYAverageLine alloc] init];
    sumPointData = [NSMutableArray array];
    closestGraph = [NSMutableArray array];
}

-(void)prepareForInterfaceBuilder{
    //在xib准备界面构建器的时候删除之前的点、重新设置点的数量
    numberOfPoints = 10;
    for (UILabel *subview in [self subviews]) {
        if ([subview isEqual:self.noDataLabel])
            [subview removeFromSuperview];
    }
    [self drawEntireGraph];
}

-(void)drawGraph{
    //告知开始加载折线图
    if ([self.delegate respondsToSelector:@selector(lineGraphDidBeginLoading:)])
        [self.delegate lineGraphDidBeginLoading:self];
    [self layoutnumberOfLines];
    
    if (numberOfLines < 1) {
        return;
    }else if (dataPoints.count == 0){
        return;
    }else {
        //绘图
        [self drawEntireGraph];
        //添加触摸手势
        [self layoutTouchReport];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(self.currentViewSize, self.bounds.size))  return;
    self.currentViewSize = self.bounds.size;
    
    [self drawGraph];
}

- (void)layoutnumberOfLines{
    
    //删除所有的数据点
    [dataPoints removeAllObjects];
    
    //删除所有的点
    [sumPointData removeAllObjects];
    
    //删除所有Y轴标签的值
    [yValues removeAllObjects];
    
    //获取真实点的数量
    if ([self.dataSource respondsToSelector:@selector(numberOfLineGraph:)]) {
        numberOfLines = [self.dataSource numberOfLineGraph:self];
    } else numberOfLines = 0;
    
    if (numberOfLines > 0) {
        for (int i = 0; i < numberOfLines; i ++ ) {
            if ([self.dataSource respondsToSelector:@selector(lineGraph:valueForPointAtIndex:)]) {
                NSArray *pointsArray = [self.dataSource lineGraph:self valueForPointAtIndex:i];
                if (pointsArray.count != 0) {
                    numberOfPoints = pointsArray.count;
                    [dataPoints addObject:pointsArray];
                    for (NSString *points in pointsArray) {
                        CGFloat point = [points doubleValue];
                        [sumPointData addObject:@(point)];
                    }
                }
            }
        }
    }
    
    //没有折线点的时候的处理
    if (numberOfLines == 0 || dataPoints.count == 0) {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(noDataLabelEnableForLineGraph:)] &&
            ![self.delegate noDataLabelEnableForLineGraph:self]) return;
        
        NSLog(@"[XMYLineChartView] 数据源中不包含任何数据。");
#if !TARGET_INTERFACE_BUILDER
        self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewForBaselineLayout.frame.size.width, self.viewForBaselineLayout.frame.size.height)];
#else
        self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewForBaselineLayout.frame.size.width, self.viewForBaselineLayout.frame.size.height-(self.viewForBaselineLayout.frame.size.height/4))];
#endif
        self.noDataLabel.backgroundColor = [UIColor clearColor];
        self.noDataLabel.textAlignment = NSTextAlignmentCenter;
#if !TARGET_INTERFACE_BUILDER
        NSString *noDataText;
        if ([self.delegate respondsToSelector:@selector(noDataLabelTextForLineGraph:)]) {
            noDataText = [self.delegate noDataLabelTextForLineGraph:self];
        }
        self.noDataLabel.text = noDataText ?: NSLocalizedString(@"No Data", nil);
#else
        self.noDataLabel.text = @"数据无法再IB中加载";
#endif
        self.noDataLabel.font = self.noDataLabelFont ?: [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        self.noDataLabel.textColor = self.noDataLabelColor ?: self.colorLine;
        [self.viewForBaselineLayout addSubview:self.noDataLabel];
        
        //告知折线图加载完成
        if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishLoading:)])
            [self.delegate lineGraphDidFinishLoading:self];
        return;
    }else if (dataPoints.count == 0) {
        NSLog(@"[XMYLineChartView] 数据源中只有一个点。");
        XMYLinkGraphs *linkGraph = [[XMYLinkGraphs alloc] initWithFrame:CGRectMake(0, 0, self.sizeLinkGraph, self.sizeLinkGraph)];
        linkGraph.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        linkGraph.graphFillColor = self.colorLinkGraph;
        linkGraph.alpha = 1;
        [self addSubview:linkGraph];
        return;
    } else {
        //删除上一次折线中所有的点
        for (UILabel *subview in [self subviews]) {
            if ([subview isEqual:self.noDataLabel])
                [subview removeFromSuperview];
        }
    }
}

- (void)layoutTouchReport {
    //如果允许显示距离触摸点最近的点
    if (self.displayTouchReport == YES || self.displayPopUpView == YES) {
        //初始化触摸辅助线在用户触摸的位置
        self.touchLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.widthTouchInputLine, self.frame.size.height)];
        self.touchLine.backgroundColor = self.colorTouchInputLine;
        self.touchLine.alpha = 0;
        [self addSubview:self.touchLine];
        
        self.panView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.viewForBaselineLayout.frame.size.width, self.viewForBaselineLayout.frame.size.height)];
        self.panView.backgroundColor = [UIColor clearColor];
        [self.viewForBaselineLayout addSubview:self.panView];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureAction:)];
        self.panGesture.delegate = self;
        [self.panGesture setMaximumNumberOfTouches:1];
        [self.panView addGestureRecognizer:self.panGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureAction:)];
        self.longPressGesture.minimumPressDuration = 0.1f;
        [self.panView addGestureRecognizer:self.longPressGesture];
        
        if (self.displayPopUpView == YES && self.alwaysDisplayPopUpLabels == NO) {
            if ([self.delegate respondsToSelector:@selector(popUpViewForLineGraph:)]) {
                self.popUpView = [self.delegate popUpViewForLineGraph:self];
                self.usingCustomPopupView = YES;
                self.popUpView.alpha = 0;
                [self addSubview:self.popUpView];
            } else {
                NSString *maxValueString = [NSString stringWithFormat:self.formatStringForValues, [self calculateMaximumPointValue].doubleValue];
                NSString *minValueString = [NSString stringWithFormat:self.formatStringForValues, [self calculateMinimumPointValue].doubleValue];
                
                NSString *longestString = @"";
                if (maxValueString.length > minValueString.length) {
                    longestString = maxValueString;
                } else {
                    longestString = minValueString;
                }
                
                NSArray *prefix;
                NSArray *suffix;
                NSString *maxprefix = @"";
                NSString *maxsuffix = @"";
                if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)]) {
                    suffix = [self.delegate popUpSuffixForlineGraph:self];
                    for (NSString *suffixString in suffix) {
                        if (maxsuffix.length < suffixString.length) {
                            maxsuffix = suffixString;
                        }
                    }
                }
                if ([self.delegate respondsToSelector:@selector(popUpPrefixForlineGraph:)]) {
                    prefix = [self.delegate popUpPrefixForlineGraph:self];
                    for (NSString *prefixString in prefix) {
                        if (maxprefix.length < prefixString.length) {
                            maxprefix = prefixString;
                        }
                    }
                }
                
                NSString *appendString = @"";
                for (int i = 0; i < numberOfLines; i ++) {
                    if (i == 0) {
                        appendString = [NSString stringWithFormat:@"%@%@%@\n", maxprefix, longestString, maxsuffix];
                    }else{
                        appendString = [NSString stringWithFormat:@"%@%@%@%@\n", appendString, maxprefix, longestString, maxsuffix];
                    }
                }
                
                NSString *fullString = [appendString substringToIndex:appendString.length - 1];
                
                NSString *mString = [fullString stringByReplacingOccurrencesOfString:@"[0-9-]" withString:@"N" options:NSRegularExpressionSearch range:NSMakeRange(0, [longestString length])];
                
                NSDictionary *attributes = @{NSFontAttributeName: self.labelFont};;
                
                CGSize popLableSize = [mString boundingRectWithSize:CGSizeMake(200, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:attributes
                                                            context:nil].size;
                
                self.popUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, popLableSize.height)];
                self.popUpLabel.text = mString;
                self.popUpLabel.textAlignment = 1;
                self.popUpLabel.numberOfLines = 0;
                self.popUpLabel.font = self.labelFont;
                self.popUpLabel.backgroundColor = [UIColor clearColor];
                [self.popUpLabel sizeToFit];
                self.popUpLabel.alpha = 0;
                self.popUpLabel.textColor = self.colorTextPopUpLabel;
                
                self.popUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.popUpLabel.frame.size.width + 10, self.popUpLabel.frame.size.height + 2)];
                self.popUpView.backgroundColor = self.colorBackgroundPopUpLabel;
                self.popUpView.alpha = 0;
                self.popUpView.layer.cornerRadius = 3;
                [self addSubview:self.popUpView];
                [self addSubview:self.popUpLabel];
            }
        }
    }
}

#pragma mark - Drawing
- (void)didFinishDrawingIncludingYAxis:(BOOL)yAxisFinishedDrawing {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.animationTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.displayYLabel == NO) {
            //让delegate知道图形渲染完成
            if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishDrawing:)])
                [self.delegate lineGraphDidFinishDrawing:self];
            return;
        } else {
            if (yAxisFinishedDrawing == YES) {
                //让delegate知道图形渲染完成
                if ([self.delegate respondsToSelector:@selector(lineGraphDidFinishDrawing:)])
                    [self.delegate lineGraphDidFinishDrawing:self];
                return;
            }
        }
    });
}

- (void)drawEntireGraph {
    self.maxValue = [self getMaximumValue];
    self.minValue = [self getMinimumValue];
    
    //如果显示Y轴标签，需要对折线图进行偏移，偏移量等于标签中宽度最大值
    if (self.displayYLabel) {
        NSDictionary *attributes = @{NSFontAttributeName: self.labelFont};
        if (self.autoScaleY == YES){
            NSString *maxValueString = [NSString stringWithFormat:self.formatStringForValues, self.maxValue];
            NSString *minValueString = [NSString stringWithFormat:self.formatStringForValues, self.minValue];
            
            NSString *longestString = @"";
            if (maxValueString.length > minValueString.length) longestString = maxValueString;
            else longestString = minValueString;
            
            NSString *prefix = @"";
            NSString *suffix = @"";
            
            if ([self.delegate respondsToSelector:@selector(yAxisPrefixOnLineGraph:)]) {
                prefix = [self.delegate yAxisPrefixOnLineGraph:self];
            }
            
            if ([self.delegate respondsToSelector:@selector(yAxisSuffixOnLineGraph:)]) {
                suffix = [self.delegate yAxisSuffixOnLineGraph:self];
            }
            
            NSString *mString = [longestString stringByReplacingOccurrencesOfString:@"[0-9-]" withString:@"N" options:NSRegularExpressionSearch range:NSMakeRange(0, [longestString length])];
            NSString *fullString = [NSString stringWithFormat:@"%@%@%@", prefix, mString, suffix];
            self.yLabelXOffset = [fullString sizeWithAttributes:attributes].width + 2;
        } else {
            NSString *longestString = [NSString stringWithFormat:@"%i", (int)self.frame.size.height];
            self.yLabelXOffset = [longestString sizeWithAttributes:attributes].width + 5;
        }
    } else self.yLabelXOffset = 0;
    
    //绘X轴
    [self drawXAxis];
    
    //画图形界面
    [self drawDots];
    
    //画Y轴
    if (self.displayYLabel) [self drawYAxis];
}

- (void)drawDots {
    //当前位置在X轴上的点被创建
    CGFloat positionOnXAxis;
    //当前位置在Y轴上的点被创建
    CGFloat positionOnYAxis;
    
    //删除之前所有的点、图
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[XMYLinkGraphs class]] || [subview isKindOfClass:[XMYPopUpView class]] || [subview isKindOfClass:[XMYPopUpLabel class]])
            [subview removeFromSuperview];
    }
    
    //遍历每一个点添加到图上
    @autoreleasepool {
        for (int i = 0; i < numberOfLines; i++) {
            NSArray *linePointArray = dataPoints[i];
            NSMutableArray *yValueArray = [[NSMutableArray alloc] init];
            for (int j = 0; j < linePointArray.count; j ++) {
                CGFloat dotValue = 0;
                
#if !TARGET_INTERFACE_BUILDER
                dotValue = [linePointArray[j] floatValue];
#else
                dotValue = (int)(arc4random() % 10000);
#endif
                
                if (self.positionYRight) {
                    positionOnXAxis = (((self.frame.size.width - self.yLabelXOffset) / (numberOfPoints - 1)) * j);
                } else {
                    positionOnXAxis = (((self.frame.size.width - self.yLabelXOffset) / (numberOfPoints - 1)) * j) + self.yLabelXOffset;
                }
                
                positionOnYAxis = [self yPositionForDotValue:dotValue];
                
                [yValueArray addObject:@(positionOnYAxis)];
                
                
                //忽略null点
                
                if (dotValue != XMYNullGraphValue) {
                    XMYLinkGraphs *circleDot = [[XMYLinkGraphs alloc] initWithFrame:CGRectMake(0, 0, self.sizeLinkGraph, self.sizeLinkGraph)];
                    circleDot.center = CGPointMake(positionOnXAxis, positionOnYAxis);
                    circleDot.tag = j + DotFirstTag100;
                    circleDot.alpha = 0;
                    circleDot.absoluteValue = dotValue;
                    circleDot.graphFillColor = self.colorLinkGraph;
                    
                    [self addSubview:circleDot];
                    if (self.alwaysDisplayPopUpLabels == YES) {
                        if ([self.delegate respondsToSelector:@selector(lineGraph:alwaysDisplayPopUpAtIndex:)]) {
                            if ([self.delegate lineGraph:self alwaysDisplayPopUpAtIndex:i] == YES) {
                                [self displayPermanentLabelForPoint:circleDot];
                            }
                        } else [self displayPermanentLabelForPoint:circleDot];
                    }
                    
                    //连接图形开始的动画
                    if (self.animationTime == 0) {
                        if (self.displayDotsOnly == YES) circleDot.alpha = 1.0;
                        else {
                            if (self.alwaysDisplayDots == NO) circleDot.alpha = 0;
                            else circleDot.alpha = 1.0;
                        }
                    } else {
                        if (self.displayDotsWhileAnimating) {
                            [UIView animateWithDuration:(float)self.animationTime/(float)numberOfPoints delay:(float)j*((float)self.animationTime/numberOfPoints) options:UIViewAnimationOptionCurveLinear animations:^{
                                circleDot.alpha = 1.0;
                            } completion:^(BOOL finished) {
                                if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO) {
                                    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                        circleDot.alpha = 0;
                                    } completion:nil];
                                }
                            }];
                        }
                    }
                }
            }
            [yValues addObject:yValueArray];
        }
    }
    
    //创建线的底部和顶部
    [self drawLine];
}

- (void)drawLine {
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[XMYLine class]])
            [subview removeFromSuperview];
    }
    
    XMYLine *line = [[XMYLine alloc] initWithFrame:[self drawableGraphArea]];
    
    line.opaque = NO;
    line.alpha = 1;
    line.backgroundColor = [UIColor clearColor];
    line.topColor = self.colorTop;
    line.bottomColor = self.colorBottom;
    line.lineTopAlpha = self.alphaTop;
    line.lineBottomAlpha = self.alphaBottom;
    line.topGradient = self.gradientTop;
    line.bottomGradient = self.gradientBottom;
    line.lineWidth = self.widthLine;
    line.referenceLineWidth = self.widthReferenceLines?self.widthReferenceLines:(self.widthLine/2);
    line.lineAlpha = self.alphaLine;
    line.bezierCurve = self.bezierCurve;
    line.arrayOfPoints = yValues;
    line.arrayOfValues = self.graphValuesForDataPoints;
    line.linePatternForReferenceYAxisLines = self.linePatternForReferenceYLines;
    line.linePatternForReferenceXAxisLines = self.linePatternForReferenceXLines;
    line.interpolateNullValues = self.interpolateNullValues;
    
    line.displayRefrenceXYLines = self.displayReference;
    line.displayRightReferenceLine = self.displayRightReferenceLine;
    line.displayTopReferenceLine = self.displayTopReferenceLine;
    line.displayLeftReferenceLine = self.displayLeftReferenceLine;
    line.displayBottomReferenceLine = self.displayBottomReferenceLine;
    
    if (self.displayReferenceXLines || self.displayReferenceYLines) {
        line.displayRefrenceLines = YES;
        line.refrenceLineColor = self.colorReferenceLines;
        line.verticalReference = xHorizontalFringeValue;
        line.arrayOfVerticalPoints = self.displayReferenceXLines ? xLabelPoints : nil;
        line.arrayOfHorizontalPoints = self.displayReferenceYLines ? yLabelPoints : nil;
    }
    
    line.lineColor = self.colorLine;
    line.colorLineArray = self.colorLineArray;
    line.lineGradient = self.gradientLine;
    line.lineGradientDirection = self.gradientLineDirection;
    line.animationTime = self.animationTime;
    line.animationType = self.animationType;
    
    if (self.averageLine.displayAverageLine == YES) {
        if (self.averageLine.modeValue == 0.0) self.averageLine.modeValue = [self calculatePointValueAverage].floatValue;
        line.averageLineYPosition = [self yPositionForDotValue:self.averageLine.modeValue];
        line.averageLine = self.averageLine;
    } else line.averageLine = self.averageLine;
    
    line.alwaysDisplayGraphs = self.displayDotsOnly;
    
    [self addSubview:line];
    [self sendSubviewToBack:line];
    [self sendSubviewToBack:self.backgroundX];
    
    [self didFinishDrawingIncludingYAxis:NO];
}

- (void)drawXAxis {
    if (!self.displayXLabel) return;
    if (![self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) return;
    
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == DotLastTag1000) [subview removeFromSuperview];
        else if ([subview isKindOfClass:[UIView class]] && subview.tag == BackgroundXAxisTag2200) [subview removeFromSuperview];
    }
    
    //删除标签信息
    [xValues removeAllObjects];
    [xLabels removeAllObjects];
    [xLabelPoints removeAllObjects];
    xHorizontalFringeValue = 0.0;
    
    //画轴的背景区域
    self.backgroundX = [[UIView alloc] initWithFrame:[self drawableXAxisArea]];
    self.backgroundX.tag = BackgroundXAxisTag2200;
    if (self.colorBackgroundX == nil) self.backgroundX.backgroundColor = self.colorBottom;
    else self.backgroundX.backgroundColor = self.colorBackgroundX;
    self.backgroundX.alpha = self.alphaBackgroundX;
    [self addSubview:self.backgroundX];
    
    if ([self.delegate respondsToSelector:@selector(incrementPositionsForXAxisOnLineGraph:)]) {
        NSArray *axisValues = [self.delegate incrementPositionsForXAxisOnLineGraph:self];
        for (NSNumber *increment in axisValues) {
            NSInteger index = increment.integerValue;
            NSString *xAxisLabelText = [self xAxisTextForIndex:index];
            
            UILabel *labelXAxis = [self xAxisLabelWithText:xAxisLabelText atIndex:index];
            [xLabels addObject:labelXAxis];
            
            if (self.positionYRight) {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x];
                [xLabelPoints addObject:xAxisLabelCoordinate];
            } else {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x-self.yLabelXOffset];
                [xLabelPoints addObject:xAxisLabelCoordinate];
            }
            
            [self addSubview:labelXAxis];
            [xValues addObject:xAxisLabelText];
        }
    } else if ([self.delegate respondsToSelector:@selector(baseIndexForXAxisOnLineGraph:)] && [self.delegate respondsToSelector:@selector(incrementIndexForXAxisOnLineGraph:)]) {
        NSInteger baseIndex = [self.delegate baseIndexForXAxisOnLineGraph:self];
        NSInteger increment = [self.delegate incrementIndexForXAxisOnLineGraph:self];
        
        NSInteger startingIndex = baseIndex;
        while (startingIndex < numberOfPoints) {
            NSString *xAxisLabelText = [self xAxisTextForIndex:startingIndex];
            
            UILabel *labelXAxis = [self xAxisLabelWithText:xAxisLabelText atIndex:startingIndex];
            [xLabels addObject:labelXAxis];
            
            if (self.positionYRight) {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x];
                [xLabelPoints addObject:xAxisLabelCoordinate];
            } else {
                NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x-self.yLabelXOffset];
                [xLabelPoints addObject:xAxisLabelCoordinate];
            }
            
            [self addSubview:labelXAxis];
            [xValues addObject:xAxisLabelText];
            
            startingIndex += increment;
        }
    } else {
        NSInteger numberOfGaps = 1;
        if ([self.delegate respondsToSelector:@selector(numberOfGapsBetweenLabelsOnLineGraph:)]) {
            numberOfGaps = [self.delegate numberOfGapsBetweenLabelsOnLineGraph:self] + 1;
            
        } else {
            numberOfGaps = 1;
        }
        
        if (numberOfGaps >= (numberOfPoints - 1)) {
            NSString *firstXLabel = [self xAxisTextForIndex:0];
            NSString *lastXLabel = [self xAxisTextForIndex:numberOfPoints - 1];
            
            CGFloat viewWidth = self.frame.size.width - self.yLabelXOffset;
            
            CGFloat xAxisXPositionFirstOffset;
            CGFloat xAxisXPositionLastOffset;
            if (self.positionYRight) {
                xAxisXPositionFirstOffset = 3;
                xAxisXPositionLastOffset = xAxisXPositionFirstOffset + 1 + viewWidth/2;
            } else {
                xAxisXPositionFirstOffset = 3+self.yLabelXOffset;
                xAxisXPositionLastOffset = viewWidth/2 + xAxisXPositionFirstOffset + 1;
            }
            UILabel *firstLabel = [self xAxisLabelWithText:firstXLabel atIndex:0];
            firstLabel.frame = CGRectMake(xAxisXPositionFirstOffset, self.frame.size.height-20, viewWidth/2, 20);
            
            firstLabel.textAlignment = NSTextAlignmentLeft;
            [self addSubview:firstLabel];
            [xValues addObject:firstXLabel];
            [xLabels addObject:firstLabel];
            
            UILabel *lastLabel = [self xAxisLabelWithText:lastXLabel atIndex:numberOfPoints - 1];
            lastLabel.frame = CGRectMake(xAxisXPositionLastOffset, self.frame.size.height-20, viewWidth/2 - 4, 20);
            lastLabel.textAlignment = NSTextAlignmentRight;
            [self addSubview:lastLabel];
            [xValues addObject:lastXLabel];
            [xLabels addObject:lastLabel];
            
            if (self.positionYRight) {
                NSNumber *xFirstAxisLabelCoordinate = @(firstLabel.center.x);
                NSNumber *xLastAxisLabelCoordinate = @(lastLabel.center.x);
                [xLabelPoints addObject:xFirstAxisLabelCoordinate];
                [xLabelPoints addObject:xLastAxisLabelCoordinate];
            } else {
                NSNumber *xFirstAxisLabelCoordinate = @(firstLabel.center.x - self.yLabelXOffset);
                NSNumber *xLastAxisLabelCoordinate = @(lastLabel.center.x - self.yLabelXOffset);
                [xLabelPoints addObject:xFirstAxisLabelCoordinate];
                [xLabelPoints addObject:xLastAxisLabelCoordinate];
            }
        } else {
            @autoreleasepool {
                //offset改变x轴标签的中心
                NSInteger offset = [self offsetForXAxisWithNumberOfGaps:numberOfGaps];
                
                for (int i = 1; i <= (numberOfPoints/numberOfGaps); i++) {
                    NSInteger index = i *numberOfGaps - 1 - offset;
                    NSString *xAxisLabelText = [self xAxisTextForIndex:index];
                    
                    UILabel *labelXAxis = [self xAxisLabelWithText:xAxisLabelText atIndex:index];
                    [xLabels addObject:labelXAxis];
                    
                    if (self.positionYRight) {
                        NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x];
                        [xLabelPoints addObject:xAxisLabelCoordinate];
                    } else {
                        NSNumber *xAxisLabelCoordinate = [NSNumber numberWithFloat:labelXAxis.center.x - self.yLabelXOffset];
                        [xLabelPoints addObject:xAxisLabelCoordinate];
                    }
                    
                    [self addSubview:labelXAxis];
                    [xValues addObject:xAxisLabelText];
                }
            }
        }
    }
    __block NSUInteger lastMatchIndex;
    
    NSMutableArray *overlapLabels = [NSMutableArray arrayWithCapacity:0];
    [xLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            lastMatchIndex = 0;
        } else {
            UILabel *prevLabel = [xLabels objectAtIndex:lastMatchIndex];
            CGRect r = CGRectIntersection(prevLabel.frame, label.frame);
            if (CGRectIsNull(r)) lastMatchIndex = idx;
            else [overlapLabels addObject:label];
        }
        
        BOOL fullyContainsLabel = CGRectContainsRect(self.bounds, label.frame);
        if (!fullyContainsLabel) {
            [overlapLabels addObject:label];
        }
    }];
    
    for (UILabel *l in overlapLabels) {
        [l removeFromSuperview];
    }
}

- (NSString *)xAxisTextForIndex:(NSInteger)index {
    NSString *xAxisLabelText = @"";
    
    if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
        xAxisLabelText = [self.dataSource lineGraph:self labelOnXAxisForIndex:index];
        
    } else  {
        xAxisLabelText = @"";
    }
    
    return xAxisLabelText;
}

- (UILabel *)xAxisLabelWithText:(NSString *)text atIndex:(NSInteger)index {
    UILabel *labelXAxis = [[UILabel alloc] init];
    labelXAxis.text = text;
    labelXAxis.font = self.labelFont;
    labelXAxis.textAlignment = 1;
    labelXAxis.textColor = self.colorXLabel;
    labelXAxis.backgroundColor = [UIColor clearColor];
    labelXAxis.tag = DotLastTag1000;
    
    //添加多行支持
    labelXAxis.numberOfLines = 0;
    CGRect lRect = [labelXAxis.text boundingRectWithSize:self.viewForBaselineLayout.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelXAxis.font} context:nil];
    
    CGPoint center;
    
    CGFloat horizontalTranslation;
    if (index == 0) {
        horizontalTranslation = lRect.size.width/2;
    } else if (index+1 == numberOfPoints) {
        horizontalTranslation = -lRect.size.width/2;
    } else horizontalTranslation = 0;
    xHorizontalFringeValue = horizontalTranslation;
    
    //确定最终的位子
    CGFloat positionOnXAxis;
    if (self.positionYRight) {
        positionOnXAxis = (((self.frame.size.width - self.yLabelXOffset) / (numberOfPoints - 1)) * index) + horizontalTranslation;
    } else {
        positionOnXAxis = (((self.frame.size.width - self.yLabelXOffset) / (numberOfPoints - 1)) * index) + self.yLabelXOffset + horizontalTranslation;
    }
    
    //标签的中心点
    if (self.positionYRight) {
        center = CGPointMake(positionOnXAxis, self.frame.size.height - lRect.size.height/2);
    } else {
        center = CGPointMake(positionOnXAxis, self.frame.size.height - lRect.size.height/2);
    }
    
    CGRect rect = labelXAxis.frame;
    rect.size = lRect.size;
    labelXAxis.frame = rect;
    labelXAxis.center = center;
    return labelXAxis;
}

- (void)drawYAxis {
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == LabelYAxisTag2000 ) {
            [subview removeFromSuperview];
        } else if ([subview isKindOfClass:[UIView class]] && subview.tag == BackgroundYAxisTag2100 ) {
            [subview removeFromSuperview];
        }
    }
    
    CGRect frameForBackgroundYAxis;
    CGRect frameForLabelYAxis;
    CGFloat xValueForCenterLabelYAxis;
    NSTextAlignment textAlignmentForLabelYAxis;
    
    if (self.positionYRight) {
        frameForBackgroundYAxis = CGRectMake(self.frame.size.width - self.yLabelXOffset, 0, self.yLabelXOffset, self.frame.size.height);
        frameForLabelYAxis = CGRectMake(self.frame.size.width - self.yLabelXOffset - 5, 0, self.yLabelXOffset - 5, 15);
        xValueForCenterLabelYAxis = self.frame.size.width - self.yLabelXOffset /2;
        textAlignmentForLabelYAxis = NSTextAlignmentRight;
    } else {
        frameForBackgroundYAxis = CGRectMake(0, 0, self.yLabelXOffset, self.frame.size.height);
        frameForLabelYAxis = CGRectMake(0, 0, self.yLabelXOffset - 5, 15);
        xValueForCenterLabelYAxis = self.yLabelXOffset/2;
        textAlignmentForLabelYAxis = NSTextAlignmentRight;
    }
    
    UIView *backgroundYaxis = [[UIView alloc] initWithFrame:frameForBackgroundYAxis];
    backgroundYaxis.tag = BackgroundYAxisTag2100;
    if (self.colorBackgroundY == nil) backgroundYaxis.backgroundColor = self.colorTop;
    else backgroundYaxis.backgroundColor = self.colorBackgroundY;
    backgroundYaxis.alpha = self.alphaBackgroundYaxis;
    [self addSubview:backgroundYaxis];
    
    NSMutableArray *yAxisLabels = [NSMutableArray arrayWithCapacity:0];
    [yLabelPoints removeAllObjects];
    
    NSString *yAxisSuffix = @"";
    NSString *yAxisPrefix = @"";
    
    if ([self.delegate respondsToSelector:@selector(yAxisPrefixOnLineGraph:)]) yAxisPrefix = [self.delegate yAxisPrefixOnLineGraph:self];
    if ([self.delegate respondsToSelector:@selector(yAxisSuffixOnLineGraph:)]) yAxisSuffix = [self.delegate yAxisSuffixOnLineGraph:self];
    
    if (self.autoScaleY) {
        NSNumber *minimumValue;
        NSNumber *maximumValue;
        
        minimumValue = [self calculateMinimumPointValue];
        maximumValue = [self calculateMaximumPointValue];
        
        CGFloat numberOfLabels;
        if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) {
            numberOfLabels = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
        } else numberOfLabels = 3;
        
        NSMutableArray *dotValues = [[NSMutableArray alloc] initWithCapacity:numberOfLabels];
        if ([self.delegate respondsToSelector:@selector(baseValueForYAxisOnLineGraph:)] && [self.delegate respondsToSelector:@selector(incrementValueForYAxisOnLineGraph:)]) {
            CGFloat baseValue = [self.delegate baseValueForYAxisOnLineGraph:self];
            CGFloat increment = [self.delegate incrementValueForYAxisOnLineGraph:self];
            
            float yAxisPosition = baseValue;
            if (baseValue + increment * 100 < maximumValue.doubleValue) {
                NSLog(@"[XMYLineChartView] 数据出现错误提前终止");
                return;
            }
            
            while(yAxisPosition < maximumValue.floatValue + increment) {
                [dotValues addObject:@(yAxisPosition)];
                yAxisPosition += increment;
            }
        } else if (numberOfLabels <= 0) return;
        else if (numberOfLabels == 1) {
            [dotValues removeAllObjects];
            [dotValues addObject:[NSNumber numberWithInt:(minimumValue.intValue + maximumValue.intValue)/2]];
        } else {
            [dotValues addObject:minimumValue];
            [dotValues addObject:maximumValue];
            for (int i=1; i<numberOfLabels-1; i++) {
                [dotValues addObject:[NSNumber numberWithFloat:(minimumValue.doubleValue + ((maximumValue.doubleValue - minimumValue.doubleValue)/(numberOfLabels-1))*i)]];
            }
        }
        
        for (NSNumber *dotValue in dotValues) {
            CGFloat yAxisPosition = [self yPositionForDotValue:dotValue.floatValue];
            UILabel *labelYAxis = [[UILabel alloc] initWithFrame:frameForLabelYAxis];
            NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, dotValue.doubleValue];
            labelYAxis.text = [NSString stringWithFormat:@"%@%@%@", yAxisPrefix, formattedValue, yAxisSuffix];
            labelYAxis.textAlignment = textAlignmentForLabelYAxis;
            labelYAxis.font = self.labelFont;
            labelYAxis.textColor = self.colorYLabel;
            labelYAxis.backgroundColor = [UIColor clearColor];
            labelYAxis.tag = LabelYAxisTag2000;
            labelYAxis.center = CGPointMake(xValueForCenterLabelYAxis, yAxisPosition);
            [self addSubview:labelYAxis];
            [yAxisLabels addObject:labelYAxis];
            
            NSNumber *yAxisLabelCoordinate = @(labelYAxis.center.y);
            [yLabelPoints addObject:yAxisLabelCoordinate];
        }
    } else {
        NSInteger numberOfLabels;
        if ([self.delegate respondsToSelector:@selector(numberOfYAxisLabelsOnLineGraph:)]) numberOfLabels = [self.delegate numberOfYAxisLabelsOnLineGraph:self];
        else numberOfLabels = 3;
        
        CGFloat graphHeight = self.frame.size.height;
        CGFloat graphSpacing = (graphHeight - self.xLabelYOffset) / numberOfLabels;
        
        CGFloat yAxisPosition = graphHeight - self.xLabelYOffset + graphSpacing/2;
        
        for (NSInteger i = numberOfLabels; i > 0; i--) {
            yAxisPosition -= graphSpacing;
            
            UILabel *labelYAxis = [[UILabel alloc] initWithFrame:frameForLabelYAxis];
            labelYAxis.center = CGPointMake(xValueForCenterLabelYAxis, yAxisPosition);
            labelYAxis.text = [NSString stringWithFormat:self.formatStringForValues, (graphHeight - self.xLabelYOffset - yAxisPosition)];
            labelYAxis.font = self.labelFont;
            labelYAxis.textAlignment = textAlignmentForLabelYAxis;
            labelYAxis.textColor = self.colorYLabel;
            labelYAxis.backgroundColor = [UIColor clearColor];
            labelYAxis.tag = LabelYAxisTag2000;
            
            [self addSubview:labelYAxis];
            
            [yAxisLabels addObject:labelYAxis];
            
            NSNumber *yAxisLabelCoordinate = @(labelYAxis.center.y);
            [yLabelPoints addObject:yAxisLabelCoordinate];
        }
    }
    
    //检测重复的标签
    __block NSUInteger lastMatchIndex = 0;
    NSMutableArray *overlapLabels = [NSMutableArray arrayWithCapacity:0];
    
    [yAxisLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        
        if (idx==0) lastMatchIndex = 0;
        else {
            //跳过第一个
            UILabel *prevLabel = yAxisLabels[lastMatchIndex];
            CGRect r = CGRectIntersection(prevLabel.frame, label.frame);
            if (CGRectIsNull(r)) lastMatchIndex = idx;
            else [overlapLabels addObject:label]; // overlapped
        }
        
        BOOL fullyContainsLabel = CGRectContainsRect(self.bounds, label.frame);
        if (!fullyContainsLabel) {
            [overlapLabels addObject:label];
            [yLabelPoints removeObject:@(label.center.y)];
        }
    }];
    
    for (UILabel *label in overlapLabels) {
        [label removeFromSuperview];
    }
    
    [self didFinishDrawingIncludingYAxis:YES];
}

- (CGRect)drawableGraphArea {
    NSInteger xAxisHeight = 20;
    CGFloat xOrigin = self.positionYRight ? 0 : self.yLabelXOffset;
    CGFloat viewWidth = self.frame.size.width - self.yLabelXOffset;
    CGFloat adjustedHeight = self.bounds.size.height - xAxisHeight;
    
    CGRect rect = CGRectMake(xOrigin, 0, viewWidth, adjustedHeight);
    return rect;
}

- (CGRect)drawableXAxisArea {
    NSInteger xAxisHeight = 20;
    NSInteger xAxisWidth = [self drawableGraphArea].size.width + 1;
    CGFloat xAxisXOrigin = self.positionYRight ? 0 : self.yLabelXOffset;
    CGFloat xAxisYOrigin = self.bounds.size.height - xAxisHeight;
    return CGRectMake(xAxisXOrigin, xAxisYOrigin, xAxisWidth, xAxisHeight);
}

- (NSInteger)offsetForXAxisWithNumberOfGaps:(NSInteger)numberOfGaps {
    NSInteger leftGap = numberOfGaps - 1;
    NSInteger rightGap = numberOfPoints - (numberOfGaps*(numberOfPoints/numberOfGaps));
    NSInteger offset = 0;
    
    if (leftGap != rightGap) {
        for (int i = 0; i <= numberOfGaps; i++) {
            if (leftGap - i == rightGap + i) {
                offset = i;
            }
        }
    }
    
    return offset;
}

- (void)displayPermanentLabelForPoint:(XMYLinkGraphs *)circleDot {
    self.displayPopUpView = NO;
    self.xCenterLabel = circleDot.center.x;
    
    XMYPopUpLabel *permanentPopUpLabel = [[XMYPopUpLabel alloc] init];
    permanentPopUpLabel.textAlignment = NSTextAlignmentCenter;
    permanentPopUpLabel.numberOfLines = 0;
    
    NSArray *prefix;
    NSArray *suffix;
    
    if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)])
        suffix = [self.delegate popUpSuffixForlineGraph:self];
    
    if ([self.delegate respondsToSelector:@selector(popUpPrefixForlineGraph:)])
        prefix = [self.delegate popUpPrefixForlineGraph:self];
    
    int index = (int)(circleDot.tag - DotFirstTag100);
    NSString *popLabelTxt;
    for (int i = 0; i < numberOfLines; i ++) {
        NSArray *pointAttay = dataPoints[i];
        NSNumber *value = pointAttay[index];
        NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, value.doubleValue];
        if (i == 0) {
            popLabelTxt = [NSString stringWithFormat:@"%@%@%@\n",prefix[i],formattedValue,suffix[i]];
        }else{
            popLabelTxt = [NSString stringWithFormat:@"%@%@%@%@\n",popLabelTxt,prefix[i],formattedValue,suffix[i]];
        }
    }
    permanentPopUpLabel.text = [[popLabelTxt substringToIndex:popLabelTxt.length - 1] stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    
    permanentPopUpLabel.font = self.labelFont;
    permanentPopUpLabel.backgroundColor = [UIColor clearColor];
    [permanentPopUpLabel sizeToFit];
    permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    permanentPopUpLabel.alpha = 0;
    
    XMYPopUpView *permanentPopUpView = [[XMYPopUpView alloc] initWithFrame:CGRectMake(0, 0, permanentPopUpLabel.frame.size.width + 7, permanentPopUpLabel.frame.size.height + 2)];
    permanentPopUpView.backgroundColor = self.colorBackgroundPopUpLabel;
    permanentPopUpView.alpha = 0;
    permanentPopUpView.layer.cornerRadius = 3;
    permanentPopUpView.tag = PermanentPopUpViewTag3100;
    permanentPopUpView.center = permanentPopUpLabel.center;
    
    if (permanentPopUpLabel.frame.origin.x <= 0) {
        self.xCenterLabel = permanentPopUpLabel.frame.size.width/2 + 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    } else if (self.displayYLabel == YES && permanentPopUpLabel.frame.origin.x <= self.yLabelXOffset) {
        self.xCenterLabel = permanentPopUpLabel.frame.size.width/2 + 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel + self.yLabelXOffset, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    } else if ((permanentPopUpLabel.frame.origin.x + permanentPopUpLabel.frame.size.width) >= self.frame.size.width) {
        self.xCenterLabel = self.frame.size.width - permanentPopUpLabel.frame.size.width/2 - 4;
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y - circleDot.frame.size.height/2 - 15);
    }
    
    if (permanentPopUpLabel.frame.origin.y <= 2) {
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y + circleDot.frame.size.height/2 + 15);
    }
    
    if ([self checkOverlapsForView:permanentPopUpView] == YES) {
        permanentPopUpLabel.center = CGPointMake(self.xCenterLabel, circleDot.center.y + circleDot.frame.size.height/2 + 15);
    }
    
    permanentPopUpView.center = permanentPopUpLabel.center;
    
    [self addSubview:permanentPopUpView];
    [self addSubview:permanentPopUpLabel];
    
    if (self.animationTime == 0) {
        permanentPopUpLabel.alpha = 1;
        permanentPopUpView.alpha = 0.7;
    } else {
        [UIView animateWithDuration:0.5 delay:self.animationTime options:UIViewAnimationOptionCurveLinear animations:^{
            permanentPopUpLabel.alpha = 1;
            permanentPopUpView.alpha = 0.7;
        } completion:nil];
    }
}

- (BOOL)checkOverlapsForView:(UIView *)view {
    for (UIView *viewForLabel in [self subviews]) {
        if ([viewForLabel isKindOfClass:[UIView class]] && viewForLabel.tag == PermanentPopUpViewTag3100 ) {
            if ((viewForLabel.frame.origin.x + viewForLabel.frame.size.width) >= view.frame.origin.x) {
                if (viewForLabel.frame.origin.y >= view.frame.origin.y && viewForLabel.frame.origin.y <= view.frame.origin.y + view.frame.size.height) return YES;
                else if (viewForLabel.frame.origin.y + viewForLabel.frame.size.height >= view.frame.origin.y && viewForLabel.frame.origin.y + viewForLabel.frame.size.height <= view.frame.origin.y + view.frame.size.height) return YES;
            }
        }
    }
    return NO;
}

- (UIImage *)graphSnapshotImage {
    return [self graphSnapshotImageRenderedWhileInBackground:NO];
}

- (UIImage *)graphSnapshotImageRenderedWhileInBackground:(BOOL)appIsInBackground {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    if (appIsInBackground == NO) [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    else [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Data Source
- (void)reloadGraph {
    for (UIView *subviews in self.subviews) {
        [subviews removeFromSuperview];
    }
    [self drawGraph];
}

#pragma mark - Calculations
- (NSArray *)calculationDataPoints {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSNumber *value = (NSNumber *)evaluatedObject;
        BOOL retVal = ![value isEqualToNumber:@(XMYNullGraphValue)];
        return retVal;
    }];
    NSArray *filteredArray = [sumPointData filteredArrayUsingPredicate:filter];
    return filteredArray;
}

- (NSNumber *)calculatePointValueAverage {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"average:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueSum {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"sum:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueMedian {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"median:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculatePointValueMode {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"mode:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSMutableArray *value = [expression expressionValueWithObject:nil context:nil];
    
    return [value firstObject];
}

- (NSNumber *)calculateLineGraphStandardDeviation {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

- (NSNumber *)calculateMinimumPointValue {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"min:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    return value;
}

- (NSNumber *)calculateMaximumPointValue {
    NSArray *filteredArray = [self calculationDataPoints];
    if (filteredArray.count == 0) return [NSNumber numberWithInt:0];
    
    NSExpression *expression = [NSExpression expressionForFunction:@"max:" arguments:@[[NSExpression expressionForConstantValue:filteredArray]]];
    NSNumber *value = [expression expressionValueWithObject:nil context:nil];
    
    return value;
}

#pragma mark - Values
- (NSArray *)graphValuesForX {
    return xValues;
}

- (NSArray *)graphValuesForDataPoints
{
    return dataPoints;
}

- (NSArray *)graphLabelsForX {
    return xLabels;
}

- (void)setAnimationGraphStyle:(XMYLineAnimation)animationGraphType {
    _animationType = animationGraphType;
    if (_animationType == XMYLineAnimationNone)
        self.animationTime = 0.f;
}

#pragma mark - Touch Gestures
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panGesture]) {
        if (gestureRecognizer.numberOfTouches >= self.touchFingersNumber) {
            CGPoint translation = [self.panGesture velocityInView:self.panView];
            return fabs(translation.y) < fabs(translation.x);
        } else return NO;
        return YES;
    } else return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)handleGestureAction:(UIGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer locationInView:self.viewForBaselineLayout];
    
    if (!((translation.x + self.frame.origin.x) <= self.frame.origin.x) && !((translation.x + self.frame.origin.x) >= self.frame.origin.x + self.frame.size.width)) {
        self.touchLine.frame = CGRectMake(translation.x - self.widthTouchInputLine/2, 0, self.widthTouchInputLine, self.frame.size.height);
    }
    
    self.touchLine.alpha = self.alphaTouchInputLine;
    [closestGraph removeAllObjects];
    NSArray *arrayGraph = [self closestDotFromtouchLine:self.touchLine];
    [closestGraph addObjectsFromArray:[arrayGraph subarrayWithRange:NSMakeRange(arrayGraph.count - numberOfLines, numberOfLines)]];
    for (XMYLinkGraphs *graph in closestGraph) {
        graph.alpha = 0.8;
        
        //展示弹出框
        if (self.displayPopUpView == YES && graph.tag >= DotFirstTag100 && graph.tag < DotLastTag1000 && [graph isKindOfClass:[XMYLinkGraphs class]] && self.alwaysDisplayPopUpLabels == NO) {
            [self setUpPopUpLabelAbovePoint:graph];
        }
        
        if (graph.tag >= DotFirstTag100 && graph.tag < DotLastTag1000 && [graph isMemberOfClass:[XMYLinkGraphs class]]) {
            if ([self.delegate respondsToSelector:@selector(lineGraph:didTouchGraphWithClosestIndex:)] && self.displayTouchReport == YES) {
                [self.delegate lineGraph:self didTouchGraphWithClosestIndex:((NSInteger)graph.tag - DotFirstTag100)];
                
            }
        }
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            if ([self.delegate respondsToSelector:@selector(lineGraph:didReleaseTouchFromGraphWithClosestIndex:)]) {
                [self.delegate lineGraph:self didReleaseTouchFromGraphWithClosestIndex:(graph.tag - DotFirstTag100)];
                
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO) {
                    graph.alpha = 0;
                }
                
                self.touchLine.alpha = 0;
                if (self.displayPopUpView == YES) {
                    self.popUpView.alpha = 0;
                    self.popUpLabel.alpha = 0;
                }
            } completion:nil];
        }
    }
}

- (void)setUpPopUpLabelAbovePoint:(XMYLinkGraphs *)closestPoint {
    CGFloat graphsCenterYSum = 0;
    CGFloat graphsCenterY = 0;
    CGFloat graphsCenterX = 0;
    CGRect graphsRect;
    NSInteger graphsTag = 0;
    for (XMYLinkGraphs *graphs in closestGraph) {
        graphsCenterX = graphs.center.x;
        graphsCenterYSum = graphsCenterYSum + graphs.center.y;
        graphsRect = graphs.frame;
        graphsTag = graphs.tag;
    }
    graphsCenterY = graphsCenterYSum/(float)numberOfLines;
    self.yCenterLabel = graphsCenterY - graphsRect.size.height/2 - 15;
    self.popUpView.center = CGPointMake(graphsCenterX, self.yCenterLabel);
    self.popUpLabel.center = self.popUpView.center;
    int index = (int)(graphsTag - DotFirstTag100);
    
    if ([self.delegate respondsToSelector:@selector(lineGraph:modifyPopupView:forIndex:)]) {
        [self.delegate lineGraph:self modifyPopupView:self.popUpView forIndex:index];
    }
    self.xCenterLabel = graphsCenterX;
    self.yCenterLabel = graphsCenterY - graphsRect.size.height/2 - 15;
    self.popUpView.center = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    
    self.popUpView.alpha = 1.0;
    
    CGPoint popUpViewCenter = CGPointZero;
    
    if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)]){
        NSString *labelTxt;
        NSArray *suffixArray = [self.delegate popUpSuffixForlineGraph:self];
        for (int i = 0; i < numberOfLines; i ++) {
            NSArray *pointsArray = dataPoints[i];
            if (i == 0) {
                labelTxt = [NSString stringWithFormat:@"%li%@\n",[pointsArray[(NSInteger) graphsTag - DotFirstTag100] integerValue],suffixArray[i]];
            }else{
                labelTxt = [NSString stringWithFormat:@"%@%li%@\n",labelTxt,[pointsArray[(NSInteger) graphsTag - DotFirstTag100] integerValue],suffixArray[i]];
            }
        }
        self.popUpLabel.text = [labelTxt substringToIndex:labelTxt.length - 1];
    }else{
        NSString *labelTxt;
        for (NSArray *pointArray in dataPoints) {
            labelTxt = [NSString stringWithFormat:@"%li\n",(long)[pointArray[(NSInteger) graphsTag - DotFirstTag100] integerValue]];
        }
        self.popUpLabel.text = [labelTxt substringToIndex:labelTxt.length - 1];
    }
    
    
    if (self.displayYLabel == YES && self.popUpView.frame.origin.x <= self.yLabelXOffset && !self.positionYRight) {
        self.xCenterLabel = self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel + self.yLabelXOffset + 1, self.yCenterLabel);
    } else if ((self.popUpView.frame.origin.x + self.popUpView.frame.size.width) >= self.frame.size.width - self.yLabelXOffset && self.positionYRight) {
        self.xCenterLabel = self.frame.size.width - self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel - self.yLabelXOffset, self.yCenterLabel);
    } else if (self.popUpView.frame.origin.x <= 0) {
        self.xCenterLabel = self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    } else if ((self.popUpView.frame.origin.x + self.popUpView.frame.size.width) >= self.frame.size.width) {
        self.xCenterLabel = self.frame.size.width - self.popUpView.frame.size.width/2;
        popUpViewCenter = CGPointMake(self.xCenterLabel, self.yCenterLabel);
    }
    
    if (self.popUpView.frame.origin.y <= 2) {
        self.yCenterLabel = graphsCenterY + graphsRect.size.height/2 + 15;
        popUpViewCenter = CGPointMake(self.xCenterLabel, graphsCenterY + graphsRect.size.height/2 + 15);
    }
    
    if (!CGPointEqualToPoint(popUpViewCenter, CGPointZero)) {
        self.popUpView.center = popUpViewCenter;
    }
    
    if (!self.usingCustomPopupView) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.popUpView.alpha = 0.7;
            self.popUpLabel.alpha = 1;
        } completion:nil];
        NSArray *prefix;
        NSArray *suffix;
        if ([self.delegate respondsToSelector:@selector(popUpSuffixForlineGraph:)]) {
            suffix = [self.delegate popUpSuffixForlineGraph:self];
        }
        if ([self.delegate respondsToSelector:@selector(popUpPrefixForlineGraph:)]) {
            prefix = [self.delegate popUpPrefixForlineGraph:self];
        }
        NSString *popLabelTxt;
        for (int i = 0; i < numberOfLines; i ++) {
            NSArray *pointAttay = dataPoints[i];
            NSNumber *value = pointAttay[index];
            NSString *formattedValue = [NSString stringWithFormat:self.formatStringForValues, value.doubleValue];
            if (i == 0) {
                popLabelTxt = [NSString stringWithFormat:@"%@%@%@\n",prefix[i],formattedValue,suffix[i]];
            }else{
                popLabelTxt = [NSString stringWithFormat:@"%@%@%@%@\n",popLabelTxt,prefix[i],formattedValue,suffix[i]];
            }
        }
        
        self.popUpLabel.text = [[popLabelTxt substringToIndex:popLabelTxt.length - 1] stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        self.popUpLabel.center = self.popUpView.center;
    }
}

#pragma mark - Graph Calculations
- (NSArray *)closestDotFromtouchLine:(UIView *)touchLine {
    NSMutableArray *XMYLinkArray = [[NSMutableArray alloc] init];
    currentlyCloser = CGFLOAT_MAX;
    for (XMYLinkGraphs *point in self.subviews) {
        if (point.tag >= DotFirstTag100 && point.tag < DotLastTag1000 && [point isMemberOfClass:[XMYLinkGraphs class]]) {
            if (self.alwaysDisplayDots == NO && self.displayDotsOnly == NO) {
                point.alpha = 0;
            }
            if (pow(((point.center.x) - touchLine.center.x), 2) <= currentlyCloser) {
                currentlyCloser = pow(((point.center.x) - touchLine.center.x), 2);
                for (int i = 0; i < numberOfLines; i ++) {
                    [XMYLinkArray addObject:point];
                }
            }
        }
    }
    return XMYLinkArray;
}

- (CGFloat)getMaximumValue {
    if ([self.delegate respondsToSelector:@selector(maxValueForLineGraph:)]) {
        return [self.delegate maxValueForLineGraph:self];
    } else {
        CGFloat maxValue = -FLT_MAX;
        NSInteger numberLines = 0;
        if ([self.dataSource respondsToSelector:@selector(numberOfLineGraph:)]) {
            numberLines = [self.dataSource numberOfLineGraph:self];
        }
        @autoreleasepool {
            for (int i = 0; i < numberLines; i++) {
                if ([self.dataSource respondsToSelector:@selector(lineGraph:valueForPointAtIndex:)]) {
                    NSArray *pointsArray = [self.dataSource lineGraph:self valueForPointAtIndex:i];
                    for (NSNumber *pointValue in pointsArray) {
                        if ([pointValue doubleValue] == XMYNullGraphValue) {
                            continue;
                        }
                        if ([pointValue doubleValue] > maxValue) {
                            maxValue = [pointValue doubleValue];
                        }
                    }
                } else {
                    if (0 > maxValue) {
                        maxValue = 0;
                    }
                }
            }
        }
        return maxValue;
    }
}

- (CGFloat)getMinimumValue {
    if ([self.delegate respondsToSelector:@selector(minValueForLineGraph:)]) {
        return [self.delegate minValueForLineGraph:self];
    } else {
        CGFloat minValue = INFINITY;
        NSInteger numberLines = 0;
        if ([self.dataSource respondsToSelector:@selector(numberOfLineGraph:)]) {
            numberLines = [self.dataSource numberOfLineGraph:self];
        }
        @autoreleasepool {
            for (int i = 0; i < numberLines; i++) {
                if ([self.dataSource respondsToSelector:@selector(lineGraph:valueForPointAtIndex:)]) {
                    NSArray *pointsArray = [self.dataSource lineGraph:self valueForPointAtIndex:i];
                    for (NSNumber *pointValue in pointsArray) {
                        if ([pointValue doubleValue] == XMYNullGraphValue) {
                            continue;
                        }
                        
                        if ([pointValue doubleValue] < minValue) {
                            minValue = [pointValue doubleValue];
                        }
                    }
                }   else {
                    if (0 < minValue) {
                        minValue = 0;
                    }
                }
            }
        }
        return minValue;
    }
}

- (CGFloat)yPositionForDotValue:(CGFloat)dotValue {
    if (dotValue == XMYNullGraphValue) {
        return XMYNullGraphValue;
    }
    
    CGFloat positionOnYAxis;
    CGFloat topPadding = 10;
    CGFloat bottomPadding = 10;
    
    if ([self.delegate respondsToSelector:@selector(staticTopPaddingForLineGraph:)])
        topPadding = [self.delegate staticTopPaddingForLineGraph:self];
    
    if ([self.delegate respondsToSelector:@selector(staticBottomPaddingForLineGraph:)])
        bottomPadding = [self.delegate staticBottomPaddingForLineGraph:self];
    
    if (self.displayXLabel) {
        if ([self.dataSource respondsToSelector:@selector(lineGraph:labelOnXAxisForIndex:)]) {
            if ([xLabels count] > 0) {
                UILabel *label = [xLabels objectAtIndex:0];
                self.xLabelYOffset = label.frame.size.height + self.widthLine;
            }
        }
    }
    
    if (self.minValue == self.maxValue && self.autoScaleY == YES) positionOnYAxis = self.frame.size.height/2;
    else if (self.autoScaleY == YES) positionOnYAxis = ((self.frame.size.height - bottomPadding) - ((dotValue - self.minValue) / ((self.maxValue - self.minValue) / (self.frame.size.height - (topPadding + bottomPadding))))) + self.xLabelYOffset/2;
    else positionOnYAxis = ((self.frame.size.height) - dotValue);
    
    positionOnYAxis -= self.xLabelYOffset;
    if (isnan(positionOnYAxis)) {
        return 0;
    }else return positionOnYAxis;
}
@end
