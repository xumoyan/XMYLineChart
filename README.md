##XMYLineChart
`XMYLineChart `是定制化折线图的一个开源项目。项目参考： [Boris Emorine](https://github.com/Boris-Em/BEMSimpleLineGraph)<br>Boris Emorine其实已经写的非常详细，但有些功能没有添加进去。针对这些功能我写了`XMYLineChart `。虽然说我已经尽力考虑到了一大部分折线图的定制化，但是总还有一些我没有想到的东西。如果你觉得还有哪些需要添加也希望你能够加入这个开源项目。

###效果图
![](https://github.com/xumoyan/XMYLineChart/blob/master/LineChartPicture/lineOne.png)
![](https://github.com/xumoyan/XMYLineChart/blob/master/LineChartPicture/lineTwo.png)
![](https://github.com/xumoyan/XMYLineChart/blob/master/LineChartPicture/lineThree.png)

###CocoaPods
推荐使用pod方式将XMYLineChart添加到你的项目中。<br>
1. 将XMYLineChart添加到你的Podfile文件 `pod 'XMYLineChart', '~> 0.0.2'`<br>
2. 安装pod运行`pod install`<br>
3. pod下来以后通过引入`#import "XMYLineChart.h"` 使用
###部分功能列表
#####1.多条折线
返回折线的数量<br>
`- (NSInteger)numberOfLineGraph:(XMYLineChartView *)graph;`
#####2.显示点数组
返回对应折线的数据<br>
`- (NSArray *)lineGraph:(XMYLineChartView *)graph valueForPointAtIndex:(NSInteger)index;`
#####3.X轴标签展示文字
返回X轴标签对应点的展示文字<br>
`- (nullable NSString *)lineGraph:(nonnull XMYLineChartView *)graph labelOnXAxisForIndex:(NSInteger)index;`
#####4.弹出框信息
弹出框信息前缀：<br>
`- (NSArray *)popUpPrefixForlineGraph:(XMYLineChartView *)graph;`<br>
弹出框信息后缀：<br>
`- (NSArray *)popUpSuffixForlineGraph:(XMYLineChartView *)graph;`<br>
自定义弹框是否展示：<br>
`- (BOOL)lineGraph:(XMYLineChartView *)graph alwaysDisplayPopUpAtIndex:(CGFloat)index`<br>
自定义弹出框：<br>
`- (UIView *)popUpViewForLineGraph:(XMYLineChartView *)graph;`<br>
自定义弹出框根据index值做不通处理：<br>
`- (void)lineGraph:(XMYLineChartView *)graph modifyPopupView:(UIView *)popupView forIndex:(NSUInteger)index;`<br>
注：弹出框前缀、后缀数据以折线数量为单位。
#####5.Y轴最大值、最小值
最大值：<br>
`- (CGFloat)maxValueForLineGraph:(XMYLineChartView *)graph;`<br>
最小值：<br>
`- (CGFloat)minValueForLineGraph:(XMYLineChartView *)graph;`
#####6.X轴标签展示
展示模式：<br>
`- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(XMYLineChartView *)graph;`<br>
开始位置：<br>
`- (NSInteger)baseIndexForXAxisOnLineGraph:(XMYLineChartView *)graph;`<br>
开始位置实现情况下两个展示点之间间隔了多少个点：<br>
`- (NSInteger)incrementIndexForXAxisOnLineGraph:(XMYLineChartView *)graph;`<br>
自定义X轴展示标签数组：<br>
`- (NSArray *)incrementPositionsForXAxisOnLineGraph:(XMYLineChartView *)graph;`<br>
注：自定义X轴展示标签代理方法优先级更高。
#####7.Y轴标签展示
Y轴标签展示数量：<br>
`- (NSInteger)numberOfYAxisLabelsOnLineGraph:(XMYLineChartView *)graph;`<br>
Y轴标签信息前缀：<br>
`- (NSString *)yAxisPrefixOnLineGraph:(XMYLineChartView *)graph;`<br>
Y轴标签信息后缀：<br>
`- (NSString *)yAxisSuffixOnLineGraph:(XMYLineChartView *)graph;`<br>
自定义Y轴标签从第几个开始：<br>
`- (CGFloat)baseValueForYAxisOnLineGraph:(XMYLineChartView *)graph;`<br>
baseValueForYAxisOnLineGraph实现情况下，两个标签之间间隔了多少个点：<br>
`- (CGFloat)incrementValueForYAxisOnLineGraph:(XMYLineChartView *)graph;`
#####8.其他属性和代理方法
其他属性和代理方法的注释都已经在代码中，根据你的实际需求去定制化。
###使用方式
1.纯代码方式：引入头文件，遵循代理，实现代理方法。<br>
2.storyboard方式：在user defined runtime attributes中实现属性控制。
##License
这段代码在遵循[MIT license](LICENSE)许可条款和条件下发布的。
