//
//  POSHTTPRequestTests.m
//  POSRx
//
//  Created by Pavel Osipov on 06.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequestMethod.h"
#import "NSString+POSRx.h"
#import <XCTest/XCTest.h>

@interface POSHTTPRequestMethodTests : XCTestCase
@end

@implementation POSHTTPRequestMethodTests

#pragma mark - Path Tests

- (void)testPathConcatWithoutSlashes {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"pavelosipov"];
    NSURL *partialURL = [@"https://github.com" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" posrx_URL]);
}

- (void)testPathConcatWithSlashAfterHost {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"pavelosipov"];
    NSURL *partialURL = [@"https://github.com/" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" posrx_URL]);
}

- (void)testPathConcatWithSlashedPath {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"/pavelosipov"];
    NSURL *partialURL = [@"https://github.com" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" posrx_URL]);
}

- (void)testPathConcatWithSlashesEverywhere {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"/pavelosipov"];
    NSURL *partialURL = [@"https://github.com/" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov" posrx_URL]);
}

#pragma mark - Query Tests

- (void)testQueryConcatWithHostWithoutSlash {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod query:@{@"number": @0,
                                                                 @"string": @"s",
                                                                 @"boolean": @YES}];
    NSURL *partialURL = [@"https://github.com" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com?number=0&string=s&boolean=1" posrx_URL]);
}

- (void)testQueryConcatWithHostWithSlash {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod query:@{@"number": @0,
                                                                 @"string": @"s",
                                                                 @"boolean": @NO}];
    NSURL *partialURL = [@"https://github.com/" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/?number=0&string=s&boolean=0" posrx_URL]);
}

#pragma mark - Path & Query Tests

- (void)testPathAndQueryConcatWithHostWithoutSlash {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"pavelosipov"
                                                        query:@{@"number": @0,
                                                                @"string": @"s",
                                                                @"boolean": @YES}];
    NSURL *partialURL = [@"https://github.com" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov?number=0&string=s&boolean=1" posrx_URL]);
}

- (void)testPathAndQueryConcatWithHostWithSlash {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"pavelosipov"
                                                        query:@{@"number": @0,
                                                                @"string": @"s",
                                                                @"boolean": @NO}];
    NSURL *partialURL = [@"https://github.com/" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov?number=0&string=s&boolean=0" posrx_URL]);
}

- (void)testPathWithSlashesAndQueryConcatWithHostWithoutSlash {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"/pavelosipov/"
                                                        query:@{@"number": @0,
                                                                @"string": @"s",
                                                                @"boolean": @NO}];
    NSURL *partialURL = [@"https://github.com" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov/?number=0&string=s&boolean=0" posrx_URL]);
}

- (void)testPathWithSlashesAndQueryConcatWithHostWithSlash {
    POSHTTPRequestMethod *method = [POSHTTPRequestMethod path:@"/pavelosipov/"
                                                        query:@{@"number": @0,
                                                                @"string": @"s",
                                                                @"boolean": @NO}];
    NSURL *partialURL = [@"https://github.com/" posrx_URL];
    NSURL *fullURL = [method appendTo:partialURL];
    XCTAssertEqualObjects(fullURL, [@"https://github.com/pavelosipov/?number=0&string=s&boolean=0" posrx_URL]);
}

@end
