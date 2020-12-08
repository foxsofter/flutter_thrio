//
//  ThrioRegistrySetTests.m
//  thrio_exampleTests
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 foxsofter. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <thrio/Thrio.h>

@interface ThrioRegistrySetTests : XCTestCase

@end

@implementation ThrioRegistrySetTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSet{
  ThrioRegistrySet *set = [ThrioRegistrySet set];
  XCTAssertNotNil(set);
}

- (void)testRegistry {
  ThrioRegistrySet *set = [ThrioRegistrySet set];
  [set registry:@"test1"];
  XCTAssertTrue([[set valueForKey:@"sets"] containsObject:@"test1"]);
}

- (void)testRegistryAll {
  ThrioRegistrySet *set = [ThrioRegistrySet set];
  [set registryAll:[NSSet setWithObject:@"test1"]];
  XCTAssertEqual([[set valueForKey:@"sets"] allObjects].firstObject, @"test1");
}

- (void)testClear {
  ThrioRegistrySet *set = [ThrioRegistrySet set];
  [set registryAll:[NSSet setWithObject:@"test1"]];
  [set clear];
  XCTAssertEqual([[set valueForKey:@"sets"] count], 0);
}

- (void)testValues {
  ThrioRegistrySet *set = [ThrioRegistrySet set];
  [set registryAll:[NSSet setWithObject:@"test1"]];
  XCTAssertEqual([[set valueForKey:@"sets"] allObjects].firstObject, @"test1");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
