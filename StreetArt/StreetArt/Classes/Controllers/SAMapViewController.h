//
//  SAMapViewController.h
//  StreetArt
//
//  Created by Kevin Lord on 6/16/12.
//  Copyright (c) 2012 Kapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Parse/Parse.h"

@interface SAMapViewController : UIViewController <MKMapViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate, UIActionSheetDelegate>

@end
