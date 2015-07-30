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


@interface KKMTracingLetterTraceViewController ()<KKMTracingLetterDrawViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *word;
@property (weak, nonatomic) IBOutlet UIView *colorPickerView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *volumeButton;
@property (nonatomic, assign) NSInteger buttonState;

@property (nonatomic, assign) NSInteger index;
@end

@implementation KKMTracingLetterTraceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDrawView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(cleanUp)];
    self.colorPickerView.hidden = YES;
    self.backButton.hidden = YES;
}

- (void)setupDrawView
{
    KKMTracingLetterDrawView *drawView = [self drawView];
    drawView.delegate = self;
    drawView.letterString = self.dataDict[KKMValues][0][0];
    self.word.text = self.dataDict[KKMValues][1][0];
}

#pragma mark - Button actions
- (IBAction)backButtonTapped:(id)sender
{
    [self refreshView:@"back"];
    self.forwardButton.hidden = NO;
}


- (IBAction)forwardButtonTapped:(id)sender
{
    [self refreshView:@"forward"];
    self.backButton.hidden = NO;
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

        if ((letterArray.count -1) == self.index)
            self.forwardButton.hidden = YES;
    }
    else if ([key isEqualToString:@"back"])
    {
        if(self.index > 0)
        {
            self.index--;
            drawView.letterString = letterArray[self.index];
            self.word.text = wordArray[self.index];
        }
        
        if (self.index == 0)
            self.backButton.hidden = YES;
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
- (IBAction)volumeButtonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
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


#pragma mark - KKMTracingLetterDrawViewDelegate
-(void)drawViewTapped
{
    self.colorPickerView.hidden = YES;
}

@end
