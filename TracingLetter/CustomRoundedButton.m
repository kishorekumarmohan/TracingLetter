//
//  CustomRoundedButton.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/24/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "CustomRoundedButton.h"

@implementation CustomRoundedButton

- (void)setCornerRadius:(NSInteger)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}


@end
