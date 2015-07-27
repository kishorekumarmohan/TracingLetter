//
//  KKMTracingLetterTraceViewController.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/23/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "KKMTracingLetterTraceViewController.h"
#import "KKMTracingLetterDrawView.h"
#import "KKMTracingLetterConstants.h"
#import "CustomRoundedButton.h"


@interface KKMTracingLetterTraceViewController ()
@property (weak, nonatomic) IBOutlet UILabel *word;
@property (weak, nonatomic) IBOutlet UIView *colorPickerView;

@property (nonatomic, assign) NSInteger index;
@end

@implementation KKMTracingLetterTraceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDrawView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(cleanUp)];
    self.colorPickerView.hidden = YES;
}

- (void)setupDrawView
{
    KKMTracingLetterDrawView *drawView = [self drawView];
    drawView.letterString = self.dataDict[KKMValues][0][0];
    self.word.text = self.dataDict[KKMValues][1][0];
}

#pragma mark - Button actions
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
    NSArray *letterArray = self.dataDict[KKMValues][0];
    NSArray *wordArray = self.dataDict[KKMValues][1];
    KKMTracingLetterDrawView *drawView = [self drawView];
    if ([key isEqualToString:@"forward"])
    {
        if((letterArray.count - 1) > self.index)
        {
            self.index++;
            drawView.letterString = letterArray[self.index];
            self.word.text = wordArray[self.index];
        }
    }
    else if ([key isEqualToString:@"back"])
    {
        if(self.index > 0)
        {
            self.index--;
            drawView.letterString = letterArray[self.index];
            self.word.text = wordArray[self.index];
        }
    }
    
    [drawView cleanUp];    
    [drawView setNeedsDisplay];
}
- (IBAction)colorLensButtonTapped:(id)sender
{
    self.colorPickerView.hidden = NO;
}
- (IBAction)colorButtonTapped:(id)sender
{
    CustomRoundedButton *button = (CustomRoundedButton *)sender;
    UIColor *color = button.backgroundColor;
    [self drawView].handWritingStrokeColor = color;
    self.colorPickerView.hidden = YES;
}


#pragma mark - helper

- (KKMTracingLetterDrawView *)drawView
{
    KKMTracingLetterDrawView *drawView = (KKMTracingLetterDrawView *)self.view;
    return drawView;
}

- (void)cleanUp
{
    [[self drawView] cleanUp];
}

@end
