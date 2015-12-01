//
//  ViewController.m
//  ASDKDeadlock
//
//  Created by Adlai Holler on 12/1/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

#import "ViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self pingMainThreadAndRepeat];
    });

    ASDisplayNode *node = [ASDisplayNode new];
    ASTextNode *textNode = [ASTextNode new];
    [node addSubnode:textNode];

    // Start updating the text on a background queue (we use high priority to make the race more likely.)
    dispatch_queue_t textNodeQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    dispatch_async(textNodeQueue, ^{
        textNode.attributedString = [NSAttributedString new];
    });

    // Load the node's view
    [node view];
}

- (void)pingMainThreadAndRepeat {
    __block BOOL responded = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        responded = YES;
    });

    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), queue, ^{
        NSAssert(responded, @"Main queue failed to respond within 1 second. Deadlocked?");
        [self pingMainThreadAndRepeat];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
