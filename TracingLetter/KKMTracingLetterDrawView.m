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

@property (nonatomic, strong) UIBezierPath *traceLetterBezierPath;
@property (nonatomic, strong) UIBezierPath *handWritingBezierPath;

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
    CGFloat fontSize = 400.0f;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fontSize = 500.f;
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    NSString *string = self.letterString;
    self.traceLetterBezierPath = [string bezierPathWithFont:font bounds:self.bounds];
    
    CGContextAddPath(context, self.traceLetterBezierPath.CGPath);
    CGContextSetStrokeColorWithColor(context,[UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 2.5);
    CGContextStrokePath(context);
}

- (void)drawHandWritingLetter
{
    [[UIColor whiteColor] setStroke];
    [self.handWritingBezierPath setLineWidth:20.0];
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

@end
