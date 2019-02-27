//
//  YxlPieChart.m
//  YxlPieChart
//
//  Created by 易小林 on 2019/2/27.
//  Copyright © 2019年 yxl. All rights reserved.
//

#import "YxlPieChart.h"

#define DATA_WIDTH 90
#define DATA_HEIGHT 30
#define CENTER_RADIUS 80

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@implementation YxlPieChart {
    NSArray<NSString *> *_dataArray;
    NSArray<UIColor *> *_colorArray;
    
    NSMutableArray<NSValue *> *_startPointArray;
    NSMutableArray<NSValue *> *_breakPointArray;
    
    NSMutableArray<NSNumber *> *_angleArray;
    NSMutableArray<NSNumber *> *_radianCenterArray;
    
    NSMutableArray<NSValue *> *_dataRectArray;
    
    CGFloat _pieRadius;
    CGPoint _pieCenter;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initData];
    }
    return self;
}

- (void) setDataArray:(NSArray<NSString *> *)dataArray {
    if (dataArray.count > 0) {
        _dataArray = dataArray;
    } else {
        _dataArray = @[@"0.01", @"0.01", @"0.98"];
    }
    
    [self setData];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setNeedsDisplay];
}

- (void) setData {
    CGFloat start = 0;
    CGFloat angle = 0;
    CGFloat end = 0;
    
    CGRect currentRect = CGRectZero;
    
    for (int i = 0; i < _dataArray.count; i++) {
        start = end;
        CGFloat percent = _dataArray[i].floatValue;
        start = end;
        angle = percent * M_PI * 2;
        
        end = start + angle;
        
        [_angleArray addObject:[NSNumber numberWithFloat:angle]];
        
        // 获取弧度的中心角度
        CGFloat radianCenter = (start + end) * 0.5;
        [_radianCenterArray addObject:[NSNumber numberWithFloat:radianCenter]];
        
        // 获取指引线的起点
        CGFloat pointX = self.frame.size.width * 0.5 + (_pieRadius + 10)  * cos(radianCenter);
        CGFloat pointY = self.frame.size.height * 0.5 + (_pieRadius + 10)  * sin(radianCenter);
        CGPoint point = CGPointMake(pointX, pointY);
        [_startPointArray addObject:[NSValue valueWithCGPoint:point]];
        
        CGFloat breakPointX = point.x + 10 * cos(radianCenter);
        CGFloat breakPointY = point.y + 10 * sin(radianCenter);
        currentRect = [self getCurrentRectByX:breakPointX Y:breakPointY];
        
        CGPoint breakPoint = CGPointMake(breakPointX, currentRect.origin.y + DATA_HEIGHT + 10);
        [_breakPointArray addObject:[NSValue valueWithCGPoint:breakPoint]];
        
        
        [_dataRectArray addObject:[NSValue valueWithCGRect:currentRect]];
    }
}

- (void) initData {
    _colorArray = @[UIColorFromRGB(0xF6CD4C), UIColorFromRGB(0x4DD8C1), UIColorFromRGB(0x5296EF)];
    _angleArray = [NSMutableArray array];
    _radianCenterArray = [NSMutableArray array];
    _startPointArray = [NSMutableArray array];
    _breakPointArray = [NSMutableArray array];
    _dataRectArray = [NSMutableArray array];
    
    CGFloat min = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height : self.bounds.size.width;
    _pieCenter =  CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    _pieRadius = min * 0.5 - 60;
}

- (CGRect) getCurrentRectByX:(CGFloat)breakPointX Y:(CGFloat)breakPointY {
    CGFloat dataX = 0;
    CGFloat dataY = 0;
    CGFloat margin = 0;
    
    if (breakPointX < self.bounds.size.width/2.0) {
        dataX = 10;
    } else {
        dataX = self.bounds.size.width - 10 - DATA_WIDTH;
    }
    dataY = breakPointY - 10 - DATA_HEIGHT;
    
    CGRect newRect = CGRectMake(dataX, dataY, DATA_WIDTH, DATA_HEIGHT);
    if (_dataRectArray.count > 0) {
        for (NSValue *rectValue in _dataRectArray) {
            CGRect preRect = [rectValue CGRectValue];
            
            if (CGRectIntersectsRect(preRect, newRect)) {
                if (CGRectGetMaxY(newRect) > preRect.origin.y && newRect.origin.y < preRect.origin.y) { // 压在总位置上面
                    margin = CGRectGetMaxY(newRect) - preRect.origin.y + 10;
                    dataY -= margin;
                } else if (newRect.origin.y < CGRectGetMaxY(preRect) &&  CGRectGetMaxY(newRect) > CGRectGetMaxY(preRect)) {  // 压总位置下面
                    margin = CGRectGetMaxY(preRect) - newRect.origin.y + 10;
                    dataY += margin;
                }
            }
        }
    }
    
    newRect = CGRectMake(dataX, dataY, DATA_WIDTH, DATA_HEIGHT);
    return newRect;
}

- (void) drawRect:(CGRect)rect {
    [self drawCenter];
    [self drawCenterMaskView];
    [self drawLine];
    [self drawPoint];
    [self addDataView];
}

- (void) drawCenter {
    float start = 0;
    float end = 0;
    float angle = 0;
    
    for (int i = 0; i < _angleArray.count; i++) {
        start = end;
        angle = _angleArray[i].floatValue;
        end = start + angle;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:_pieCenter radius:_pieRadius startAngle:start endAngle:end clockwise:YES];
        [_colorArray[i] set];
        [path addLineToPoint:_pieCenter];
        [path fill];
    }
}

- (void) drawCenterMaskView {
    UIView *centerMaskView1 = [[UIView alloc] init];
    centerMaskView1.frame = CGRectMake(_pieCenter.x - CENTER_RADIUS/2.0, _pieCenter.y - CENTER_RADIUS/2.0, CENTER_RADIUS, CENTER_RADIUS);
    centerMaskView1.backgroundColor = UIColorFromRGBA(0xffffff, 0.5);
    centerMaskView1.layer.cornerRadius = CENTER_RADIUS/2.0;
    centerMaskView1.layer.masksToBounds = YES;
    [self addSubview:centerMaskView1];
    
    UIView *centerMaskView2 = [[UIView alloc] init];
    centerMaskView2.frame = CGRectMake(_pieCenter.x - (CENTER_RADIUS - 10)/2.0, _pieCenter.y - (CENTER_RADIUS - 10)/2.0, CENTER_RADIUS - 10, CENTER_RADIUS - 10);
    centerMaskView2.backgroundColor = UIColorFromRGBA(0xffffff, 1);
    centerMaskView2.layer.cornerRadius = (CENTER_RADIUS - 10)/2.0;
    centerMaskView2.layer.masksToBounds = YES;
    [self addSubview:centerMaskView2];
}

- (void) drawPoint {
    UIColor *color = UIColorFromRGB(0x999999);
    for (int i = 0; i < _startPointArray.count; i++) {
        NSValue *value = _startPointArray[i];
        CGPoint point = [value CGPointValue];
        
        // 在终点处添加点(小圆点)
        // movePoint，让转折线指向小圆点中心
        CGFloat movePoint = -2.5;
        
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = color;
        [self addSubview:view];
        CGRect contentRect = view.frame;
        contentRect.size = CGSizeMake(5, 5);
        contentRect.origin = CGPointMake(point.x + movePoint, point.y - 2.5);
        view.frame = contentRect;
        view.layer.cornerRadius = 2.5;
        view.layer.masksToBounds = true;
    }
}

- (void) drawLine {
    
    UIColor *color = UIColorFromRGB(0x999999);
    for (int i = 0; i < _startPointArray.count; i++) {
        NSValue *startValue = _startPointArray[i];
        CGPoint startPoint = [startValue CGPointValue];
        
        NSValue *breakValue = _breakPointArray[i];
        CGPoint breakPoint = [breakValue CGPointValue];
        
        //1.获取上下文
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //2.绘制路径
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(startPoint.x, startPoint.y)];
        [path addLineToPoint:CGPointMake(breakPoint.x, breakPoint.y)];
        
        if (breakPoint.x < self.bounds.size.width/2.0) {
            [path addLineToPoint:CGPointMake(10, breakPoint.y)];
        } else {
            [path addLineToPoint:CGPointMake(self.bounds.size.width - 10, breakPoint.y)];
        }
        
        CGContextSetLineWidth(ctx, 0.5);
        //设置颜色
        [color set];
        //3.把绘制的内容添加到上下文当中
        CGContextAddPath(ctx, path.CGPath);
        //4.把上下文的内容显示到View上(渲染到View的layer)(stroke fill)
        CGContextStrokePath(ctx);
    }
}

- (void) addDataView {
    for (int i = 0; i < _dataRectArray.count; i++) {
        NSValue *rectValue = _dataRectArray[i];
        CGRect rect = [rectValue CGRectValue];
        UIView *dataView = [[UIView alloc] init];
        dataView.frame = rect;
        dataView.backgroundColor = [UIColor clearColor];
        [self addSubview:dataView];
        
        UILabel *percentLabel = [[UILabel alloc] init];
        percentLabel.frame = CGRectMake(0, 0, rect.size.width, rect.size.height/2.0);
        percentLabel.font = [UIFont systemFontOfSize:10];
        percentLabel.textColor = UIColorFromRGB(0x999999);
        percentLabel.text = [NSString stringWithFormat:@"%.2f%%", _dataArray[i].floatValue*100];
        [dataView addSubview:percentLabel];
        
        UILabel *dataLabel = [[UILabel alloc] init];
        dataLabel.frame = CGRectMake(0, rect.size.height/2.0, rect.size.width, rect.size.height/2.0);
        dataLabel.font = [UIFont systemFontOfSize:10];
        dataLabel.textColor = UIColorFromRGB(0x999999);
        dataLabel.text = _dataArray[i];
        [dataView addSubview:dataLabel];
        
        if (rect.origin.x < self.bounds.size.width/2.0) {
            percentLabel.textAlignment = NSTextAlignmentLeft;
            dataLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            percentLabel.textAlignment = NSTextAlignmentRight;
            dataLabel.textAlignment = NSTextAlignmentRight;
        }
    }
}



@end
