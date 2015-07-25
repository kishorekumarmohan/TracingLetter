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


@interface KKMTracingLetterDrawView()

@property (nonatomic, strong) UIBezierPath  *traceLetterBezierPath;
@property (nonatomic, strong) UIBezierPath  *handWritingBezierPath;

@end

@implementation KKMTracingLetterDrawView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _handWritingBezierPath = [UIBezierPath bezierPath];
    }
    return self;
}

- (void)cleanUp
{
    self.handWritingBezierPath = [UIBezierPath bezierPath];
}

- (void)drawRect:(CGRect)rect
{
    [self drawTracingLetter];
    [self drawHandWritingLetter];
}

- (void)drawTracingLetter
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *string = self.letterString;

    CGFloat fontSize = 500.0f;

    if (string.length > 1)
        fontSize = 400.0f;

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fontSize = 500.f;
    
    UIFont *font = [UIFont fontWithName:@"TamilSangamMN-Bold" size:fontSize];
    self.traceLetterBezierPath = [string bezierPathWithFont:font bounds:self.bounds];
    
    CGContextAddPath(context, self.traceLetterBezierPath.CGPath);
    CGContextSetStrokeColorWithColor(context,[UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
}

- (void)drawHandWritingLetter
{
    [[UIColor whiteColor] setStroke];
    CGFloat lineWidth = 30.0f;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        lineWidth = 40.0f;
    
    [self.handWritingBezierPath setLineWidth:lineWidth];
    [self.handWritingBezierPath stroke];
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    if([self touchedInsideTracingArea:p])
        [self.handWritingBezierPath moveToPoint:p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    if([self touchedInsideTracingArea:p])
        [self.handWritingBezierPath addLineToPoint:p];
    
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
