//
//  KKMTracingLetterWelcomeViewController.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/24/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "KKMTracingLetterWelcomeViewController.h"
#import "KKMTracingLetterTraceViewController.h"

NSString* const KKMEnglishUpperCaseAlphabets    = @"en_upper_case_alphabets";
NSString* const KKMEnglishLowerCaseAlphabets    = @"en_lower_case_alphabets";
NSString* const KKMNumbers                      = @"numbers";

@interface KKMTracingLetterWelcomeViewController ()

@end

@implementation KKMTracingLetterWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    KKMTracingLetterTraceViewController *controller = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:KKMEnglishLowerCaseAlphabets])
        controller.plistKey = KKMEnglishLowerCaseAlphabets;
    
    else if ([segue.identifier isEqualToString:KKMEnglishLowerCaseAlphabets])
        controller.plistKey = KKMEnglishLowerCaseAlphabets;
    
    else if ([segue.identifier isEqualToString:KKMNumbers])
        controller.plistKey = KKMNumbers;
}


@end
