//
//  ViewController.m
//  BigFootUpdaterForMac
//
//  Created by huangzh on 16/11/4.
//  Copyright © 2016年 RIck. All rights reserved.
//

#import "ViewController.h"
#import "BFLoader.h"

#define PATH_KEY    @"wow_path"

@interface ViewController ()<BFLoaderDelegate>

@property (weak) IBOutlet NSTextField *labVersion;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSTextField *labPath;
@property (weak) IBOutlet NSProgressIndicator *progress;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //init path
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:PATH_KEY];
    if(path.length > 0)
    {
        self.labPath.stringValue = path;
    }
    else
    {
        self.labPath.stringValue = @"暂未设置wow目录";
    }
    
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
    
    [[BFLoader loader] loadVersion:^(NSString *version) {
        if(version)
        {
            self.labVersion.stringValue = version;
            
            [BFLoader loader].delegate = self;
            [[BFLoader loader] downloadWithVersion:version complete:nil];

        }
        else
        {
            self.labVersion.stringValue = @"获取版本失败";
        }
        
        [self.indicator stopAnimation:self];
        self.indicator.hidden = YES;
        
    }];
}

- (IBAction)choosePath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@""];
    [panel setPrompt:@"OK"];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:YES];
    NSString *path_all;
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton)
    {
        path_all = [[panel URL] path];
        [self savePath:path_all];
    }

}
-(void)savePath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:PATH_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.labPath.stringValue = path;
}
#pragma mark - BFLoader delegate
-(void)downloadProgressUpdated:(CGFloat)percent
{
    [self.progress setDoubleValue:percent];
}
@end
