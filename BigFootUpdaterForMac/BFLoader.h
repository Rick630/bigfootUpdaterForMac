//
//  BFLoader.h
//  BigFootUpdaterForMac
//
//  Created by huangzh on 16/11/4.
//  Copyright © 2016年 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BFLoaderDelegate <NSObject>

-(void)downloadProgressUpdated:(CGFloat)percent;
-(void)downloadDidfinshed:(NSString *)filePath;

@end

@interface BFLoader : NSObject

@property (nonatomic, weak) id<BFLoaderDelegate>delegate;

+(instancetype)loader;
-(void)loadVersion:(void(^)(NSString *))complete;
-(void)downloadWithVersion:(NSString *)version;
@end
