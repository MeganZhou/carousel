//
//  ECCarouselView.h
//  Blinq-iOS
//
//  Created by Megan on 7/16/14.
//  Copyright (c) 2014 jinyuntian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECCarouselViewDelegate <NSObject>

- (void)selectedImage:(UIImage *)image atIndex:(NSUInteger)index;

@end

@interface ECCarouselView : UIView

@property (weak, nonatomic) id <ECCarouselViewDelegate> carouselDelegate;

- (void)setImageUrls:(NSArray *)imageUrls andTitles:(NSArray *)titles;

@end

#pragma mark - ImageTouchView

@protocol ECImageTouchDelegate;

@interface ECImageTouchView : UIImageView

@property(weak, nonatomic) id<ECImageTouchDelegate> imageTouchViewDelegate;

@end

@protocol ECImageTouchDelegate <NSObject>

- (void)imageViewTouch:(ECImageTouchView *)imageView begin:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)imageViewTouch:(ECImageTouchView *)imageView end:(NSSet *)touches withEvent:(UIEvent *)event;

@end