//
//  KKMTracingLetterDrawView.h
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/23/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKMTracingLetterDrawView : UIView

@property (nonatomic, strong) NSString *letterString;
@property (nonatomic, strong) UIColor *handWritingStrokeColor;

- (void)cleanUp;

@end
