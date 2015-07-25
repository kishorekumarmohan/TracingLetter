//
//  KKMTracingLetterTraceViewController.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/23/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "KKMTracingLetterTraceViewController.h"
#import "KKMTracingLetterDrawView.h"
#import "KKMTracingLetterWelcomeViewController.h"

NSString* const KKMDataPListFileName = @"data";

@interface KKMTracingLetterTraceViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger arrayIndex;

@end

@implementation KKMTracingLetterTraceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupPropertyList];
    [self setupDrawView];
    //[self setupSwipeGesture];
}

- (void)setupPropertyList
{
    NSString *path = [[NSBundle mainBundle] pathForResource:KKMDataPListFileName ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    if (self.plistKey == nil)
        self.plistKey = KKMEnglishUpperCaseAlphabets;
    
    self.dataArray = [dictionary objectForKey:self.plistKey];
}

- (void)setupDrawView
{
    KKMTracingLetterDrawView *drawView = (KKMTracingLetterDrawView *)self.view;
    drawView.letterString = [self.dataArray firstObject];
}



- (IBAction)backButtonTapped:(id)sender
{
    [self refreshView:@"back"];
}


- (IBAction)forwardButtonTapped:(id)sender
{
    [self refreshView:@"forward"];
}

- (void)refreshView:(NSString *)key
{
    KKMTracingLetterDrawView *drawView = (KKMTracingLetterDrawView *)self.view;
    if ([key isEqualToString:@"forward"])
    {
        if((self.dataArray.count - 1) > self.arrayIndex)
        {
            self.arrayIndex++;
            drawView.letterString = self.dataArray[self.arrayIndex];
        }
    }
    else if ([key isEqualToString:@"back"])
    {
        if(self.arrayIndex > 0)
        {
            self.arrayIndex--;
            drawView.letterString = self.dataArray[self.arrayIndex];
        }
    }
    
    [drawView cleanUp];    
    [drawView setNeedsDisplay];
}













-(void)setupSwipeGesture
{
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];

    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;

    [self.view addGestureRecognizer:swipeLeftGesture];
    [self.view addGestureRecognizer:swipeRightGesture];
}

- (void) swipeRecognizer:(UISwipeGestureRecognizer *)sender
{
    KKMTracingLetterDrawView *drawView = (KKMTracingLetterDrawView *)self.view;
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if((self.dataArray.count - 1) > self.arrayIndex)
        {
            self.arrayIndex++;
            drawView.letterString = self.dataArray[self.arrayIndex];
        }
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if(self.arrayIndex > 0)
        {
            self.arrayIndex--;
            drawView.letterString = self.dataArray[self.arrayIndex];
        }
    }
    
    [self.view setNeedsDisplay];
}


@end
