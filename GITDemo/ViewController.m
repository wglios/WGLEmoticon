//
//  ViewController.m
//  GITDemo
//
//  Created by wangguoliang on 15/9/6.
//  Copyright (c) 2015年 wangguoliang. All rights reserved.
//

#import "ViewController.h"
#import "WGLFaceScrollView.h"
#import "UIViewExt.h"

//获取物理屏幕的尺寸
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

#define bgTextView_height 45.0f

@interface ViewController ()<UITextViewDelegate>
{
    UIView *_bgTextView;
    UITextView *_textView;
    
    WGLFaceScrollView *_faceView;//表情视图
}

@end

@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
    /*
    WGLFaceScrollView *faceScrollView = [[WGLFaceScrollView alloc] initWithBlock:^(NSString *faceName) {
        NSLog(@"faceName:%@",faceName);
    }];
    faceScrollView.hidden = YES;
    [self.view addSubview:faceScrollView];
     */
    [self _loadEditorViews];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipe];
}
#pragma mark - 加载输入框
- (void)_loadEditorViews
{
    _bgTextView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth, bgTextView_height)];
    _bgTextView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:_bgTextView];
    //创建输入框视图
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0f, (bgTextView_height - 35.0f)/2.0f, kScreenWidth - 90.0f, 35.0f)];
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:16.0f];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.layer.cornerRadius = 5.0f;
    _textView.layer.shouldRasterize = YES;
    _textView.layer.masksToBounds = YES;
    _textView.returnKeyType = UIReturnKeySend;
    //弹出键盘
    [_textView becomeFirstResponder];
    [_bgTextView addSubview:_textView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_textView.right + 10.0f, (bgTextView_height - 33.0f)/2.0f, 40.0f, 33.0f)];
    [button addTarget:self action:@selector(emoticonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"表情" forState:UIControlStateNormal];
    button.tag = 2015;
    [_bgTextView addSubview:button];
}
#pragma mark - 向上 扫的手势
- (void)swipeAction:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        BOOL isFirstResponder = _textView.isFirstResponder;
        if (!isFirstResponder) {
            [_textView becomeFirstResponder];
        }
    }
}

#pragma mark - UIKeyboardWillShowNotification 键盘的通知事件
#pragma mark - 键盘 将要出现的通知事件
- (void)keyboardWillShowAction:(NSNotification *)notification
{
    //取得键盘的frame，UIKeyboardFrameEndUserInfoKey是键盘尺寸变化之后的尺寸
    NSDictionary *userInfo = notification.userInfo;
    NSValue *boundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [boundsValue CGRectValue];
    
    //取到键盘的高
    CGFloat height = CGRectGetHeight(frame);
    //编辑视图的UI需要重新调整
    //_textView.height = kScreenHeight - 64.0f - height;
    _bgTextView.frame = CGRectMake(0.0f, kScreenHeight - bgTextView_height - height, kScreenWidth, bgTextView_height);
}
#pragma mark - 键盘 将要 消失的通知事件
- (void)keyboardWillHideAction:(NSNotification *)notification
{
    //编辑视图的UI需要重新调整
    //_textView.height = kScreenHeight - 64.0f - height;
    _bgTextView.frame = CGRectMake(0.0f, kScreenHeight - bgTextView_height, kScreenWidth, bgTextView_height);
    
}
#pragma mark - 选择 表情
- (void)emoticonAction:(UIButton *)sender
{
    BOOL isFirstResponder = _textView.isFirstResponder;
    if (isFirstResponder) {
        //显示表情
        [self showFaceView];
        [sender setTitle:@"键盘" forState:UIControlStateNormal];
    } else {
        //隐藏表情
        if ([sender.currentTitle isEqualToString:@"表情"]) {
            [self showFaceView];
            [sender setTitle:@"键盘" forState:UIControlStateNormal];
            return;
        }
        [self hideFaceView];
        [_textView becomeFirstResponder];
        [sender setTitle:@"表情" forState:UIControlStateNormal];
    }
}

#pragma mark -表情显示与收起
- (void)showFaceView
{
    //创建表情面板视图
    if (_faceView == nil) {
        _faceView = [[WGLFaceScrollView alloc] init];
        //_faceView->block->self->_faceView
        __weak ViewController *weekThis = self;
        [_faceView setFaceBlock:^(NSString *faceName) {
            ViewController *strongThis = weekThis;
            strongThis->_textView.text = [strongThis->_textView.text stringByAppendingString:faceName];
        }];
        _faceView.top = kScreenHeight;
        [self.view addSubview:_faceView];
    }
    //隐藏键盘
    [_textView resignFirstResponder];
    //显示表情
    [UIView animateWithDuration:0.3f animations:^{
        _faceView.transform = CGAffineTransformTranslate(_faceView.transform, 0.0f, -_faceView.height);
        //重新布局工具栏和输入框
        //_bgTextView.height = kScreenHeight - 64 - _faceView.height;
        _bgTextView.frame = CGRectMake(0.0f, 432.0f - bgTextView_height, kScreenWidth, bgTextView_height);
    }];
}

//隐藏表情
- (void)hideFaceView
{
    [UIView animateWithDuration:0.3f animations:^{
        _faceView.transform = CGAffineTransformIdentity;
        _bgTextView.frame = CGRectMake(0.0f, kScreenHeight - bgTextView_height, kScreenWidth, bgTextView_height);
    }];
    //[_textView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self hideFaceView];
    UIButton *button = (UIButton *)[_bgTextView viewWithTag:2015];
    [button setTitle:@"表情" forState:UIControlStateNormal];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        NSString *title = nil;
        NSString *message = @"发送的内容为空";
        BOOL isCancel = NO;
        if (textView.text.length) {
            title = @"发送";
            message = textView.text;
            isCancel = YES;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:isCancel == YES ? @"取消" : nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
    UIButton *button = (UIButton *)[_bgTextView viewWithTag:2015];
    [button setTitle:@"表情" forState:UIControlStateNormal];
    [self hideFaceView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
