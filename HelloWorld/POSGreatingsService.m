//
//  POSGreatingsService.m
//  HelloWorld
//
//  Created by Pavel Osipov on 24.12.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSGreatingsService.h"
#import "POSPrinter.h"

@interface POSGreatingsService ()
@property (nonatomic, readonly) id<POSPrinter> printer;
@end

@implementation POSGreatingsService

- (instancetype)initWithPrinter:(id<POSPrinter>)printer {
    NSParameterAssert(printer);
    if (self = [super init]) {
        _printer = printer;
    }
    return self;
}

- (void)sayHelloToUserWithName:(NSString *)name {
    [_printer printMessage:[NSString stringWithFormat:@"Hello, %@", name]];
}

@end
