//
//  POSPrinter.h
//  HelloWorld
//
//  Created by Pavel Osipov on 24.12.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol POSPrinter
- (void)printMessage:(nonnull NSString *)message;
@end

@interface POSPrinter : NSObject <POSPrinter>
@end
