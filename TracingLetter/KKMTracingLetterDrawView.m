//
//  KKMTracingLetterDrawView.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/23/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "KKMTracingLetterDrawView.h"
#import "NSString+Glyphs.h"
#import "DeviceUtil.h"
#import "KKMTracingLetterConstants.h"

typedef enum : NSUInteger {
    TouchLifeCycleStateTypeBegin = 0,
    TouchLifeCycleStateTypeMoved,
    TouchLifeCycleStateTypeCancelled,
    TouchLifeCycleStateTypeEnded
} TouchLifeCycleStateTypeEnum;

CGFloat const KKMiPadLineWidth = 30.0f;
CGFloat const KKMiPhoneLineWidth = 20.0f;
CGFloat const KKMPathCopyLineWidth = 30.0f;

@interface KKMTracingLetterDrawView()

@property (nonatomic, strong) UIBezierPath  *traceLetterBezierPath;
@property (nonatomic, strong) UIBezierPath  *handWritingBezierPath;
@property (nonatomic, assign) NSInteger handWritingLineWidth;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) NSInteger countOfInvalidTouchPoints;

@end

@implementation KKMTracingLetterDrawView

#pragma mark - init
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _handWritingBezierPath = [UIBezierPath bezierPath];
        _handWritingStrokeColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - drawing

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self cleanUp];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self fontSizeAndLineWidth];
    [self drawTracingLetter];
    [self drawHandWritingLetter];
}

- (void)fontSizeAndLineWidth
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.fontSize = 550.f;
        self.handWritingLineWidth = KKMiPadLineWidth;
    }
    else
    {
        if ([DeviceUtil hardware] == IPHONE_4S)
            self.fontSize = 290.0f;
        else if([DeviceUtil hardware] == IPHONE_5 || [DeviceUtil hardware] == IPHONE_5S)
            self.fontSize = 320.0f;
        else
            self.fontSize = 380.0f;
        
        self.handWritingLineWidth = KKMiPhoneLineWidth;
    }
}

- (void)drawTracingLetter
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *string = self.letterString;
    UIFont *font = [UIFont fontWithName:self.fontNameString size:self.fontSize];

    self.traceLetterBezierPath = [string bezierPathWithFont:font bounds:self.bounds];
    // The path is upside down (CG coordinate system)
    CGRect boundingBox = CGPathGetBoundingBox(self.traceLetterBezierPath.CGPath);
    [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
    
    NSLog(@"%@", self.letterString);
    NSLog(@"self.bounds.width = %f; self.bounds.height = %f", self.bounds.size.width, self.bounds.size.height);
    NSLog(@"boundingBox.width = %f; boundingBox.height = %f", boundingBox.size.width, boundingBox.size.height);
    CGFloat x = (self.bounds.size.width - boundingBox.size.width) / 2;
    if (x < 0)
        x = 0;
    
    CGFloat y = 0;

    NSString *hint = [self presentationHint];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        y = self.bounds.size.height / 1.5;

        if ([hint isEqualToString:@"top"])
            y = (self.bounds.size.height) / 1.15;
    }
    else
    {
        if ([hint isEqualToString:@"top"] || [hint isEqualToString:@"top-iphone"])
            y = (self.bounds.size.height) / 1.15;
        else if ([hint isEqualToString:@"bottom"])
            y = (self.bounds.size.height) / 1.25;
        else
            y = (self.bounds.size.height) / 1.5;
    }
    [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeTranslation(x, y)];

    CGFloat buffer = 50.0f;
    if(boundingBox.size.height + buffer > self.bounds.size.height)
    {
        CGFloat scale = self.bounds.size.height / (boundingBox.size.height + buffer);
        [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeScale(scale, scale)];
    }
    else if(boundingBox.size.width + buffer > self.bounds.size.width)
    {
        CGFloat scale = (self.bounds.size.width / boundingBox.size.width) - 0.05;
        [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeScale(scale, scale)];
    }    
   
    CGContextAddPath(context, self.traceLetterBezierPath.CGPath);
    CGContextSetStrokeColorWithColor(context,[UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 4);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    //[self animate];
}

- (NSString *)presentationHint
{
    NSString *hint = self.dataDict[KKMValues][2][self.letterString];
    if (hint == nil)
        hint = self.dataDict[KKMValues][2][KKMAll];

    return hint;
}

- (void)drawHandWritingLetter
{
    [self.handWritingStrokeColor setStroke];
    [self.handWritingBezierPath setLineJoinStyle:kCGLineJoinRound];
    [self.handWritingBezierPath setLineCapStyle:kCGLineCapButt];
    [self.handWritingBezierPath setLineWidth:self.handWritingLineWidth];
    [self.handWritingBezierPath stroke];
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate drawViewTapped];
    [self handleTouch:touches withEvent:event withTouchLifeCycleStateTypeEnum:TouchLifeCycleStateTypeBegin];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouch:touches withEvent:event withTouchLifeCycleStateTypeEnum:TouchLifeCycleStateTypeMoved];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)handleTouch:(NSSet *)touches withEvent:(UIEvent *)event withTouchLifeCycleStateTypeEnum:(TouchLifeCycleStateTypeEnum)type
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    if (type == TouchLifeCycleStateTypeBegin)
        self.countOfInvalidTouchPoints = 0;
    
    if([self touchedInsideTracingArea:p withTouchLifeCycleStateTypeEnum:type])
    {
        if (self.countOfInvalidTouchPoints < 2)
        {
            [self updateHandWritingBezierPathWithPoint:p forTouchLifeCycleStateTypeEnum:type];
            self.countOfInvalidTouchPoints = 0;
        }
    }
    else
    {
        self.countOfInvalidTouchPoints++;
    }
}

- (void)updateHandWritingBezierPathWithPoint:(CGPoint) p forTouchLifeCycleStateTypeEnum:(TouchLifeCycleStateTypeEnum)type
{
    if (type == TouchLifeCycleStateTypeBegin)
        [self.handWritingBezierPath moveToPoint:p];
    else if(type == TouchLifeCycleStateTypeMoved)
        [self.handWritingBezierPath addLineToPoint:p];
}

- (BOOL)touchedInsideTracingArea:(CGPoint)point withTouchLifeCycleStateTypeEnum:(TouchLifeCycleStateTypeEnum)type
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [self.traceLetterBezierPath containsPoint:point];
    }
    
    if (type == TouchLifeCycleStateTypeBegin)
    {
        return [self.traceLetterBezierPath containsPoint:point];
    }
    else
    {
        CGPathRef strokedPath = CGPathCreateCopyByStrokingPath(self.traceLetterBezierPath.CGPath, NULL, KKMPathCopyLineWidth, kCGLineCapRound, kCGLineJoinRound, 1);
        BOOL pointIsNearPath = CGPathContainsPoint(strokedPath, NULL, point, NO);
        CGPathRelease(strokedPath);
        return pointIsNearPath;
    }
}

#pragma mark - Motion
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
        [self cleanUp];
}


#pragma mark - cleanup
- (void)cleanUp
{
    self.handWritingBezierPath = [UIBezierPath bezierPath];
    [self setNeedsDisplay];
}




- (void)animate
{
    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
    
    [progressLayer setPath: self.traceLetterBezierPath.CGPath];
    
    [progressLayer setStrokeColor:[UIColor redColor].CGColor];
    [progressLayer setFillColor:[UIColor clearColor].CGColor];
    [progressLayer setLineWidth:10];
    [progressLayer setFillRule:kCAFillRuleEvenOdd];
    
    [progressLayer setStrokeStart:0.0];
    [progressLayer setStrokeEnd:1.0];
    [self.layer addSublayer:progressLayer];
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd = [CABasicAnimation animation];
    animateStrokeEnd.duration  = 5;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    [progressLayer addAnimation:animateStrokeEnd forKey:nil];
}














//- (void)layoutSubviews
//{
//    if (!self.shapeLayer)
//    {
//        self.shapeLayer = [[CAShapeLayer alloc] init];
//        self.shapeLayer.bounds = CGRectMake(0, 0, 200, 200);     // layer is 100x100 in size
//        self.shapeLayer.position = self.center;                  // and is centered in the view
//        self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
//        self.shapeLayer.fillColor = [UIColor redColor].CGColor;
//        self.shapeLayer.lineWidth = 3.f;
//        self.shapeLayer.backgroundColor = [UIColor whiteColor].CGColor;
//        
//        //[self.layer addSublayer:self.shapeLayer];
//    }
//}


//- (IBAction)animate:(id)sender
//{
//    UIBezierPath* path0 = [UIBezierPath bezierPath];
//    [path0 moveToPoint:CGPointZero];
//    [path0 addLineToPoint:CGPointZero];
//    [path0 addLineToPoint:CGPointZero];
//    [path0 addLineToPoint:CGPointZero];
//    
//    UIBezierPath* path1 = [UIBezierPath bezierPath];
//    [path1 moveToPoint:CGPointZero];
//    [path1 addLineToPoint:CGPointMake(50,100)];
//    [path1 addLineToPoint:CGPointMake(50,100)];
//    [path1 addLineToPoint:CGPointMake(50,100)];
//    
//    UIBezierPath* path2 = [UIBezierPath bezierPath];
//    [path2 moveToPoint:CGPointZero];
//    [path2 addLineToPoint:CGPointMake(50,100)];
//    [path2 addLineToPoint:CGPointMake(100,0)];
//    [path2 addLineToPoint:CGPointMake(100,0)];
//    
//    UIBezierPath* path3 = [UIBezierPath bezierPath];
//    [path3 moveToPoint:CGPointZero];
//    [path3 addLineToPoint:CGPointMake(50,100)];
//    [path3 addLineToPoint:CGPointMake(100,0)];
//    [path3 addLineToPoint:CGPointZero];
    
//    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
//    animation.duration = 10.0f;
////    animation.values = [NSArray arrayWithObjects:(id)path0.CGPath, (id)path1.CGPath, (id)path2.CGPath, (id)path3.CGPath, nil];
//    CGPathRef pathRef = self.traceLetterBezierPath.CGPath;
//    NSMutableArray *bezierPoints = [NSMutableArray array];
//    NSMutableArray *bezierPathElementType = [NSMutableArray array];
//    CGPathApply(pathRef, (__bridge void *)(bezierPoints), &GetArrayPoints_CGPathApplierFunc);
//    CGPathApply(pathRef, (__bridge void *)(bezierPathElementType), &GetArrayPoints_CGPathApplierFunc1);
//    
//    UIBezierPath *bPath0 = [UIBezierPath bezierPath];
//    [bPath0 moveToPoint:CGPointZero];
//
//    UIBezierPath *bPath1 = [UIBezierPath bezierPath];
//    [bPath1 moveToPoint:CGPointZero];
//
//    for (NSInteger i = 0; i < bezierPoints.count; i++)
//    {
//        NSValue *pointValue = (NSValue *)bezierPoints[i];
//        [bPath0 addLineToPoint:pointValue.CGPointValue];
//        
//        NSValue *elementTypeValue = (NSValue *)bezierPathElementType[i];
//        int elementTypeIntValue = -1;
//        [elementTypeValue getValue:&elementTypeIntValue];
//    }
//    
//    animation.values = [NSArray arrayWithObjects:(id)bPath0.CGPath, nil];
//    [self.shapeLayer addAnimation:animation forKey:nil];
//}

//void GetArrayPoints_CGPathApplierFunc(void *info, const CGPathElement *element) {
//    NSMutableArray *array = (__bridge NSMutableArray *)info;
////    if (element->type == kCGPathElementMoveToPoint || element->type == kCGPathElementAddLineToPoint)
//    {
//        //printf("The value is %d\n", element->type);
//        CGPoint point = element->points[0];
//        [array addObject:[NSValue valueWithCGPoint:point]];
//    }
//}
//
//void GetArrayPoints_CGPathApplierFunc1(void *info, const CGPathElement *element) {
//    NSMutableArray *array = (__bridge NSMutableArray *)info;
//    //if (element->type == kCGPathElementMoveToPoint || element->type == kCGPathElementAddLineToPoint)
//    {
////        printf("The value is %d\n", element->type);
//        int theInt = element->type;
//        const void *myVal = &theInt;
//        NSValue *valObj = [NSValue value:myVal withObjCType:@encode(int*)];
//        [array addObject:valObj];
//    }
//}



@end
