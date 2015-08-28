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

CGFloat const KKMiPadLineWidth = 25.0f;
CGFloat const KKMiPhoneLineWidth = 15.0f;

CGFloat const KKMPadBoundingBoxbuffer = 50.0f;
CGFloat const KKMPhoneBoundingBoxbuffer = 30.0f;

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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.fontSize = 600.f;
        self.handWritingLineWidth = KKMiPadLineWidth;
    }
    else
    {
        if ([DeviceUtil hardware] == IPHONE_6_PLUS)
            self.fontSize = 400.0f;
        else if ([DeviceUtil hardware] == IPHONE_6)
            self.fontSize = 360.0f;
        else
            self.fontSize = 300.f;
        
        self.handWritingLineWidth = KKMiPhoneLineWidth;
    }
}

- (void)drawTracingLetter
{
    UIFont *font = [UIFont fontWithName:self.fontNameString size:self.fontSize];
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
    
    CGFloat factor = 1.0f;
    
    if ([hint isEqualToString:@"top"])
        factor = 1.4f;
    else if ([hint isEqualToString:@"top1"])
        factor = 1.2f;
    else if ([hint isEqualToString:@"top2"])
        factor = 1.1f;
    
    y = y * factor;
    
    [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeTranslation(x, y)];
}

- (void)calculateBoundingBoxScale
{
    CGFloat scale = [self calculateScale];
    
    if (scale > 0)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.handWritingLineWidth = KKMiPadLineWidth * scale;
        else
            self.handWritingLineWidth = KKMiPhoneLineWidth * scale;
        
        [self.traceLetterBezierPath applyTransform:CGAffineTransformMakeScale(scale, scale)];
    }
}

- (CGFloat)calculateScale
{
    CGRect boundingBox = CGPathGetBoundingBox(self.traceLetterBezierPath.CGPath);
    
    CGFloat buffer = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? KKMPhoneBoundingBoxbuffer : KKMPadBoundingBoxbuffer;
    CGFloat scale = 0.0f;
    
    if(boundingBox.size.height + buffer > self.bounds.size.height)
        scale = self.bounds.size.height / (boundingBox.size.height + buffer);
    
    if(boundingBox.size.width + buffer > self.bounds.size.width)
        scale = (self.bounds.size.width / boundingBox.size.width) - 0.05;
    
    return scale;
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
    if (hint == nil)
        hint = self.dataDict[KKMValues][2][KKMAll];
    
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
    [self.delegate touchEnded];
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
        [self.delegate touchBegan];
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
    return [self.traceLetterBezierPath containsPoint:point];
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
