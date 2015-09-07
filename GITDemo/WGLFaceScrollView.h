//
//  WGLFaceScrollView.h
//  GITDemo
//
//  Created by wangguoliang on 15/9/6.
//  Copyright (c) 2015年 wangguoliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGLFaceView.h"

@interface WGLFaceScrollView : UIView<UIScrollViewDelegate>

{
    UIScrollView *_scrollView;
    WGLFaceView *_faceView;
    UIPageControl *_pageControl;
}

- (id)initWithBlock:(SelectedBlock)block;

- (void)setFaceBlock:(SelectedBlock)block;

@end
