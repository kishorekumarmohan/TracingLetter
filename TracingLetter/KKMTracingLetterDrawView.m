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

typedef enum : NSUInteger {
    TouchLifeCycleStateTypeBegin = 0,
    TouchLifeCycleStateTypeMoved,
    TouchLifeCycleStateTypeCancelled,
    TouchLifeCycleStateTypeEnded
} TouchLifeCycleStateTypeEnum;

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

#pragma mark - drawing

-(void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self fontSizeAndLineWidth];
    [self drawTracingLetter];
    [self drawHandWritingLetter];
}

- (void)drawTracingLetter
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *string = self.letterString;
    UIFont *font = [UIFont fontWithName:@"TamilSangamMN" size:self.fontSize];

    self.traceLetterBezierPath = [string bezierPathWithFont:font bounds:self.bounds];
    // The path is upside down (CG coordinate system)
    CGRect boundingBox = CGPathGetBoundingBox(self.traceLetterBezierPath.CGPath);
    [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
    
    CGFloat x = 0;
    CGFloat y = 0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        x = (self.bounds.size.width - boundingBox.size.width) / 2;
        y = self.bounds.size.height / 1.5;
    }
    else
    {
        x = (self.bounds.size.width - boundingBox.size.width) / 2;
        y = (self.bounds.size.height) / 1.5;
    }
    
    [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeTranslation(x, y)];

    
    CGContextAddPath(context, self.traceLetterBezierPath.CGPath);
    CGContextSetStrokeColorWithColor(context,[UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
}

- (void)fontSizeAndLineWidth
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            self.fontSize = 450.f;
            self.handWritingLineWidth = 20.0f;
        }
        else
        {
            self.fontSize = 550.f;
            self.handWritingLineWidth = 30.0f;
        }
    }
    else
    {
        if ([DeviceUtil hardware] == IPHONE_5S)
            self.fontSize = 300.0f;
        else
            self.fontSize = 300.0f;
        
        self.handWritingLineWidth = 15.0f;
        
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            if (self.letterString.length > 1)
                self.fontSize = 250.0f;
        }
    }
}

- (void)drawHandWritingLetter
{
    [self.handWritingStrokeColor setStroke];
    self.handWritingBezierPath.lineJoinStyle = kCGLineJoinRound;
    [self.handWritingBezierPath setLineWidth:self.handWritingLineWidth];
    [self.handWritingBezierPath stroke];
}

#pragma mark - Touch

- (void)handleTouch:(NSSet *)touches withEvent:(UIEvent *)event withTouchLifeCycleStateTypeEnum:(TouchLifeCycleStateTypeEnum) type
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];

    if (type == TouchLifeCycleStateTypeBegin)
        self.countOfInvalidTouchPoints = 0;
    
    if([self touchedInsideTracingArea:p])
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

- (BOOL)touchedInsideTracingArea:(CGPoint)point
{
    BOOL touchedInside = CGPathContainsPoint(self.traceLetterBezierPath.CGPath, nil, point, YES);
    return touchedInside;
}


#pragma mark - cleanup
- (void)cleanUp
{
    self.handWritingBezierPath = [UIBezierPath bezierPath];
    [self setNeedsDisplay];
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


- (IBAction)animate:(id)sender
{
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
}

void GetArrayPoints_CGPathApplierFunc(void *info, const CGPathElement *element) {
    NSMutableArray *array = (__bridge NSMutableArray *)info;
//    if (element->type == kCGPathElementMoveToPoint || element->type == kCGPathElementAddLineToPoint)
    {
        //printf("The value is %d\n", element->type);
        CGPoint point = element->points[0];
        [array addObject:[NSValue valueWithCGPoint:point]];
    }
}

void GetArrayPoints_CGPathApplierFunc1(void *info, const CGPathElement *element) {
    NSMutableArray *array = (__bridge NSMutableArray *)info;
    //if (element->type == kCGPathElementMoveToPoint || element->type == kCGPathElementAddLineToPoint)
    {
//        printf("The value is %d\n", element->type);
        int theInt = element->type;
        const void *myVal = &theInt;
        NSValue *valObj = [NSValue value:myVal withObjCType:@encode(int*)];
        [array addObject:valObj];
    }
}



@end
