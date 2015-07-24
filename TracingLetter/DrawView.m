//
//  DrawView.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/23/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "DrawView.h"
#import <CoreText/CoreText.h>
@interface DrawView()

@property (nonatomic, strong) UIBezierPath *bpath;
@end

@implementation DrawView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    self.bpath = [self getUIBezierPath];
    
    CGContextAddPath(context, self.bpath.CGPath);
    CGContextSetStrokeColorWithColor(context,[UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.5);
    CGContextStrokePath(context);
    
    UIColor *fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.7];
    [fillColor setFill];
    [self.bpath fill];
}

- (UIBezierPath *)getUIBezierPath
{
    NSString *fontName = @"Helvatica";
    CGFloat fontSize = 100.0f;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
    NSString *string = @"A";
    NSUInteger count = string.length;
    unichar characters[count];
    [string getCharacters:characters range:NSMakeRange(0, count)];
    CGGlyph glyphs[count];
    BOOL gotGlyphs = CTFontGetGlyphsForCharacters(fontRef, characters, glyphs, count);

    UIBezierPath *bpath;
    if (gotGlyphs)
    {
        CGAffineTransform transform = CGAffineTransformIdentity;// CGAffineTransformMakeRotation(10.0f);
        CGPathRef pathRef = CTFontCreatePathForGlyph(fontRef, glyphs[0], &transform);
        bpath = [UIBezierPath bezierPathWithCGPath:pathRef];
//        [bpath closePath];
    }
    return bpath;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    BOOL touchedInside = CGPathContainsPoint(self.bpath.CGPath, nil, point, YES);
    NSLog(touchedInside ? @"Yes": @"No");
}
@end
