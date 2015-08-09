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
    self.fontSize = 550.f;
    self.handWritingLineWidth = KKMiPadLineWidth;
}

- (void)drawTracingLetter
{
    UIFont *font = [UIFont fontWithName:self.fontNameString size:self.fontSize];
    NSLog(@"%@", self.letterString);
    self.traceLetterBezierPath = [self.letterString bezierPathWithFont:font bounds:self.bounds];
    [self calculateBoundingBoxPosition];
    [self calculateBoundingBoxScale];
   
    [[UIColor yellowColor] setStroke];
    [self.traceLetterBezierPath setLineJoinStyle:kCGLineJoinRound];
    [self.traceLetterBezierPath setLineCapStyle:kCGLineCapButt];
    [self.traceLetterBezierPath setLineWidth:3];
    CGFloat dashes[] = {6, 2};
    [self.traceLetterBezierPath setLineDash:dashes count:2 phase:0];
    [self.traceLetterBezierPath stroke];
}

- (void)calculateBoundingBoxPosition
{
    CGRect boundingBox = CGPathGetBoundingBox(self.traceLetterBezierPath.CGPath);
    CGFloat x = (self.bounds.size.width - boundingBox.size.width) / 2;
    if (x < 0)
        x = 0;
    
    CGFloat y = self.bounds.size.height / 1.5;
    NSString *hint = [self presentationHint];
    if ([hint isEqualToString:@"top"])
    {
        y = y * 1.3;
    }
    
    [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeTranslation(x, y)];
}

- (void)calculateBoundingBoxScale
{
    CGRect boundingBox = CGPathGetBoundingBox(self.traceLetterBezierPath.CGPath);
    
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
}

- (void)drawHandWritingLetter
{
    [self.handWritingStrokeColor setStroke];
    [self.handWritingBezierPath setLineJoinStyle:kCGLineJoinRound];
    [self.handWritingBezierPath setLineCapStyle:kCGLineCapButt];
    [self.handWritingBezierPath setLineWidth:self.handWritingLineWidth];
    [self.handWritingBezierPath stroke];
}

- (NSString *)presentationHint
{
    NSString *hint = self.dataDict[KKMValues][2][self.letterString];
    return hint;
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

@end
