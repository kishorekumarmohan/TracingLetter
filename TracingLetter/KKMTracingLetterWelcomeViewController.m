//
//  KKMTracingLetterWelcomeViewController.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/24/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "KKMTracingLetterWelcomeViewController.h"
#import "KKMTracingLetterTraceViewController.h"
#import "KKMTracingLetterConstants.h"
#import "CustomRoundedButton.h"

@interface KKMTracingLetterWelcomeViewController ()

@property (nonatomic, strong) NSDictionary *dataDict;
@property (weak, nonatomic) IBOutlet CustomRoundedButton *button1;
@property (weak, nonatomic) IBOutlet CustomRoundedButton *button2;
@property (weak, nonatomic) IBOutlet CustomRoundedButton *button3;

@end

@implementation KKMTracingLetterWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupPropertyList];
    [self setupButton];
    self.navigationItem.title = self.dataDict[@"title"];
}

- (void)setupPropertyList
{
    NSString *path = [[NSBundle mainBundle] pathForResource:KKMPropertyListDataFile ofType:@"plist"];
    NSDictionary *languageDict = [NSDictionary dictionaryWithContentsOfFile:path];
    self.dataDict = languageDict[KKMLanguageNameTamil];
}

- (void)setupButton
{
    [self.button1 setTitle:self.dataDict[KKMButton1][KKMName] forState:UIControlStateNormal];
    [self.button2 setTitle:self.dataDict[KKMButton2][KKMName] forState:UIControlStateNormal];
    [self.button3 setTitle:self.dataDict[KKMButton3][KKMName] forState:UIControlStateNormal];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    KKMTracingLetterTraceViewController *controller = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:KKMButton1])
    {
        controller.navigationItem.title = self.dataDict[KKMButton1][KKMName];
        controller.dataDict = self.dataDict[KKMButton1];
    }
    
    else if ([segue.identifier isEqualToString:KKMButton2])
        controller.dataDict = self.dataDict[KKMButton2];
    
    else if ([segue.identifier isEqualToString:KKMButton3])
        controller.dataDict = self.dataDict[KKMButton3];
}


@end
