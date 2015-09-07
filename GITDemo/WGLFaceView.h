//
//  WGLFaceView.h
//  GITDemo
//
//  Created by wangguoliang on 15/9/6.
//  Copyright (c) 2015年 wangguoliang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedBlock)(NSString *faceName);

@interface WGLFaceView : UIView

{
    NSMutableArray *_items;
    
    //放大镜视图
    UIImageView *_magnifierView;
    
    //当前选中的表情名
    NSString *_selectedFaceName;
    
}

@property (nonatomic, copy)SelectedBlock block;

@property (nonatomic, assign)NSInteger pageNumber;

@end
