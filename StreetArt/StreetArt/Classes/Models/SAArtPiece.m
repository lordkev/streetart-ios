//
//  SAArtPiece.m
//  StreetArt
//
//  Created by Kevin Lord on 6/16/12.
//  Copyright (c) 2012 Kapps. All rights reserved.
//

#import "SAArtPiece.h"

#import "UIImage+Resize.h"

@implementation SAArtPiece

@synthesize coordinate = _coordinate;
@synthesize imageFile = _imageFile;
@synthesize thumbnailFile = _thumbnailFile;

- (id)initWithPFObject:(PFObject *)artObject {
    
    self = [super init];
    
    if (self) {
        
        PFGeoPoint *geoPoint = [artObject objectForKey:@"location"];
        self.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        
        self.imageFile = [artObject objectForKey:@"imageFile"];
        self.thumbnailFile = [artObject objectForKey:@"thumbnailFile"];
    }
    
    return self;
}

#pragma mark - Class methods

+ (NSArray *)artPiecesWithPFObjects:(NSArray *)pfObjects {

    NSMutableArray *mutableArtPiecesArray = [NSMutableArray array];
    
    for (PFObject *pfObject in pfObjects) {
        
        SAArtPiece *artPiece = [[SAArtPiece alloc] initWithPFObject:pfObject];
        [mutableArtPiecesArray addObject:artPiece];
    }
    
    return [NSArray arrayWithArray:mutableArtPiecesArray];
}

+ (void)getArtPiecesInMapRect:(MKMapRect)mapRect success:(void (^)(NSArray *artPieces))successBlock failure:(void (^)(NSError *error))failureBlock {
    
    // Calculate NE and SW corners of current map rect
    MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), mapRect.origin.y);
    MKMapPoint swMapPoint = MKMapPointMake(mapRect.origin.x, MKMapRectGetMaxY(mapRect));
    CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
    CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
    
    PFGeoPoint *neGeoPoint = [PFGeoPoint geoPointWithLatitude:neCoord.latitude longitude:neCoord.longitude];
    PFGeoPoint *swGeoPoint = [PFGeoPoint geoPointWithLatitude:swCoord.latitude longitude:swCoord.longitude];
    PFQuery *query = [PFQuery queryWithClassName:@"ArtPiece"];
    [query whereKey:@"location" withinGeoBoxFromSouthwest:swGeoPoint toNortheast:neGeoPoint];
    [query findObjectsInBackgroundWithBlock:^(NSArray *artObjects, NSError *error) {
        
        NSLog(@"got art pieces: %@ in box with sw geopoint: %f %f ne geopoint: %f %f", artObjects, swGeoPoint.latitude, swGeoPoint.longitude, neGeoPoint.latitude, neGeoPoint.longitude);
        if ((error != nil) && (failureBlock != nil)) {
            failureBlock(error);
            return;
        }
        
        if (successBlock != nil) {
            
            NSArray *artPieces = [SAArtPiece artPiecesWithPFObjects:artObjects];
            successBlock(artPieces);
        }
    }];
}

+ (void)saveArtPieceWithImage:(UIImage *)image location:(CLLocation *)location success:(void (^)())successBlock failure:(void (^)(NSError *error))failureBlock progressBlock:(void (^)(NSInteger percentDone))progressBlock {
    
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    // Scale image down
    UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(240.0f, 320.0f) interpolationQuality:kCGInterpolationHigh];

    // Generate thumbnail
    UIImage *thumbnailImage = [image thumbnailImage:100.0f transparentBorder:0 cornerRadius:3.0f interpolationQuality:kCGInterpolationHigh];
    
    // Upload thumbnail image
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnailImage);
    PFFile *thumbnailFile = [PFFile fileWithName:@"thumbnail.png" data:thumbnailData];
    [thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if ((error != nil) && (failureBlock != nil)) {
            failureBlock(error);
            return;
        }
        
        // Upload image
        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if ((error != nil) && (failureBlock != nil)) {
                failureBlock(error);
                return;
            }
            
            // Create ArtPiece object once file upload succeeds
            PFObject *artPieceObject = [PFObject objectWithClassName:@"ArtPiece"];
            [artPieceObject setObject:geoPoint forKey:@"location"];
            [artPieceObject setObject:thumbnailFile forKey:@"thumbnailFile"];
            [artPieceObject setObject:imageFile forKey:@"imageFile"];
            [artPieceObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (successBlock != nil) {
                    successBlock();
                }
            }];
        } progressBlock:progressBlock];
    }];
}

@end
