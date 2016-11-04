//
//  BFLoader.m
//  BigFootUpdaterForMac
//
//  Created by huangzh on 16/11/4.
//  Copyright © 2016年 RIck. All rights reserved.
//

#import "BFLoader.h"

@implementation BFLoader
+(void)loadVersion:(void(^)(NSString *))complete
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
+(NSString *)parseHtml:(NSString *)htmlStr
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
@end
