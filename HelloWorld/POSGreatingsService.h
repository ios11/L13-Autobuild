//
//  POSGreatingsService.h
//  HelloWorld
//
//  Created by Pavel Osipov on 24.12.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol POSPrinter;

@interface POSGreatingsService : NSObject

- (nonnull instancetype)initWithPrinter:(nonnull id<POSPrinter>)printer;

- (void)sayHelloToUserWithName:(nonnull NSString *)name;

@end
