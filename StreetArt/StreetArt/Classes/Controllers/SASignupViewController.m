//
//  SASignupViewController.m
//  StreetArt
//
//  Created by Kevin Lord on 6/17/12.
//  Copyright (c) 2012 Kapps. All rights reserved.
//

#import "SASignupViewController.h"

@interface SASignupViewController ()

@end

@implementation SASignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UILabel *logoLabel = [[UILabel alloc] init];
    logoLabel.text = @"Art Mapper";
    logoLabel.font = [UIFont boldSystemFontOfSize:30.0f];
    logoLabel.textColor = [UIColor colorWithWhite:(167.0f/255.0f) alpha:1.0f];
    logoLabel.backgroundColor = [UIColor clearColor];
    [logoLabel sizeToFit];
    self.signUpView.logo = logoLabel;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
