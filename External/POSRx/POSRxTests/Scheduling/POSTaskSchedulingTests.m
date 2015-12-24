//
//  POSTaskSchedulingTests.m
//  POSRx
//
//  Created by Osipov on 09.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <POSRx/POSRx.h>

@interface POSTaskSchedulingTests : XCTestCase

@end

@implementation POSTaskSchedulingTests

- (void)testSchedulingEventFromNonTaskScheduler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completes"];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTaskContext *context) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            return [[RACScheduler scheduler] schedule:^{
                [subscriber sendNext:@1];
                [subscriber sendCompleted];
            }];
        }];
    }];
    [task.values subscribeNext:^(NSNumber *value) {
        XCTAssertEqual(value, @1);
        [expectation fulfill];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.values subscribeNext:^(NSNumber *value) {
            XCTAssertEqualObjects(value, @(1));
        }];
    }];
}

- (void)testTaskBlockExecutionShouldBeShecduledWithSpecifiedScheduler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task scheduledu"];
    RACTargetQueueScheduler *taskScheduler = [RACTargetQueueScheduler pos_scheduler];
    [taskScheduler schedule:^{
        POSTask *task = [POSTask createTask:^RACSignal *(POSTaskContext *context) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                XCTAssert([RACScheduler currentScheduler] == taskScheduler);
                [subscriber sendCompleted];
                [expectation fulfill];
                return nil;
            }];
        } scheduler:taskScheduler];
        [[RACScheduler mainThreadScheduler] schedule:^{
            [task schedule:^{
                [task execute];
            }];
        }];
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
