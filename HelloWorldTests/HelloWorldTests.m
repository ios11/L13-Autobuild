//
//  HelloWorldTests.m
//  HelloWorldTests
//
//  Created by Pavel Osipov on 24.12.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "POSGreatingsService.h"
#import "POSPrinter.h"

@interface STUBPrinter : NSObject <POSPrinter>
@property (nonatomic, readonly) NSString *lastMessage;
@end

@implementation STUBPrinter
- (void)printMessage:(NSString *)message {
    _lastMessage = message;
}
@end

#pragma mark -

@interface HelloWorldTests : XCTestCase
@end

@implementation HelloWorldTests

- (void)testGreatingsService {
    STUBPrinter *printer = [STUBPrinter new];
    POSGreatingsService *greatingsService = [[POSGreatingsService alloc] initWithPrinter:printer];
    [greatingsService sayHelloToUserWithName:@"Pavel"];
    XCTAssertEqualObjects(@"Hello, Pavel", printer.lastMessage);
}

@end
