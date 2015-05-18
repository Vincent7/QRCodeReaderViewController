/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderView.h"

@interface QRCodeReaderView ()
@property (nonatomic, strong) CAShapeLayer *overlay;
@property (nonatomic, strong) CAShapeLayer *masklay;
@end

@implementation QRCodeReaderView{
    float rectWidth;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self addOverlay];
        
    }
  
  return self;
}

- (void)drawRect:(CGRect)rect{
    CGRect innerRect = CGRectInset(rect, 50, 30);

    CGFloat minSize = MIN(innerRect.size.width, innerRect.size.height);
    
    if (innerRect.size.width != minSize) {
        innerRect.origin.x   += (innerRect.size.width - minSize) / 2;
        innerRect.size.width = minSize;
    }
    else if (innerRect.size.height != minSize) {
        innerRect.origin.y    += (innerRect.size.height - minSize) / 2;
        innerRect.size.height = minSize;
    }
    rectWidth = minSize;
    CGRect offsetRect = CGRectOffset(innerRect, 0, 15);

    _overlay.lineDashPattern = @[@(rectWidth/3), @(rectWidth*2/3)];
    _overlay.lineDashPhase   = rectWidth/6;
    _overlay.path = [UIBezierPath bezierPathWithRoundedRect:offsetRect cornerRadius:0].CGPath;
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, 0);//移动到指定位置（设置路径起点）
    CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, self.bounds.size.width, self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, self.bounds.size.width, 0);
    CGPathAddLineToPoint(path, nil, 0, 0);
    
    float offDistance = 9;
    CGPathMoveToPoint(path, nil,
                      innerRect.origin.x - _overlay.lineWidth/2,
                      innerRect.origin.y + offDistance + _overlay.lineWidth * 3/2);
    CGPathAddLineToPoint(path, nil,
                         innerRect.origin.x - _overlay.lineWidth/2 + innerRect.size.width + _overlay.lineWidth,
                         innerRect.origin.y + offDistance + _overlay.lineWidth * 3/2);
    CGPathAddLineToPoint(path, nil,
                         innerRect.origin.x - _overlay.lineWidth/2 + innerRect.size.width + _overlay.lineWidth,
                         innerRect.origin.y + offDistance + _overlay.lineWidth * 3/2 + innerRect.size.height + _overlay.lineWidth);
    CGPathAddLineToPoint(path, nil,
                         innerRect.origin.x - _overlay.lineWidth/2,
                         innerRect.origin.y + offDistance + _overlay.lineWidth * 3/2 + innerRect.size.height + _overlay.lineWidth);
    CGPathAddLineToPoint(path, nil,
                         innerRect.origin.x - _overlay.lineWidth/2,
                         innerRect.origin.y + offDistance + _overlay.lineWidth * 3/2);
    
    //3.添加路径到图形上下文
//    CGContextAddPath(context, path);
    _masklay.path = path;
    
}

#pragma mark - Private Methods

- (void)addOverlay{
    
    _overlay = [[CAShapeLayer alloc] init];
    _overlay.backgroundColor = [UIColor clearColor].CGColor;
    _overlay.fillColor       = [UIColor clearColor].CGColor;
    _overlay.strokeColor     = [UIColor whiteColor].CGColor;
    _overlay.lineWidth       = 3;

    _masklay = [[CAShapeLayer alloc] init];
    _masklay.backgroundColor = [UIColor clearColor].CGColor;
    _masklay.fillColor       = kRGBA(0x00000080).CGColor;
    _masklay.strokeColor     = [UIColor clearColor].CGColor;
    _masklay.lineWidth       = 0;
  
    [self.layer addSublayer:_overlay];
    [self.layer addSublayer:_masklay];
}

@end
