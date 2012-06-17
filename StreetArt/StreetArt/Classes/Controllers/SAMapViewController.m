//
//  SAMapViewController.m
//  StreetArt
//
//  Created by Kevin Lord on 6/16/12.
//  Copyright (c) 2012 Kapps. All rights reserved.
//

#import "SAMapViewController.h"
#import "SALoginViewController.h"
#import "SASignupViewController.h"

#import "SAMapAnnotationView.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+Resize.h"

#import "SALocationManager.h"

#import "SAArtPiece.h"

typedef enum {
    SAActionSheetButtonTakePhoto,
    SAActionSheetButtonUploadPhoto,
    SAActionSheetButtonCancel,
} SAActionSheetButton;

@interface SAMapViewController ()

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIProgressView *uploadProgressView;
@property (nonatomic, strong) NSArray *nearbyArtArray;

- (void)addButtonPressed;
- (void)updateMapWithLocation:(CLLocationCoordinate2D)location;
- (void)reloadMapAnnotations;
- (void)uploadImage:(UIImage *)image withLocation:(CLLocation *)location;
@end

@implementation SAMapViewController

@synthesize mapView = _mapView;
@synthesize uploadProgressView = _uploadProgressView;
@synthesize nearbyArtArray = _nearbyArtArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:(116.0f/255.0f) alpha:1.0f];
    self.title = NSLocalizedString(@"Art Mapper", @"");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addButtonPressed)];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    self.uploadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 310.0f, 50.0f)];
    self.uploadProgressView.backgroundColor = [UIColor clearColor];
    self.uploadProgressView.progressTintColor = [UIColor darkGrayColor];
    self.uploadProgressView.trackTintColor = [UIColor clearColor];
    
    SALocationManager *manager = [SALocationManager sharedInstance];
    [manager addObserver:self
              forKeyPath:@"currentLocation"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    [manager start];
    
    if ([PFUser currentUser] == nil) {
        SALoginViewController *loginViewController = [[SALoginViewController alloc] init];
        loginViewController.delegate = self;
        loginViewController.signUpController = [[SASignupViewController alloc] init];
        loginViewController.fields = PFLogInFieldsUsernameAndPassword 
                                    | PFLogInFieldsLogInButton
                                    | PFLogInFieldsSignUpButton 
                                    | PFLogInFieldsFacebook
                                    | PFLogInFieldsTwitter
                                    | PFLogInFieldsPasswordForgotten;
        [self presentModalViewController:loginViewController animated:YES];
    }
}

- (void)viewDidUnload {
    
    [super viewDidUnload];

    [[SALocationManager sharedInstance] removeObserver:self forKeyPath:@"currentLocation"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)addButtonPressed {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Take Photo or Video", @""), NSLocalizedString(@"Upload Photo", @""), nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Private methods

- (void)updateMapWithLocation:(CLLocationCoordinate2D)location {
    
    MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance(location, 2000, 2000)];

    [self.mapView setRegion:regionThatFits animated:NO];
}

- (void)reloadMapAnnotations {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (SAArtPiece *artPiece in self.nearbyArtArray) {
        NSLog(@"adding annotation for artPiece: %@", artPiece);

        [self.mapView addAnnotation:artPiece];
    }
}

- (void)uploadImage:(UIImage *)image withLocation:(CLLocation *)location {
    
    self.uploadProgressView.progress = 0.0f;
    [self.view addSubview:self.uploadProgressView];
    
    [SAArtPiece saveArtPieceWithImage:image location:location success:^{
        [self.uploadProgressView removeFromSuperview];
    } failure:^(NSError *error) {
        
    } progressBlock:^(NSInteger percentDone) {
        self.uploadProgressView.progress = percentDone;
    }];
}

#pragma mark - PFLoginViewControllerDelegate methods

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    
}

#pragma mark - PFSignupViewControllerDelegate methods

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    
}

#pragma mark - KVO methods for location updates

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqual:@"currentLocation"]) {
        
        if ([SALocationManager sharedInstance].currentLocation) {
            
            [[SALocationManager sharedInstance] stop];
            
            CLLocationCoordinate2D currentLocation = [SALocationManager sharedInstance].currentLocation.coordinate;
            [self updateMapWithLocation:currentLocation];
        }
        
    } else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - MKMapViewDelegateMethods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    [SAArtPiece getArtPiecesInMapRect:[self.mapView visibleMapRect] success:^(NSArray *artPieces) {
        
        self.nearbyArtArray = artPieces;
        [self reloadMapAnnotations];
    } failure:^(NSError *error) {
        NSLog(@"error getting art objects: %@", error);
    }];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"created annotation view for annotation: %@", annotation);

    NSString *identifier = @"MapAnnotation";
    
    SAMapAnnotationView *annotationView = (SAMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView == nil) {
        annotationView = [[SAMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.animatesDrop = NO;
        annotationView.canShowCallout = NO;
        
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        [((SAArtPiece *)annotation).thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            annotationView.thumbnailImage = [UIImage imageWithData:data];
        }];
    }
    /*
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (pinAnnotationView == nil) {
        pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        pinAnnotationView.pinColor = MKPinAnnotationColorRed;
        pinAnnotationView.animatesDrop = NO;
        pinAnnotationView.canShowCallout = NO;
        
        pinAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        [((SAArtPiece *)annotation).thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            pinAnnotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
        }];
    }
    */
    return annotationView;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    switch (buttonIndex) {
        case SAActionSheetButtonTakePhoto:
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case SAActionSheetButtonUploadPhoto:
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            return;
            break;
    }
    
    [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        CLLocation *location = [[SALocationManager sharedInstance] currentLocation];
        
        [self uploadImage:image withLocation:location];
    } else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            
            CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
            
            [self uploadImage:image withLocation:location];
        } failureBlock:^(NSError *error) {
            NSLog(@"Could not get asset. Error: %@", error);
        }];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

@end
