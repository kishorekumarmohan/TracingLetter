//
//  CustomRoundedView.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/26/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "CustomRoundedView.h"

@implementation CustomRoundedView

- (void)setCornerRadius:(NSInteger)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

@end
