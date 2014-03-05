//
//  LKViewController.m
//  AddScore
//
//  Created by ljh on 14-3-4.
//  Copyright (c) 2014年 LJH. All rights reserved.
//

#import "LKViewController.h"
#import "LKAddScoreView.h"


@interface LKViewController ()
@property float score;
@end

@implementation LKViewController

#define step 0.2

- (IBAction)bt_add:(id)sender {
    [[LKAddScoreView shareInstance] showMessage:@"欧耶" subMes:@"+20分" fromScore:_score toScore:MIN(1, _score + step)];
    _score = MIN(1, _score + step);
}
- (IBAction)bt_cut:(id)sender {
    [[LKAddScoreView shareInstance] showMessage:@"买噶" subMes:@"-20分" fromScore:_score toScore:MAX(0, _score - step)];
    _score = MAX(0, _score - step);
}

@end
