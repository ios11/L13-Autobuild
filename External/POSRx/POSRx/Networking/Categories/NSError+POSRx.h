//
//  NSError+POSRx.h
//  POSRx
//
//  Created by Pavel Osipov on 12.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (POSRx)

- (NSError *)errorWithURL:(NSURL *)URL;

@end
