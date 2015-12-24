//
//  RACTargetQueueScheduler+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 29.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACTargetQueueScheduler (POSRx)

+ (RACTargetQueueScheduler *)pos_scheduler;
+ (RACTargetQueueScheduler *)pos_mainThreadScheduler;

@end
