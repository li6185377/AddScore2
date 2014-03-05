//
//  LKAddScoreView.m
//  Seeyou
//
//  Created by ljh on 14-3-3.
//  Copyright (c) 2014年 linggan. All rights reserved.
//

#import "LKAddScoreView.h"

#ifndef RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#endif

@interface LKAddScoreView()
@property(strong,nonatomic)CAGradientLayer* pregress;
@property float nowTo;
@property float nextTo;

@property BOOL isAnimationing;
@property BOOL hasTo;
@property BOOL fadeIn;
@property BOOL fadeOut;

@property(strong,nonatomic)UIView* labelLayer;
@property(strong,nonatomic)UIView* whiteLayer;
@property(strong,nonatomic)UIView* pinkLayer;
@end

@implementation LKAddScoreView

+(instancetype)shareInstance
{
    static LKAddScoreView* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]initWithFrame:CGRectMake(0, 0, 86, 74)];
    });
    return instance;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"record_addbg"];
        
        self.pregress = [[CAGradientLayer alloc]init];
        _pregress.frame = CGRectMake(6,5, 64,64);
        _pregress.startPoint = CGPointMake(0.5, 1);
        _pregress.endPoint = CGPointMake(0.5, 0);
        _pregress.colors = @[(id)RGBCOLOR(255,135,160).CGColor,(id)[UIColor colorWithWhite:0.6 alpha:0.2].CGColor];
        _pregress.locations = @[@0,@0];
        
        CAShapeLayer* pregress_bg = [[CAShapeLayer alloc]init];
        pregress_bg.path = CGPathCreateWithEllipseInRect(_pregress.bounds, NULL);
        _pregress.mask = pregress_bg;
        
        [self.layer addSublayer:_pregress];
        
        self.labelLayer = [[UIView alloc]initWithFrame:CGRectMake(6,(74-28)/2, 64, 28)];
        
        self.whiteLayer = [[UIView alloc]initWithFrame:_labelLayer.bounds];
        _whiteLayer.clipsToBounds = YES;
        self.pinkLayer = [[UIView alloc]initWithFrame:_labelLayer.bounds];
        _pinkLayer.clipsToBounds = YES;
        
        [self addLabelToView:_whiteLayer textColor:[UIColor whiteColor]];
        [self addLabelToView:_pinkLayer textColor:RGBCOLOR(255,135,160)];
        
        [_labelLayer addSubview:_whiteLayer];
        [_labelLayer addSubview:_pinkLayer];
        [self addSubview:_labelLayer];
        
    }
    return self;
}
-(void)addLabelToView:(UIView*)view textColor:(UIColor*)color
{
    UILabel* _lb_message = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 14)];
    _lb_message.tag = 1121;
    _lb_message.font = [UIFont systemFontOfSize:12];
    _lb_message.textColor = color;
    _lb_message.textAlignment = NSTextAlignmentCenter;
    _lb_message.backgroundColor = [UIColor clearColor];
    [view addSubview:_lb_message];
    
    
    UILabel* _lb_sub = [[UILabel alloc]initWithFrame:CGRectMake(0, 14, 64, 14)];
    _lb_sub.tag = 1122;
    _lb_sub.font = [UIFont systemFontOfSize:12];
    _lb_sub.textColor = color;
    _lb_sub.textAlignment = NSTextAlignmentCenter;
    _lb_sub.backgroundColor = [UIColor clearColor];
    [view addSubview:_lb_sub];
}
-(void)view:(UIView*)view mes:(NSString*)mes sub:(NSString*)sub
{
    UILabel* lb = (id)[view viewWithTag:1121];
    lb.text = mes;
    
    UILabel* sb = (id)[view viewWithTag:1122];
    sb.text = sub;
}
-(void)startFrom:(float)from to:(float)to
{
    NSArray* tovalue = @[@(to),@(to)];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = @[@(from),@(from)];
    animation.toValue = tovalue;
    animation.duration = 1 * fabsf(to - from);
    animation.delegate  = self;
    
    _nowTo = to;
    _pregress.locations = tovalue;
    [_pregress addAnimation:animation forKey:nil];
    
    float height = _pregress.frame.size.height;
    float top = height * (1 - to) + _pregress.frame.origin.y;
    float pheight = MIN(_labelLayer.frame.size.height,MAX(0,top - _labelLayer.frame.origin.y));
    [UIView animateWithDuration:animation.duration animations:^{
        _pinkLayer.frame = CGRectMake(0, 0, 64, pheight);
    }];
    
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(_hasTo)
    {
        _hasTo = NO;
        if(_nowTo != _nextTo)
        {
            [self startFrom:_nowTo to:_nextTo];
            return;
        }
    }
    else
    {
        float delay=1;
        if(_nowTo >=1)
        {
            delay = 0.3;
        }
        [self performSelector:@selector(beginFadeOut) withObject:nil afterDelay:delay];
    }
    _isAnimationing = NO;
}
-(void)beginFadeOut
{
    self.fadeOut = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.35];
    
    if(_nowTo >=1)
    {
        [LKAddScoreView showFullScore];
    }
}
-(void)dismiss
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginFadeOut) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    
    [self removeFromSuperview];
    _fadeOut = NO;
}
-(void)showMessage:(NSString *)message subMes:(NSString *)subMes fromScore:(float)from toScore:(float)to
{
    [self view:_whiteLayer mes:message sub:subMes];
    [self view:_pinkLayer mes:message sub:subMes];
    
    if(_fadeOut){
        [self dismiss];
    }
    else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginFadeOut) object:nil];
    }
    
    if(_fadeIn)
    {
        _nowTo = to;
    }
    else if(self.superview == nil)
    {
        _nextTo = 0;
        _hasTo = NO;
        _isAnimationing = NO;
        
        _nowTo = to;
        
        UIWindow* window = [self.class getShowWindow];
        self.center = CGPointMake(window.center.x + 5, window.center.y + 1);
        self.alpha = 0;
        [window addSubview:self];
        
        _fadeIn = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            self.fadeIn = NO;
            [self startFrom:from to:self.nowTo];
        }];
    }
    else if(_isAnimationing)
    {
        _nextTo = to;
        _hasTo = YES;
        return;
    }
    else{
        [self startFrom:from to:to];
    }
}

+(void)addStartWithView:(UIView*)view atIndex:(int)index
{
    UIImageView* star1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"record_start"]];
    UIImageView* star2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"record_start"]];
    
    
    float r = view.bounds.size.height/2 * 0.7;
    float d = M_PI/2 + M_PI/8;
    d = d - index * M_PI/8;
    
    star1.center = CGPointMake(cosf(d)*r + view.bounds.size.width/2, sinf(d)*r + view.bounds.size.height/2);
    star2.center = CGPointMake(cosf(d)*r + view.bounds.size.width/2, sinf(d+M_PI)*r + view.bounds.size.height/2);
    
    [view addSubview:star1];
    [view addSubview:star2];
    
    CABasicAnimation* alpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpha.fromValue = @0.5;
    alpha.toValue = @1;
    
    CABasicAnimation* scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @2;
    scale.toValue = @1;
    
    CAAnimationGroup* anim = [CAAnimationGroup animation];
    anim.animations = @[alpha,scale];
    anim.duration = 0.4;
    
    [star1.layer addAnimation:anim forKey:nil];
    [star2.layer addAnimation:anim forKey:nil];
}
+(void)showFullScore
{
    UIWindow* window = [self getShowWindow];
    UIView* view = [[UIView alloc]initWithFrame:window.bounds];
    
    UIImageView* light = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 230, 230)];
    light.center = view.center;
    light.image = [UIImage imageNamed:@"record_lightone"];
    [view addSubview:light];
    [light startAnimating];
    
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.fromValue = @0;
    anim.toValue = @1;
    anim.repeatCount = INT_MAX;
    anim.duration = 3;
    [light.layer addAnimation:anim forKey:nil];
    
    
    UIImageView* bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"record_fullbg"]];
    bg.center = view.center;
    
    
    UILabel* lb1 = [[UILabel alloc]initWithFrame:CGRectMake(0, bg.bounds.size.height/2 - 16, bg.bounds.size.width, 16)];
    lb1.backgroundColor = [UIColor clearColor];
    lb1.textColor = RGBCOLOR(255,135,160);
    lb1.font = [UIFont systemFontOfSize:10];
    lb1.textAlignment = NSTextAlignmentCenter;
    lb1.text = @"太棒了";
    [bg addSubview:lb1];
    
    
    UILabel* lb2 = [[UILabel alloc]initWithFrame:CGRectMake(0, bg.bounds.size.height/2, bg.bounds.size.width, 18)];
    lb2.backgroundColor = [UIColor clearColor];
    lb2.textColor = RGBCOLOR(255,135,160);
    lb2.font = [UIFont systemFontOfSize:15];
    lb2.textAlignment = NSTextAlignmentCenter;
    lb2.text = @"100分";
    [bg addSubview:lb2];
    
    [view addSubview:bg];
    
    view.alpha = 0;
    [window addSubview:view];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self addStartWithView:bg atIndex:0];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self addStartWithView:bg atIndex:1];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self addStartWithView:bg atIndex:2];
    });
    
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.3 animations:^{
                view.alpha = 0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        });
    }];
}
+(UIWindow*)getShowWindow
{
    UIWindow *window = nil;
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *uiWindow in windows)
    {
        //有inputView或者键盘时，避免提示被挡住，应该选择这个 UITextEffectsWindow 来显示
        if ([NSStringFromClass(uiWindow.class) isEqualToString:@"UITextEffectsWindow"])
        {
            window = uiWindow;
            break;
        }
    }
    if (!window)
    {
        window = [[UIApplication sharedApplication] keyWindow];
    }
    return window;
}
@end

