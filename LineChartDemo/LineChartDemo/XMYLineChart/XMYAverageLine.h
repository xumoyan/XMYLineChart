//
//  XMYAverageLine.h
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

@interface XMYAverageLine : NSObject
///是否在Y轴上展示平均线
@property (nonatomic, assign) BOOL displayAverageLine;
///平均线的颜色
@property (nonatomic, strong) UIColor *averageLineColor;
///这条线可以是一个平均线、中位线或者一个总结、模型
@property (nonatomic, assign) CGFloat modeValue;
///平均线的的透明度
@property (nonatomic, assign) CGFloat averageAlpha;
///平均线的宽度
@property (nonatomic, assign) CGFloat averageWidth;
///平均线的模式数组
@property (nonatomic, strong) NSArray *averageLinePattern;
@end
