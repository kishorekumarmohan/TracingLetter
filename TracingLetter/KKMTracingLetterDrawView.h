//
//  KKMTracingLetterDrawView.h
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/23/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKMTracingLetterDrawViewDelegate <NSObject>

- (void)drawViewTapped;

@end

@interface KKMTracingLetterDrawView : UIView

@property (nonatomic, weak) id<KKMTracingLetterDrawViewDelegate> delegate;

@property (nonatomic, strong) NSString *letterString;
@property (nonatomic, strong) UIColor *handWritingStrokeColor;
@property (nonatomic, strong) NSString *fontNameString;
@property (nonatomic, strong) NSDictionary *dataDict;

- (void)cleanUp;

@end
