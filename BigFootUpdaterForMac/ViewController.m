//
//  ViewController.m
//  BigFootUpdaterForMac
//
//  Created by huangzh on 16/11/4.
//  Copyright © 2016年 RIck. All rights reserved.
//

#import "ViewController.h"
#import "BFLoader.h"
@interface ViewController ()

@property (weak) IBOutlet NSTextField *labVersion;
@property (weak) IBOutlet NSProgressIndicator *indicator;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self loadVersion];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
-(void)loadVersion
{
    //load version
    
    self.indicator.hidden = NO;
    [self.indicator startAnimation:self];
    
    [BFLoader loadVersion:^(NSString *version) {
        if(version)
        {
            self.labVersion.stringValue = version;
        }
        else
        {
            self.labVersion.stringValue = @"获取版本失败";
        }
        
        [self.indicator stopAnimation:self];
        self.indicator.hidden = YES;
    }];
}

@end
