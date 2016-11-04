//
//  BFLoader.h
//  BigFootUpdaterForMac
//
//  Created by huangzh on 16/11/4.
//  Copyright © 2016年 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFLoader : NSObject
+(void)loadVersion:(void(^)(NSString *))complete;
@end
