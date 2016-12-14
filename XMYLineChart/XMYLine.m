//
//  XMYLine.m
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

#import "XMYLine.h"

#if CGFLOAT_IS_DOUBLE
#define CGFloatValue doubleValue
#else
#define CGFloatValue floatValue
#endif

@interface XMYLine()
{
    UIBezierPath *sendLine;
}
///取值于arrayOfPoints
@property (nonatomic, strong) NSMutableArray *points;

@end

@implementation XMYLine

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _displayLeftReferenceLine = YES;
        _displayBottomReferenceLine = YES;
        _interpolateNullValues = YES;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    ///////////////////////////////////
    //////DRAW REFRENCE LINE///////////
    ///////////////////////////////////
    UIBezierPath *verticalReferenceLinesPath = [UIBezierPath bezierPath];
    UIBezierPath *horizontalReferenceLinesPath = [UIBezierPath bezierPath];
    UIBezierPath *referenceFramePath = [UIBezierPath bezierPath];
    
    verticalReferenceLinesPath.lineCapStyle = kCGLineCapButt;
    verticalReferenceLinesPath.lineWidth = 0.7;
    
    horizontalReferenceLinesPath.lineCapStyle = kCGLineCapButt;
    horizontalReferenceLinesPath.lineWidth = 0.7;
    
    referenceFramePath.lineCapStyle = kCGLineCapButt;
    referenceFramePath.lineWidth = 0.7;
    
    if (self.displayRefrenceXYLines == YES) {
        if (self.displayBottomReferenceLine) {
            [referenceFramePath moveToPoint:CGPointMake(0, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        }
        
        if (self.displayLeftReferenceLine) {
            [referenceFramePath moveToPoint:CGPointMake(0+self.referenceLineWidth/4, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(0+self.referenceLineWidth/4, 0)];
        }
        
        if (self.displayTopReferenceLine) {
            [referenceFramePath moveToPoint:CGPointMake(0+self.referenceLineWidth/4, 0)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        }
        if (self.displayRightReferenceLine) {
            [referenceFramePath moveToPoint:CGPointMake(self.frame.size.width - self.referenceLineWidth/4, self.frame.size.height)];
            [referenceFramePath addLineToPoint:CGPointMake(self.frame.size.width - self.referenceLineWidth/4, 0)];
        }
    }
    
    if (self.displayRefrenceLines == YES) {
        if (self.arrayOfVerticalPoints.count > 0) {
            for (NSNumber *xNumber in self.arrayOfVerticalPoints) {
                CGFloat xValue;
                if (self.verticalReference != 0.0) {
                    if ([self.arrayOfVerticalPoints indexOfObject:xNumber] == 0) {
                        xValue = [xNumber floatValue] + self.verticalReference;
                    } else if ([self.arrayOfVerticalPoints indexOfObject:xNumber] == [self.arrayOfVerticalPoints count]-1) {
                        xValue = [xNumber floatValue] - self.verticalReference;
                    } else xValue = [xNumber floatValue];
                } else xValue = [xNumber floatValue];
                
                CGPoint initialPoint = CGPointMake(xValue, self.frame.size.height);
                CGPoint finalPoint = CGPointMake(xValue, 0);
                
                [verticalReferenceLinesPath moveToPoint:initialPoint];
                [verticalReferenceLinesPath addLineToPoint:finalPoint];
            }
        }
    }
    
    if (self.arrayOfHorizontalPoints.count > 0) {
        for (NSNumber *yNumber in self.arrayOfHorizontalPoints) {
            CGPoint initialPoint = CGPointMake(0, [yNumber floatValue]);
            CGPoint finalPoint = CGPointMake(self.frame.size.width, [yNumber floatValue]);
            
            [horizontalReferenceLinesPath moveToPoint:initialPoint];
            [horizontalReferenceLinesPath addLineToPoint:finalPoint];
        }
    }
    
    
    ///////////////////////////////////
    ///////DRAW AVERAGE LINE///////////
    ///////////////////////////////////
    UIBezierPath *averageLinePath = [UIBezierPath bezierPath];
    if (self.averageLine.displayAverageLine == YES) {
        averageLinePath.lineCapStyle = kCGLineCapButt;
        averageLinePath.lineWidth = self.averageLine.averageWidth;
        
        CGPoint initialPoint = CGPointMake(0, self.averageLineYPosition);
        CGPoint finalPoint = CGPointMake(self.frame.size.width, self.averageLineYPosition);
        
        [averageLinePath moveToPoint:initialPoint];
        [averageLinePath addLineToPoint:finalPoint];
    }
    
    ///////////////////////////////////
    /////////DRAW GRAPH LINE///////////
    ///////////////////////////////////
    
    for (NSMutableArray *pointArray in self.arrayOfPoints) {
        UIBezierPath *line = [UIBezierPath bezierPath];
        UIBezierPath *fillTop = [UIBezierPath bezierPath];
        UIBezierPath *fillBottom = [UIBezierPath bezierPath];
        CGFloat xIndexScale = self.frame.size.width/([pointArray count] - 1);
        self.points = [NSMutableArray arrayWithCapacity:pointArray.count];
        for (int i = 0; i < pointArray.count; i++) {
            CGPoint value = CGPointMake(xIndexScale * i, [pointArray[i] CGFloatValue]);
            if (value.y != CGFLOAT_MAX || !self.interpolateNullValues) {
                [self.points addObject:[NSValue valueWithCGPoint:value]];
            }
        }
        
        BOOL bezierStatus = self.bezierCurve;
        if (pointArray.count <= 2 && self.bezierCurve == YES) bezierStatus = NO;
        if (!self.alwaysDisplayGraphs && bezierStatus) {
            line = [XMYLine quadCurvedPathWithPoints:self.points];
            fillBottom = [XMYLine quadCurvedPathWithPoints:self.bottomPointsArray];
            fillTop = [XMYLine quadCurvedPathWithPoints:self.topPointsArray];
        }else if (!self.alwaysDisplayGraphs && !bezierStatus) {
            line = [XMYLine linesToPoints:self.points];
            fillBottom = [XMYLine linesToPoints:self.bottomPointsArray];
            fillTop = [XMYLine linesToPoints:self.topPointsArray];
        }else {
            fillBottom = [XMYLine linesToPoints:self.bottomPointsArray];
            fillTop = [XMYLine linesToPoints:self.topPointsArray];
        }
        [self.topColor set];
        [fillTop fillWithBlendMode:kCGBlendModeNormal alpha:self.lineTopAlpha];
        
        [self.bottomColor set];
        [fillBottom fillWithBlendMode:kCGBlendModeNormal alpha:self.lineBottomAlpha];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (self.topGradient != nil) {
            CGContextSaveGState(ctx);
            CGContextAddPath(ctx, [fillTop CGPath]);
            CGContextClip(ctx);
            CGContextDrawLinearGradient(ctx, self.topGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillTop.bounds)), 0);
            CGContextRestoreGState(ctx);
        }
        
        if (self.bottomGradient != nil) {
            CGContextSaveGState(ctx);
            CGContextAddPath(ctx, [fillBottom CGPath]);
            CGContextClip(ctx);
            CGContextDrawLinearGradient(ctx, self.bottomGradient, CGPointZero, CGPointMake(0, CGRectGetMaxY(fillBottom.bounds)), 0);
            CGContextRestoreGState(ctx);
        }
        
        if (self.alwaysDisplayGraphs == NO) {
            CAShapeLayer *pathLayer = [CAShapeLayer layer];
            pathLayer.frame = self.bounds;
            pathLayer.path = line.CGPath;
            if (self.colorLineArray.count == self.arrayOfPoints.count) {
                UIColor *color = self.colorLineArray[[self.arrayOfPoints indexOfObject:pointArray]];
                self.lineColor = self.colorLineArray[0];
                 pathLayer.strokeColor = color.CGColor;
            }else{
                 pathLayer.strokeColor = self.lineColor.CGColor;
            }
           
            pathLayer.fillColor = nil;
            pathLayer.opacity = self.lineAlpha;
            pathLayer.lineWidth = self.lineWidth;
            pathLayer.lineJoin = kCALineJoinBevel;
            pathLayer.lineCap = kCALineCapRound;
            if (self.animationTime > 0) [self animateForLayer:pathLayer withAnimationType:self.animationType isAnimatingReferenceLine:NO];
            if (self.lineGradient) [self.layer addSublayer:[self backgroundGradientLayerForLayer:pathLayer]];
            else [self.layer addSublayer:pathLayer];
        }
    }
    
    ///////////////////////////////////
    /////////////ANIMATE///////////////
    ///////////////////////////////////
    if (self.displayRefrenceLines == YES) {
        CAShapeLayer *verticalReferenceLinesPathLayer = [CAShapeLayer layer];
        verticalReferenceLinesPathLayer.frame = self.bounds;
        verticalReferenceLinesPathLayer.path = verticalReferenceLinesPath.CGPath;
        verticalReferenceLinesPathLayer.opacity = self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2;
        verticalReferenceLinesPathLayer.fillColor = nil;
        verticalReferenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;
        
        if (self.linePatternForReferenceYAxisLines) {
            verticalReferenceLinesPathLayer.lineDashPattern = self.linePatternForReferenceYAxisLines;
        }
        
        if (self.refrenceLineColor) {
            verticalReferenceLinesPathLayer.strokeColor = self.refrenceLineColor.CGColor;
        } else {
            verticalReferenceLinesPathLayer.strokeColor = self.lineColor.CGColor;
        }
        
        if (self.animationTime > 0)
            [self animateForLayer:verticalReferenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
        [self.layer addSublayer:verticalReferenceLinesPathLayer];
        
        
        CAShapeLayer *horizontalReferenceLinesPathLayer = [CAShapeLayer layer];
        horizontalReferenceLinesPathLayer.frame = self.bounds;
        horizontalReferenceLinesPathLayer.path = horizontalReferenceLinesPath.CGPath;
        horizontalReferenceLinesPathLayer.opacity = self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2;
        horizontalReferenceLinesPathLayer.fillColor = nil;
        horizontalReferenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;
        if(self.linePatternForReferenceXAxisLines) {
            horizontalReferenceLinesPathLayer.lineDashPattern = self.linePatternForReferenceXAxisLines;
        }
        
        if (self.refrenceLineColor) {
            horizontalReferenceLinesPathLayer.strokeColor = self.refrenceLineColor.CGColor;
        } else {
            horizontalReferenceLinesPathLayer.strokeColor = self.lineColor.CGColor;
        }
        
        if (self.animationTime > 0)
            [self animateForLayer:horizontalReferenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
        [self.layer addSublayer:horizontalReferenceLinesPathLayer];
    }
    
    CAShapeLayer *referenceLinesPathLayer = [CAShapeLayer layer];
    referenceLinesPathLayer.frame = self.bounds;
    referenceLinesPathLayer.path = referenceFramePath.CGPath;
    referenceLinesPathLayer.opacity = self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2;
    referenceLinesPathLayer.fillColor = nil;
    referenceLinesPathLayer.lineWidth = self.referenceLineWidth/2;
    
    if (self.refrenceLineColor) referenceLinesPathLayer.strokeColor = self.refrenceLineColor.CGColor;
    else referenceLinesPathLayer.strokeColor = self.lineColor.CGColor;
    
    if (self.animationTime > 0)
        [self animateForLayer:referenceLinesPathLayer withAnimationType:self.animationType isAnimatingReferenceLine:YES];
    [self.layer addSublayer:referenceLinesPathLayer];
    
    
    
    if (self.averageLine.displayAverageLine == YES) {
        CAShapeLayer *averageLinePathLayer = [CAShapeLayer layer];
        averageLinePathLayer.frame = self.bounds;
        averageLinePathLayer.path = averageLinePath.CGPath;
        averageLinePathLayer.opacity = self.averageLine.averageAlpha;
        averageLinePathLayer.fillColor = nil;
        averageLinePathLayer.lineWidth = self.averageLine.averageWidth;
        
        if (self.averageLine.averageLinePattern) averageLinePathLayer.lineDashPattern = self.averageLine.averageLinePattern;
        
        if (self.averageLine.averageLineColor) averageLinePathLayer.strokeColor = self.averageLine.averageLineColor.CGColor;
        else averageLinePathLayer.strokeColor = self.lineColor.CGColor;
        
        if (self.animationTime > 0)
            [self animateForLayer:averageLinePathLayer withAnimationType:self.animationType isAnimatingReferenceLine:NO];
        [self.layer addSublayer:averageLinePathLayer];
    }
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}
static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}


+ (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points {
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        
        p1 = p2;
    }
    return path;
}

- (NSArray *)bottomPointsArray {
    CGPoint bottomPointZero = CGPointMake(0, self.frame.size.height);
    CGPoint bottomPointFull = CGPointMake(self.frame.size.width, self.frame.size.height);
    NSMutableArray *bottomPoints = [NSMutableArray arrayWithArray:self.points];
    [bottomPoints insertObject:[NSValue valueWithCGPoint:bottomPointZero] atIndex:0];
    [bottomPoints addObject:[NSValue valueWithCGPoint:bottomPointFull]];
    return bottomPoints;
}

- (NSArray *)topPointsArray {
    CGPoint topPointZero = CGPointMake(0,0);
    CGPoint topPointFull = CGPointMake(self.frame.size.width, 0);
    NSMutableArray *topPoints = [NSMutableArray arrayWithArray:self.points];
    [topPoints insertObject:[NSValue valueWithCGPoint:topPointZero] atIndex:0];
    [topPoints addObject:[NSValue valueWithCGPoint:topPointFull]];
    return topPoints;
}

+ (UIBezierPath *)linesToPoints:(NSArray *)points {
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
    }
    return path;
}

- (void)animateForLayer:(CAShapeLayer *)shapeLayer withAnimationType:(XMYLineAnimation)animationType isAnimatingReferenceLine:(BOOL)shouldHalfOpacity {
    if (animationType == XMYLineAnimationNone) return;
    else if (animationType == XMYLineAnimationFade) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        if (shouldHalfOpacity == YES) pathAnimation.toValue = [NSNumber numberWithFloat:self.lineAlpha == 0 ? 0.1 : self.lineAlpha/2];
        else pathAnimation.toValue = [NSNumber numberWithFloat:self.lineAlpha];
        [shapeLayer addAnimation:pathAnimation forKey:@"opacity"];
        return;
    } else if (animationType == XMYLineAnimationExpand) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:shapeLayer.lineWidth];
        [shapeLayer addAnimation:pathAnimation forKey:@"lineWidth"];
        return;
    } else {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = self.animationTime;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        return;
    }
}

- (CALayer *)backgroundGradientLayerForLayer:(CAShapeLayer *)shapeLayer {
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    CGPoint start, end;
    if (self.lineGradientDirection == XMYLineGradientDirectionHorizontal) {
        start = CGPointMake(0, CGRectGetMidY(shapeLayer.bounds));
        end = CGPointMake(CGRectGetMaxX(shapeLayer.bounds), CGRectGetMidY(shapeLayer.bounds));
    } else {
        start = CGPointMake(CGRectGetMidX(shapeLayer.bounds), 0);
        end = CGPointMake(CGRectGetMidX(shapeLayer.bounds), CGRectGetMaxY(shapeLayer.bounds));
    }
    
    CGContextDrawLinearGradient(imageCtx, self.lineGradient, start, end, 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.contents = (id)image.CGImage;
    gradientLayer.mask = shapeLayer;
    return gradientLayer;
}

@end
