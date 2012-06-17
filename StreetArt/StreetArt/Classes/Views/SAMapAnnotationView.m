//
//  SAMapAnnotationView.m
//  StreetArt
//
//  Created by Kevin Lord on 6/17/12.
//  Copyright (c) 2012 Kapps. All rights reserved.
//

#import "SAMapAnnotationView.h"
#import "SAMapAnnotationCalloutView.h"

@interface SAMapAnnotationView ()

@property (nonatomic, strong) SAMapAnnotationCalloutView *calloutView;
@end

@implementation SAMapAnnotationView

@synthesize thumbnailImage = _thumbnailImage;
@synthesize calloutView = _calloutView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.calloutView = [[SAMapAnnotationCalloutView alloc] initWithFrame:CGRectMake(-50.0f, -110.0f, 110.0f, 110.0f)];
    }
    return self;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    
    _thumbnailImage = thumbnailImage;
    self.calloutView.thumbnailImageView.image = _thumbnailImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
}

@end
