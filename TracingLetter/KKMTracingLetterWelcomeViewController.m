//
//  KKMTracingLetterWelcomeViewController.m
//  TracingLetter
//
//  Created by Mohan, Kishore Kumar on 7/24/15.
//  Copyright (c) 2015 kmohan. All rights reserved.
//

#import "KKMTracingLetterWelcomeViewController.h"
#import "KKMTracingLetterTraceViewController.h"

NSString* const KKMKey1 = @"key1";
NSString* const KKMKey2 = @"key2";
NSString* const KKMKey3 = @"key3";

@interface KKMTracingLetterWelcomeViewController ()

@end

@implementation KKMTracingLetterWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    KKMTracingLetterTraceViewController *controller = [segue destinationViewController];
    controller.languageKey = @"tamil";
    
    if ([segue.identifier isEqualToString:KKMKey1])
        controller.plistKey = KKMKey1;
    
    else if ([segue.identifier isEqualToString:KKMKey2])
        controller.plistKey = KKMKey2;
    
    else if ([segue.identifier isEqualToString:KKMKey3])
        controller.plistKey = KKMKey3;
}


@end
