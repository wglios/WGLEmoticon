//
//  WGLFaceScrollView.m
//  GITDemo
//
//  Created by wangguoliang on 15/9/6.
//  Copyright (c) 2015年 wangguoliang. All rights reserved.
//

#import "WGLFaceScrollView.h"
#import "UIViewExt.h"

//获取物理屏幕的尺寸
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

@implementation WGLFaceScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _initViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _initViews];
}
- (id)initWithBlock:(SelectedBlock)block
{
    self = [super init];
    if (self) {
        _faceView.block = block;
    }
    return self;
}

- (void)setFaceBlock:(SelectedBlock)block
{
    _faceView.block = block;
}
#pragma mark -
- (void)_initViews
{
    // 表情View
    _faceView = [[WGLFaceView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    _faceView.backgroundColor = [UIColor clearColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth, _faceView.height)];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_faceView.width, _faceView.height);
    _scrollView.clipsToBounds = NO;
    [_scrollView addSubview:_faceView];
    
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _scrollView.bottom, kScreenWidth, 20.0f)];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.numberOfPages = _faceView.pageNumber;
    _pageControl.currentPage = 0;//self：frame（0，0，0，0）；
    [self addSubview:_pageControl];
    
    //_pageControll：320
    
    
    self.autoresizesSubviews = NO;
    self.height = _scrollView.height + _pageControl.height;
    self.width = _scrollView.width;//self 0-->320  _pageControl 320-->640
    self.frame = CGRectMake(0.0f, 100.0f, _scrollView.width, _scrollView.height + _pageControl.height);
    
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _pageControl.currentPage = _scrollView.contentOffset.x/kScreenWidth;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIImage imageNamed:@"emoticon_keyboard_background.png"] drawInRect:rect];
}


@end
