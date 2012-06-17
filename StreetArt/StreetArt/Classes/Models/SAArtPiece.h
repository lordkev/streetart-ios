//
//  SAArtPiece.h
//  StreetArt
//
//  Created by Kevin Lord on 6/16/12.
//  Copyright (c) 2012 Kapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Parse/Parse.h"

@interface SAArtPiece : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFFile *thumbnailFile;

- (id)initWithPFObject:(PFObject *)artObject;
+ (NSArray *)artPiecesWithPFObjects:(NSArray *)pfObjects;

+ (void)getArtPiecesInMapRect:(MKMapRect)mapRect success:(void (^)(NSArray *artPieces))successBlock failure:(void (^)(NSError *error))failureBlock;
+ (void)saveArtPieceWithImage:(UIImage *)image location:(CLLocation *)location success:(void (^)())successBlock failure:(void (^)(NSError *error))failureBlock progressBlock:(void (^)(NSInteger percentDone))progressBlock;
@end
