//
//  ViewController.m
//  BigFootUpdaterForMac
//
//  Created by huangzh on 16/11/4.
//  Copyright © 2016年 RIck. All rights reserved.
//

#import "ViewController.h"
#import "BFLoader.h"
#import <SSZipArchive.h>

#define PATH_KEY    @"wow_path"
#define LOCAL_VERSION @"local_version"

@interface ViewController ()<BFLoaderDelegate>
{
    NSString *newVersion;
    NSString *wowPath;
}

@property (weak) IBOutlet NSTextField *labVersion;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSTextField *labPath;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSTextField *labLocalVersion;
@property (weak) IBOutlet NSTextField *lablog;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //init path
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:PATH_KEY];
    if(path.length > 0)
    {
        self.labPath.stringValue = path;
        wowPath = path;
    }
    else
    {
        self.labPath.stringValue = @"暂未设置wow目录";
    }
    

    //local version
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_VERSION];
    NSString *versionStr = [NSString stringWithFormat:@"本地插件版本：%@", localVersion?localVersion:@""];
    self.labLocalVersion.stringValue = versionStr;
    
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
    [self showLog:@"正在获取最新插件版本"];
    
    [[BFLoader loader] loadVersion:^(NSString *version) {
        if(version)
        {
            self.labVersion.stringValue = version;
            newVersion = version;
            [self showLog:@""];
        }
        else
        {
            [self showLog:@"获取插件版本失败"];
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
    wowPath = path;
}
- (IBAction)update:(id)sender {
    
    if(newVersion == nil)
    {
        [self showLog:@"无法更新（没有获取到最新版本号）"];
        return;
    }
    if(wowPath == nil)
    {
        [self showLog:@"请先设置魔兽目录"];
        return;
    }
    
    [self showLog:@"正在下载"];
    [BFLoader loader].delegate = self;
    [[BFLoader loader] downloadWithVersion:newVersion];
}
#pragma mark - BFLoader delegate
-(void)downloadProgressUpdated:(CGFloat)percent
{
    [self.progress setDoubleValue:percent];
}
-(void)downloadDidfinshed:(NSString *)filePath
{
    if(filePath)
    {
        [self showLog:@"下载完成"];

        if(wowPath)
        {
            [self showLog:@"正在解压"];
            if([SSZipArchive unzipFileAtPath:filePath toDestination:wowPath])
            {
                [[NSUserDefaults standardUserDefaults] setValue:newVersion forKey:LOCAL_VERSION];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                self.labLocalVersion.stringValue = [NSString stringWithFormat:@"本地插件版本：%@", newVersion];
                [self showLog:@"解压成功"];
            }
            else
            {
                [self showLog:@"解压失败"];
            }
        }
        else
        {
            [self showLog:@"无法解压：没有设置魔兽路径"];
        }
    }
}
#pragma mark - Log
-(void)showLog:(NSString *)log
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lablog.stringValue = log;
    });
}
@end
