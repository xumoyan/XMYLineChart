//
//  XMYLine.h
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
#import "XMYAverageLine.h"

///展示图线时候的动画类型
typedef NS_ENUM(NSInteger, XMYLineAnimation){
    //绘线的动画从左到右，从下到上
    XMYLineAnimationDraw,
    //从0%的透明到100%的透明
    XMYLineAnimationFade,
    //线宽从一点逐渐扩展到线的设置宽度
    XMYLineAnimationExpand,
    //在展示的过程中不使用动画
    XMYLineAnimationNone
};
///如果使用了梯度，顺着梯度的方向来画线
typedef NS_ENUM(NSInteger, XMYLineGradientDirection){
    //横向
    XMYLineGradientDirectionHorizontal = 0,
    //纵向
    XMYLineGradientDirectionVertical = 1
};

@interface XMYLine : UIView

///////////////////////////////////
////////////POINT//////////////////
///////////////////////////////////

///点在坐标Y轴的数值数组
@property (nonatomic, strong) NSArray *arrayOfPoints;
///在X轴显示点的坐标的数组
@property (nonatomic, strong) NSArray *arrayOfVerticalPoints;
///抵消边界坐标轴坐标的移动
@property (nonatomic, assign) CGFloat verticalReference;
///在Y轴显示点的坐标的数组
@property (nonatomic, strong) NSArray *arrayOfHorizontalPoints;
///点对应的值
@property (nonatomic, strong) NSArray *arrayOfValues;
///是否展示参考线
@property (nonatomic, assign) BOOL displayRefrenceLines;
///是否展示X轴、Y轴的参考线
@property (nonatomic, assign) BOOL displayRefrenceXYLines;
///是否展示左边参考线
@property (nonatomic, assign) BOOL displayLeftReferenceLine;
///是否展示下边参考线
@property (nonatomic, assign) BOOL displayBottomReferenceLine;
///是否展示右边参考线
@property (nonatomic, assign) BOOL displayRightReferenceLine;
///是否展示上边参考线
@property (nonatomic, assign) BOOL displayTopReferenceLine;
///参考线虚线X轴
@property (nonatomic, strong) NSArray *linePatternForReferenceXAxisLines;
///参考线虚线Y轴
@property (nonatomic, strong) NSArray *linePatternForReferenceYAxisLines;
///对空Value是否插入一个辅助值
@property (nonatomic, assign) BOOL interpolateNullValues;
///是否永远显示连接图形
@property (nonatomic, assign) BOOL alwaysDisplayGraphs;

///////////////////////////////////
///////////COLORS//////////////////
///////////////////////////////////

///连接线的颜色
@property (nonatomic, strong) UIColor *lineColor;
///连接线颜色数组
@property (nonatomic, strong) NSArray *colorLineArray;
///连接线上方的颜色
@property (nonatomic, strong) UIColor *topColor;
///连接线上方的渐变
@property (nonatomic, assign) CGGradientRef topGradient;
///连接线下方的颜色
@property (nonatomic, strong) UIColor *bottomColor;
///连接线下方的渐变
@property (nonatomic, assign) CGGradientRef bottomGradient;
///线的渐变
@property (nonatomic, assign) CGGradientRef lineGradient;
///线简便的方向：纵向、横向
@property (nonatomic, assign) XMYLineGradientDirection lineGradientDirection;
///参考线XY的颜色
@property (nonatomic, strong) UIColor *refrenceLineColor;

///////////////////////////////////
////////////ALPHA//////////////////
///////////////////////////////////

///连接线的透明度
@property (nonatomic, assign) float lineAlpha;
///连接线上方的透明度
@property (nonatomic, assign) float lineTopAlpha;
///连接线下方的透明度
@property (nonatomic, assign) float lineBottomAlpha;

///////////////////////////////////
/////////////SIZE//////////////////
///////////////////////////////////

///连接线的宽度
@property (nonatomic, assign) float lineWidth;
///参考线XY的宽度
@property (nonatomic, assign) float referenceLineWidth;

///////////////////////////////////
/////////BEZIER CURVE//////////////
///////////////////////////////////

///是否采用贝塞尔曲线
@property (nonatomic, assign) BOOL bezierCurve;

///////////////////////////////////
///////////ANIMATION///////////////
///////////////////////////////////

///动画时间
@property (nonatomic, assign) float animationTime;
///动画类型
@property (nonatomic, assign) XMYLineAnimation animationType;

///////////////////////////////////
////////////AVERAGE////////////////
///////////////////////////////////

///平均线
@property (nonatomic, strong) XMYAverageLine *averageLine;
///平均线在Y轴的坐标位置
@property (nonatomic, assign) CGFloat averageLineYPosition;

@end
