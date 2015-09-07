//
//  WGLFaceView.m
//  GITDemo
//
//  Created by wangguoliang on 15/9/6.
//  Copyright (c) 2015年 wangguoliang. All rights reserved.
//

#import "WGLFaceView.h"
#import "UIViewExt.h"

#define face_width   30.0f   //表情的宽度
#define face_heigth  30.0f   //表情的高度

//获取物理屏幕的尺寸
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

#define item_width  (kScreenWidth/7.0f)    //单个表情占用的区域宽度
#define item_heigth (kScreenWidth/7.0f)    //单个表情占用的区域高度

@implementation WGLFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLoadData];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initLoadData];
}
- (void)initLoadData
{
    _items = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"];
    NSArray *emoticons = [NSArray arrayWithContentsOfFile:filePath];
    
    //以每组最大28个一组分成二维数组
    NSMutableArray *item2D = nil;
    for (NSInteger i = 0; i < emoticons.count; i++) {
        if (item2D == nil || item2D.count == 28) {
            item2D = [NSMutableArray arrayWithCapacity:28];
            [_items addObject:item2D];
        }
        NSDictionary *item = [emoticons objectAtIndex:i];
        [item2D addObject:item];
    }
    
    //设置当前视图的尺寸
    self.width = _items.count * kScreenWidth;
    self.height = item_heigth * 4;
    
    //创建放大镜视图
    _magnifierView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emoticon_keyboard_magnifier"]];
    _magnifierView.frame = CGRectMake(0.0f, 0.0f, 64.0f, 92.0f);
    _magnifierView.backgroundColor = [UIColor clearColor];
    _magnifierView.hidden = YES;
    [self addSubview:_magnifierView];
    
    //放大镜上的表情视图
    UIImageView *faceItem = [[UIImageView alloc] initWithFrame:CGRectMake((_magnifierView.width - face_width)/2, 15.0f, face_width, face_heigth)];
    faceItem.backgroundColor = [UIColor clearColor];
    faceItem.tag = 2013;
    [_magnifierView addSubview:faceItem];
}
//画表情
//当前数组已分为
/*
 [
 [表情1，表情2，.....表情28],
 [表情1，表情2，.....表情28],
 [表情1，表情2，.....表情28],
 ......
 ]
 */
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSInteger row = 0;   // 有多少行
    NSInteger colum = 0; // 每行的个数
    
    for (NSInteger i = 0; i < _items.count; i++) {
        NSArray *item2D = [_items objectAtIndex:i];
        for (NSInteger j = 0; j < item2D.count; j++) {
            NSDictionary *item = [item2D objectAtIndex:j];
            //取得图片的文件名
            NSString *imgName = [item objectForKey:@"png"];
            UIImage *image = [UIImage imageNamed:imgName];
            //计算表情的坐标
            CGFloat x = colum*item_width + (item_width - face_width)/2 + i*kScreenWidth;
            CGFloat y = row*item_heigth + (item_heigth - face_heigth)/2;
            
            CGRect frame = CGRectMake(x, y, face_width, face_heigth);
            [image drawInRect:frame];
            
            colum ++;
            if (colum % 7 == 0) {
                row ++;
                colum = 0;
            }
            if (row == 4) {
                row = 0;
            }
            
        }
    }
}

//通过坐标点，找表情文件
- (void)touchFace:(CGPoint)point
{
    //计算页数
    NSInteger page = point.x/kScreenWidth;
    if (page > _items.count) {
        return;
    }
    //计算行、列
    NSInteger row = (point.y - (item_heigth - face_heigth)/2)/item_heigth;
    NSInteger colum = (point.x - page*kScreenWidth - (item_width - face_width)/2)/item_width;
    
    //范围安全判断
    if (colum > 6) colum = 6;
    if (row > 3) row = 3;
    if (colum < 0) colum = 0;
    if (row < 0) row = 0;
    
    //通过row、colum，计算出表情在此页面的索引Index
    NSInteger index = row*7 + colum;
    NSArray *item2D = [_items objectAtIndex:page];
    
    if (index >= item2D.count) {
        return;
    }
    //取得表情
    NSDictionary *item = [item2D objectAtIndex:index];
    //文件名
    NSString *fileName = [item objectForKey:@"png"];
    //表情名
    NSString *faceName = [item objectForKey:@"chs"];
    
    if (![_selectedFaceName isEqualToString:faceName]) {
        //当前表情的中心位置
        CGFloat x = colum * item_width + item_width/2 +page*kScreenWidth;
        CGFloat y = row*item_heigth + item_heigth/2;
        
        NSLog(@"====== %f,%f",x,y);
        UIImageView *faceItem = (UIImageView *)[_magnifierView viewWithTag:2013];
        faceItem.image = [UIImage imageNamed:fileName];
        
        _magnifierView.center = CGPointMake(x, 0);
        _magnifierView.bottom = y;
        //记录当前选中的表情名
        _selectedFaceName = faceName;
    }
}
#pragma mark - 开始点击
//通过坐标的计算，拿到当前表情
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //显示放大镜
    _magnifierView.hidden = NO;
    //禁止滑动
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = NO;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self touchFace:point];
}
#pragma mark - 移动 点击
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self touchFace:point];
}
#pragma mark - 结束点击
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //隐藏放大镜
    _magnifierView.hidden = YES;
    //开启滑动
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = YES;
    }
    //回掉block，将选中的表情名字回传
    if (self.block) {
        self.block(_selectedFaceName);
    }
}

- (NSInteger)pageNumber
{
    return _items.count;
}


@end
