//
//  ThrioRegistryMapTests.m
//  thrio_exampleTests
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 foxsofter. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <thrio/Thrio.h>

@interface ThrioRegistryMapTests : XCTestCase

@end

@implementation ThrioRegistryMapTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMap {
  ThrioRegistryMap *map = [ThrioRegistryMap map];
  XCTAssertNotNil(map);
}

- (void)testRegistry {
  ThrioRegistryMap *map = [ThrioRegistryMap map];
  [map registry:@"test1" value:@"test1_value"];
  XCTAssertEqual(map[@"test1"], @"test1_value");
}

- (void)testRegistryAll {
  ThrioRegistryMap *map = [ThrioRegistryMap map];
  [map registryAll:@{@"test1":@"test1_value"}];
  XCTAssertEqual(map[@"test1"], @"test1_value");
}

- (void)testClear {
  ThrioRegistryMap *map = [ThrioRegistryMap map];
  [map registryAll:@{@"test1":@"test1_value"}];
  [map clear];
  XCTAssertEqual(map[@"test1"], nil);
}

- (void)testObjectForKeyedSubscript {
  ThrioRegistryMap *map = [ThrioRegistryMap map];
  [map registry:@"test1" value:@"test1_value"];
  XCTAssertEqual(map[@"test1"], @"test1_value");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
