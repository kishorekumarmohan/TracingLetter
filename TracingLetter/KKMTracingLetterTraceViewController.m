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

@property (weak, nonatomic) IBOutlet UILabel    *wordLabel;
@property (weak, nonatomic) IBOutlet UIView     *colorPickerView;
@property (weak, nonatomic) IBOutlet UIButton   *backButton;
@property (weak, nonatomic) IBOutlet UIButton   *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton   *menuButton1;
@property (weak, nonatomic) IBOutlet UIButton   *menuButton2;
@property (weak, nonatomic) IBOutlet UIButton   *menuButton3;

@property (nonatomic, assign) NSInteger         buttonState;
@property (nonatomic, strong) NSDictionary      *languageDataDict;
@property (nonatomic, assign) NSInteger         index;
@property (nonatomic, assign) BOOL              isShown;

@end

@implementation KKMTracingLetterTraceViewController

#pragma mark - view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupPropertyList];
    [self setupDrawView];
    [self setUpInitialLetterAndWord];
    [self setupMenuButtonItems];

    self.colorPickerView.hidden = YES;
    self.backButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view becomeFirstResponder];
}

#pragma mark - setup
- (void)setupPropertyList
{
    NSString *path = [[NSBundle mainBundle] pathForResource:KKMPropertyListDataFile ofType:@"plist"];
    NSDictionary *languageDict = [NSDictionary dictionaryWithContentsOfFile:path];
    self.languageDataDict = languageDict[KKMLanguageNameTamil];
    self.dataDict = self.languageDataDict[KKMButton1];
}

- (void)setupDrawView
{
    KKMTracingLetterDrawView *drawView = [self drawView];
    drawView.delegate = self;
    drawView.fontNameString = self.languageDataDict[KKMFontName];
    drawView.dataDict = self.dataDict;
}

- (void)setUpInitialLetterAndWord
{
    KKMTracingLetterDrawView *drawView = [self drawView];
    drawView.letterString = self.dataDict[KKMValues][0][0];

    NSArray *array = self.dataDict[KKMValues][1];
    if (array.count > 0)
    {
        self.wordLabel.text = self.dataDict[KKMValues][1][0];
    }
}

- (void)setupMenuButtonItems
{
    [self.menuButton1 setTitleColor:[UIColor yellowColor] forState: UIControlStateNormal];

    [self.menuButton1 setTitle:self.languageDataDict[KKMButton1][KKMName] forState:UIControlStateNormal];
    [self.menuButton2 setTitle:self.languageDataDict[KKMButton2][KKMName] forState:UIControlStateNormal];
    [self.menuButton3 setTitle:self.languageDataDict[KKMButton3][KKMName] forState:UIControlStateNormal];
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
    drawView.dataDict = self.dataDict;
    if ([key isEqualToString:@"forward"])
    {
        if((letterArray.count - 1) > self.index)
            self.index++;

        if ((letterArray.count -1) == self.index)
            self.forwardButton.hidden = YES;
    }
    else if ([key isEqualToString:@"back"])
    {
        if(self.index > 0)
            self.index--;
        
        if (self.index == 0)
            self.backButton.hidden = YES;
    }
    else
    {
        self.index = 0;
        self.forwardButton.hidden = NO;
        self.backButton.hidden = YES;
    }
    
    drawView.letterString = letterArray[self.index];
    if (wordArray.count > 0)
        self.wordLabel.text = wordArray[self.index];
    else
        self.wordLabel.text = nil;

    [self drawViewTapped];
    [self cleanUp];
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
    [self cleanUp];
    [self drawView].handWritingStrokeColor = color;
    self.colorPickerView.hidden = YES;
}

- (IBAction)deleteButtonTapped:(id)sender
{
    [self cleanUp];
}

- (IBAction)menuItemButtonTapped:(id)sender
{
    [self resetMenuButtonColor];
    CustomRoundedButton *button = (CustomRoundedButton *)sender;
    if(button.tag == 0)
        self.dataDict = self.languageDataDict[KKMButton1];
    else if(button.tag == 1)
        self.dataDict = self.languageDataDict[KKMButton2];
    else if (button.tag == 2)
        self.dataDict = self.languageDataDict[KKMButton3];
    
    [button setTitleColor:[UIColor yellowColor] forState: UIControlStateNormal];
    
    [self refreshView:nil];
    [[self drawView] setNeedsDisplay];
}

- (void)resetMenuButtonColor
{
    [self.menuButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
