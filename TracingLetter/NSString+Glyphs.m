//
//  NSString+Glyphs.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/24/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "NSString+Glyphs.h"
#import <CoreText/CoreText.h>

@implementation NSString (Glyphs)

- (UIBezierPath *)bezierPathWithFont:(UIFont *)font bounds:(CGRect)bounds
{
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.familyName, font.pointSize, NULL);
    NSString *string = self;
    NSUInteger count = string.length;
    unichar characters[count];
    [string getCharacters:characters range:NSMakeRange(0, count)];
    
    CGGlyph glyphs[count];
    BOOL gotGlyphs = CTFontGetGlyphsForCharacters(fontRef, characters, glyphs, count);
    
    UIBezierPath *bpath;
    if (gotGlyphs)
    {
        CGAffineTransform transform = CGAffineTransformIdentity; //CGAffineTransformMakeRotation(2.0f);
        CGPathRef pathRef = CTFontCreatePathForGlyph(fontRef, glyphs[0], &transform);
        bpath = [UIBezierPath bezierPath];
        [bpath appendPath:[UIBezierPath bezierPathWithCGPath:pathRef]];
        [bpath closePath];
        [bpath applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
        CGRect boundingBox = CGPathGetBoundingBox(pathRef);
        CGFloat x = (bounds.size.width / 2) - (boundingBox.size.width / 2);
        CGFloat y = (bounds.size.height / 2) + (boundingBox.size.height / 2);
        
        [bpath applyTransform:CGAffineTransformMakeTranslation(x, y)];
    }
    return bpath;
}

- (BOOL)isCharacter:(unichar)character supportedByFont:(UIFont *)aFont
{
    UniChar characters[] = { character };
    CGGlyph glyphs[1] = { };
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)aFont.fontName, aFont.pointSize, NULL);
    BOOL ret = CTFontGetGlyphsForCharacters(ctFont, characters, glyphs, 1);
    CFRelease(ctFont);
    return ret;
}
@end
