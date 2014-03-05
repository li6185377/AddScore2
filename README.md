AddScore2
=========

simple animation demo  use for add score，similar health point view

类似 血瓶的效果  

animation layer using CAShapeLayer
```objective-c
         self.pregress = [[CAGradientLayer alloc]init];
        _pregress.frame = CGRectMake(6,5, 64,64);
        _pregress.startPoint = CGPointMake(0.5, 1);
        _pregress.endPoint = CGPointMake(0.5, 0);
        _pregress.colors = @[(id)colorWithSYPink.CGColor,(id)[UIColor colorWithWhite:0.6 alpha:0.2].CGColor];
        _pregress.locations = @[@0,@0];
        
        CAShapeLayer* pregress_bg = [[CAShapeLayer alloc]init];
        pregress_bg.path = CGPathCreateWithEllipseInRect(_pregress.bounds, NULL);
        _pregress.mask = pregress_bg;
        
        [self.layer addSublayer:_pregress];
        ....
        NSArray* tovalue = @[@(to),@(to)];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = @[@(from),@(from)];
    animation.toValue = tovalue;
    animation.duration = 1 * fabsf(to - from);
    animation.delegate  = self;
    
    _nowTo = to;
    _pregress.locations = tovalue;
    [_pregress addAnimation:animation forKey:nil];

```

![](http://img.blog.csdn.net/20140305154553234)
