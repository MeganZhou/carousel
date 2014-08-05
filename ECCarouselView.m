//
//  ECCarouselView.m
//  Blinq-iOS
//
//  Created by Megan on 7/16/14.
//  Copyright (c) 2014 jinyuntian. All rights reserved.
//

#import "ECCarouselView.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Util.h"
#import "UIView+Frame.h"

static CGFloat const kTimeForDisplayView = 0.5f;
static CGFloat const kTimeInterval = 1.5f;

@interface ECCarouselView() <UIScrollViewDelegate, ECImageTouchDelegate>
{
    int _currentPageIndex;
    NSArray *_originImageUrls;
}

@property (strong, nonatomic) NSArray *carouselImageUrls; // Two bigger than _originImageUrls
@property (strong, nonatomic) NSArray *carouselTitles;

@property (weak, nonatomic) IBOutlet UIScrollView *carouselScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *carouselPageControl;
@property (weak, nonatomic) IBOutlet UILabel *carouselTitleLabel;
@property (strong, nonatomic) ECImageTouchView *imageTouchView;

//@property (strong, nonatomic) NSTimer *carouselTimer;

@end

@implementation ECCarouselView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ECCarouselView" owner:self options:nil];

    if (nibs.count > 0) {
        self = nibs[0];
        self.frame = frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _carouselTitleLabel.hidden = YES;
        _carouselPageControl.hidden = YES;
    }
    
    return self;
}

- (void)setImageUrls:(NSArray *)imageUrls andTitles:(NSArray *)titles
{
    _carouselTitles = [NSArray arrayWithArray:titles];
    _carouselTitleLabel.hidden = ((titles == nil) || (titles.count == 0));
    
    // Init image
    _originImageUrls = [NSArray arrayWithArray:imageUrls];
    
    if (_originImageUrls && [_originImageUrls count] > 0) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_originImageUrls];
        [tempArray insertObject:[_originImageUrls lastObject] atIndex:0];
        [tempArray addObject:[_originImageUrls firstObject]];
        
        self.carouselImageUrls = [NSArray arrayWithArray:tempArray];
    }
    
    if (_carouselImageUrls.count > 0) {
        [self initCarouselView];
    }
}

- (void)initCarouselView
{
    CGSize contentSize = CGSizeMake(kScreenWidth * self.carouselImageUrls.count,  self.height);
    if ([_originImageUrls count] == 1) {
        contentSize = CGSizeMake(kScreenWidth, self.height);
    }
    
    [_carouselScrollView setContentSize:contentSize];
    [_carouselScrollView setContentOffset:CGPointMake(kScreenWidth, 0)];
    
    // Init pageController
    _carouselPageControl.numberOfPages = _originImageUrls.count;
    _carouselPageControl.currentPage = 0;
    _carouselPageControl.hidden = !(_originImageUrls.count > 1);
    
//    [self initTimer];
    [self initImageViews];
}

- (void)initImageViews
{
    for (int imageUrlIndex = 0; imageUrlIndex < _carouselImageUrls.count; imageUrlIndex++) {
        _imageTouchView = [[ECImageTouchView alloc]initWithFrame:CGRectMake(kScreenWidth * imageUrlIndex, CGPointZero.y, _carouselScrollView.width, _carouselScrollView.height)];
        _imageTouchView.imageTouchViewDelegate = self;
        [_imageTouchView setImageWithURL:[NSURL URLWithString:_carouselImageUrls[imageUrlIndex]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMGE]];
        [_imageTouchView  addGestureRecognizer:[self adsViewTapGesture]];
        
        [_carouselScrollView addSubview:_imageTouchView];
    }
}

- (UITapGestureRecognizer *)adsViewTapGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAdsView:)];
    tapGesture.numberOfTapsRequired = 1;
    
    return tapGesture;
}

- (void)tappedAdsView:(UITapGestureRecognizer *)gestureRecognizer
{
    UIImageView *selectedImageView = nil;
    if (_carouselScrollView.subviews.count > _carouselPageControl.currentPage) {
        selectedImageView = _carouselScrollView.subviews[_carouselPageControl.currentPage];
    }
    
    UIImage *selectedImage = (selectedImageView != nil) ? selectedImageView.image : nil;
    
    [_carouselDelegate selectedImage:selectedImage atIndex:_carouselPageControl.currentPage];
}

//- (void)initTimer
//{
//    if (_carouselTimer || [_carouselTimer isValid]) {
//        [_carouselTimer invalidate];
//    }
//    
//    _carouselTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(imageScrollViewAutoScroll) userInfo:nil repeats:YES];
//}

#pragma mark - Cycle ScrollView related

- (CATransition *)imageAnimation
{
    CATransition *myTransition = [CATransition animation];
    myTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    myTransition.duration = kTimeForDisplayView;
    myTransition.type = kCATransitionPush;
    myTransition.subtype = kCATransitionFromRight;
    return myTransition;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != _carouselScrollView) {
        return;
    }
    
    _currentPageIndex = floor((scrollView.contentOffset.x - scrollView.width / 2) / scrollView.width);
    _carouselPageControl.currentPage = _currentPageIndex;

    // Init title
    if (_carouselTitles.count > self.carouselPageControl.currentPage) {
       id title  = _carouselTitles[self.carouselPageControl.currentPage];
        
        if ([title isKindOfClass:[NSMutableAttributedString class]]) {
           
            CGFloat bottomPadding = (CGRectGetHeight(self.frame) - CGRectGetMaxY(_carouselTitleLabel.frame));
            [_carouselTitleLabel setHeight:50.0]; // Can fit height to text
            [_carouselTitleLabel setOriginY:CGRectGetHeight(self.frame) - CGRectGetHeight(_carouselTitleLabel.frame) - bottomPadding];
            [_carouselTitleLabel setAttributedText:title];
        } else {
            _carouselTitleLabel.text = [NSString stringWithFormat:@"  %@", title];
        }
    }
}


//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (_carouselTimer != nil) {
//        [_carouselTimer invalidate];
//        _carouselTimer = nil;
//    }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_currentPageIndex == -1) {
        [_carouselScrollView setContentOffset:CGPointMake(_originImageUrls.count * _carouselScrollView.width, 0)];
    }
    
    if (_currentPageIndex == _originImageUrls.count) {
        [_carouselScrollView setContentOffset:CGPointMake(_carouselScrollView.width, 0)];
    }
    
//    if (_carouselTimer == nil) {
//        _carouselTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(imageScrollViewAutoScroll) userInfo:nil repeats:YES];
//    }
}


#pragma mark - NSTimer Action
- (void)imageScrollViewAutoScroll
{
    if ([_originImageUrls count] <= 1) {
        return;
    }
    
    [_carouselScrollView.layer removeAllAnimations];
    
    CGFloat pageWidth = _carouselScrollView.width;
    int page = floor((_carouselScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1; // Mark
    
    if (page == -1) {
        [_carouselScrollView setContentOffset:CGPointMake(_originImageUrls.count * _carouselScrollView.width, 0)];
        [_carouselScrollView.layer addAnimation:[self imageAnimation] forKey:kCATransition];
    } else if (page == _originImageUrls.count) {
        [_carouselScrollView setContentOffset:CGPointMake(_carouselScrollView.width, 0)];
        [_carouselScrollView.layer addAnimation:[self imageAnimation] forKey:kCATransition];
        
    } else {
        [_carouselScrollView setContentOffset:CGPointMake(_carouselScrollView.contentOffset.x + kScreenWidth, 0)];
        [_carouselScrollView.layer addAnimation:[self imageAnimation] forKey:kCATransition];
    }
}

//#pragma mark - ImageTouchView delegate
//
//- (void)imageViewTouch:(ECImageTouchView *)imageView begin:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (_carouselTimer != nil) {
//        [_carouselTimer invalidate];
//        _carouselTimer = nil;
//    }
//}
//
//- (void)imageViewTouch:(ECImageTouchView *)imageView end:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (_carouselTimer == nil) {
//        _carouselTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(imageScrollViewAutoScroll) userInfo:nil repeats:YES];
//    }
//}

@end


#pragma mark - ImageTouchView
@implementation ECImageTouchView

- (void)dealloc
{
    self.imageTouchViewDelegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        [self setUserInteractionEnabled:YES];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return  self;
}

//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
//{
//    return YES;
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    if ([self.imageTouchViewDelegate respondsToSelector:@selector(imageViewTouch:begin:withEvent:)]) {
//        [self.imageTouchViewDelegate imageViewTouch:self begin:touches withEvent:event];
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//    if ([self.imageTouchViewDelegate respondsToSelector:@selector(imageViewTouch:end:withEvent:)]) {
//        [self.imageTouchViewDelegate imageViewTouch:self end:touches withEvent:event];
//    }
//}

@end
