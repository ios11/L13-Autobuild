//
//  POSSchedulableObject.m
//  POSRx
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"
#import "NSException+POSRx.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

static char kPOSQueueSchedulerKey;

@interface POSScheduleProtectionOptions ()
@property (nonatomic) RACSequence *includedSelectors;
@property (nonatomic) RACSequence *excludedSelectors;
@end

@implementation POSScheduleProtectionOptions

+ (instancetype)defaultOptionsForClass:(Class)aClass {
    return [self.class include:[POSSchedulableObject selectorsForClass:aClass nonatomicOnly:YES]
                       exclude:[POSSchedulableObject selectorsForClass:[NSObject class]]];
}

+ (instancetype)include:(RACSequence *)includes exclude:(RACSequence *)excludes {
    POSScheduleProtectionOptions *options = [[POSScheduleProtectionOptions alloc] init];
    options.includedSelectors = includes;
    options.excludedSelectors = excludes;
    return options;
}

- (instancetype)include:(RACSequence *)includes {
    _includedSelectors = _includedSelectors ? [_includedSelectors concat:includes] : includes;
    return self;
}

- (instancetype)exclude:(RACSequence *)excludes {
    _excludedSelectors = _excludedSelectors ? [_excludedSelectors concat:excludes] : excludes;
    return self;
}

@end

@interface POSSchedulableObject ()
@property (nonatomic) RACTargetQueueScheduler *scheduler;
@end

@implementation POSSchedulableObject

POSRX_DEADLY_INITIALIZER(init)

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler {
    POSRX_CHECK(scheduler);
    if (self = [super init]) {
        NSParameterAssert([self.class
                           protect:self
                           forScheduler:scheduler
                           options:[[POSScheduleProtectionOptions
                                     defaultOptionsForClass:[self class]]
                                    exclude:[self.class selectorsForProtocol:@protocol(POSSchedulable)]]]);
        _scheduler = scheduler;
    }
    return self;
}

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler options:(POSScheduleProtectionOptions *)options {
    POSRX_CHECK(scheduler);
    if (self = [super init]) {
        NSParameterAssert([self.class protect:self forScheduler:scheduler options:options]);
        _scheduler = scheduler;
    }
    return self;
}

- (RACDisposable *)schedule:(void (^)(void))block {
    return [_scheduler schedule:block];
}

#pragma mark - POSSchedulableObject

+ (BOOL)protect:(id)object forScheduler:(RACTargetQueueScheduler *)scheduler {
    return [self.class protect:object
                  forScheduler:scheduler
                       options:[POSScheduleProtectionOptions defaultOptionsForClass:[object class]]];
}

+ (BOOL)protect:(id)object forScheduler:(RACTargetQueueScheduler *)scheduler options:(POSScheduleProtectionOptions *)options {
    if (!options.includedSelectors) {
        return YES;
    }
    dispatch_queue_set_specific(scheduler.queue, &kPOSQueueSchedulerKey, (__bridge void *)scheduler, NULL);
    NSMutableArray *protectingSelectors = [[options.includedSelectors array] mutableCopy];
    if (options.excludedSelectors) {
        [protectingSelectors removeObjectsInArray:[options.excludedSelectors array]];
    }
    for (NSValue *selectorValue in protectingSelectors) {
        SEL selector = (SEL)[selectorValue pointerValue];
        NSString *selectorName = NSStringFromSelector(selector);
        if ([selectorName rangeOfString:@"init"].location != NSNotFound ||
            [selectorName rangeOfString:@".cxx_destruct"].location != NSNotFound ||
            [selectorName rangeOfString:@"aspects__"].location != NSNotFound) {
            continue;
        }
        NSError *error;
        @weakify(object);
        id hooked = [object aspect_hookSelector:selector withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
            @strongify(object);
            RACScheduler *currentScheduler = (__bridge RACScheduler *)dispatch_get_specific(&kPOSQueueSchedulerKey);
            if (!currentScheduler) {
                currentScheduler = [RACScheduler currentScheduler];
            }
            if ([aspectInfo instance] == object && currentScheduler != scheduler) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"Incorrect scheduler to invoke '%@'.", selectorName]
                                             userInfo:nil];
            }
        } error:&error];
        if (!hooked) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
    }
    return YES;
}

+ (RACSequence *)selectorsForClass:(Class)aClass {
    return [[self.class p_selectorsSetForClass:aClass nonatomicOnly:NO] rac_sequence];
}

+ (RACSequence *)selectorsForClass:(Class)aClass nonatomicOnly:(BOOL)nonatomicOnly {
    return [[self.class p_selectorsSetForClass:aClass nonatomicOnly:nonatomicOnly] rac_sequence];
}

+ (RACSequence *)selectorsForProtocol:(Protocol *)aProtocol {
    return [[self.class p_selectorsSetForProtocol:aProtocol] rac_sequence];
}

#pragma mark - Private

+ (NSSet *)p_selectorsSetForClass:(Class)aClass nonatomicOnly:(BOOL)nonatomicOnly {
    Class base = class_getSuperclass(aClass);
    NSSet *baseSelectors = base ? [self p_selectorsSetForClass:base nonatomicOnly:nonatomicOnly] : [NSSet set];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    NSMutableSet *selectors = [NSMutableSet setWithCapacity:methodCount];
    for (unsigned int i = 0; i < methodCount; ++i) {
        SEL selector = method_getName(methods[i]);
        if (nonatomicOnly) {
            objc_property_t property = class_getProperty(
                aClass,
                NSStringFromSelector(selector).UTF8String);
            if (property && !property_copyAttributeValue(property, "N")) {
                continue;
            }
        }
        [selectors addObject:[NSValue valueWithPointer:method_getName(methods[i])]];
    }
    free(methods);
    [selectors unionSet:baseSelectors];
    return selectors;
}

+ (NSSet *)p_selectorsSetForProtocol:(Protocol *)aProtocol {
    unsigned int methodCount = 0;
    NSMutableSet *selectors = [NSMutableSet setWithCapacity:methodCount];
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(aProtocol, YES, YES, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        [selectors addObject:[NSValue valueWithPointer:methods[i].name]];
    }
    free(methods);
    return selectors;
}

@end
