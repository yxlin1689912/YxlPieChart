# YxlPieChart
自定义饼图

1、按百分比画圆弧度：

UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:start endAngle:end clockwise:YES];

            [color set];

            [path addLineToPoint:center];

            [path fill];

2、添加圆心遮挡：

3、画折线跟引线：

    //1.获取上下文

        CGContextRef ctx = UIGraphicsGetCurrentContext();

        //2.绘制路径

        UIBezierPath *path = [UIBezierPath bezierPath];

        [path moveToPoint:CGPointMake(endX, endY)];

        [path addLineToPoint:CGPointMake(breakPointX, breakPointY)];

        [path addLineToPoint:CGPointMake(startX, startY)];

        CGContextSetLineWidth(ctx, 0.5);

        //设置颜色

        [color set];

        //3.把绘制的内容添加到上下文当中

        CGContextAddPath(ctx, path.CGPath);

        //4.把上下文的内容显示到View上(渲染到View的layer)(stroke fill)

        CGContextStrokePath(ctx);

4、折线起始位置添加圆点；

5、在引线周围添加文本。

注意事项：

1、当前文本区域要跟前面所有文本区域比较是否有相交，相交后要调整当前文本区域；

2、图表内的圆点、文本、圆心遮挡、引线等既可以画也可以添加View的方式；

3、调整好圆弧半径及文本区域高宽，避免界面遮挡。
