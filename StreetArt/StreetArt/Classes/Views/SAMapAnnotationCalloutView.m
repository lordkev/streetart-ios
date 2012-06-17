//
//  SAMapAnnotationCalloutView.m
//  StreetArt
//
//  Created by Kevin Lord on 6/17/12.
//  Copyright (c) 2012 Kapps. All rights reserved.
//

#import "SAMapAnnotationCalloutView.h"

@implementation SAMapAnnotationCalloutView

@synthesize thumbnailImageView = _thumbnailImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 100.0f, 100.0f)];
        [self addSubview:self.thumbnailImageView];
    }
    return self;
}

@end
