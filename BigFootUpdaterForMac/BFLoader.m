//
//  BFLoader.m
//  BigFootUpdaterForMac
//
//  Created by huangzh on 16/11/4.
//  Copyright © 2016年 RIck. All rights reserved.
//

#import "BFLoader.h"

@interface BFLoader ()<NSURLSessionDelegate>
@end

@implementation BFLoader
+(instancetype)loader
{
    static dispatch_once_t onceToken;
    static BFLoader *instance;
    dispatch_once(&onceToken, ^{
        instance = [[BFLoader alloc] init];
    });
    return instance;
}
-(void)loadVersion:(void(^)(NSString *))complete
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://bigfoot.178.com/wow/update.html"];

    NSURLSessionTask *task = [session dataTaskWithURL:url
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError* error) {

                                        NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                        
                                        NSString *version = [self parseHtml:htmlStr];
                                        
                                        if(complete)
                                        {
                                            complete(version);
                                        }
                                        
                                    }];
    [task resume];
 
}
-(NSString *)parseHtml:(NSString *)htmlStr
{
    ///<span class="tit">V7.1.0.599版本说明</span>
    
    NSString *regStr = @"<span class=\"tit\">.+?</span>";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regStr options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *regArray=[reg matchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length])];
    
    if(regArray.count == 0)
    {
        return nil;
    }
    
    NSTextCheckingResult *result = regArray[0];
    
    NSString *matchStr = [htmlStr substringWithRange:result.range];
    
    NSRange headRange = [matchStr rangeOfString:@">V"];
    NSRange tailRange = [matchStr rangeOfString:@"版本说明"];
    
    if(headRange.location == NSNotFound || tailRange.location == NSNotFound)
    {
        return nil;
    }
    
    NSRange versionRange = NSMakeRange(headRange.location + headRange.length, tailRange.location - (headRange.location + headRange.length));
    NSString *version = [matchStr substringWithRange:versionRange];
    
    return version;
}
#pragma -mark 下载
-(void)downloadWithVersion:(NSString *)version
{
    if(version.length == 0)
    {
        return;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://wow.bfupdate.178.com/BigFoot/Interface/3.1/Interface.%@.zip", version]];

    [[session downloadTaskWithURL:url] resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"%f",progress);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadProgressUpdated:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloadProgressUpdated:progress];
        });
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    NSString *desPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents"];
    NSString *filePath = [desPath stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSError *error;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    if([[NSFileManager defaultManager] moveItemAtPath:location.path toPath:filePath error:&error])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(downloadDidfinshed:)])
        {
            [self.delegate downloadDidfinshed:filePath];
        }
    }
    NSLog(@"%@", error);
}
@end
