//
//  NSString+Glyphs.h
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/24/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Glyphs)

- (UIBezierPath *)bezierPathWithFont:(UIFont *)font bounds:(CGRect)bounds;

@end