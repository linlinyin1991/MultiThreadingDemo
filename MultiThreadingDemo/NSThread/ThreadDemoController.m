//
//  ThreadDemoController.m
//  MultiThreadingDemo
//
//  Created by yin linlin on 2018/5/21.
//  Copyright © 2018年 yin linlin. All rights reserved.
//

#import "ThreadDemoController.h"

@interface ThreadDemoController ()

@property (nonatomic, assign) NSInteger ticketsCount;
@property (nonatomic, strong) NSLock *threadLock;
@property (nonatomic, strong) NSCondition *condition;

@end

@implementation ThreadDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self threadDemo];
}

/*
 NSThread属于轻量级多任务实现方式，可以直观的管理线程的生命周期、同步、加锁等问题，缺点是会导致一定的性能开销
 */
- (void)threadDemo {
    
    self.threadLock = [[NSLock alloc]init];
    self.condition = [[NSCondition alloc] init];
    
    self.ticketsCount = 100;
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(sellTicket) object:nil];
    thread1.name=@"thread1";
    
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(sellTicket) object:nil];
    thread2.name=@"thread2";
    
    NSThread *thread3 = [[NSThread alloc] initWithTarget:self selector:@selector(sellTicket) object:nil];
    thread3.name=@"thread3";
    
    [thread1 start];
    [thread2 start];
    [thread3 start];
}

- (void)sellTicket {
    while (self.ticketsCount > 0) {
        @synchronized(self) {
            NSThread *thread = [NSThread currentThread];
            [NSThread sleepForTimeInterval:2];
            self.ticketsCount -- ;
            NSLog(@"当前线程:%@\n剩余票数为:%zd ",thread.name, self.ticketsCount);
        }
    }
}

- (void)sellTicketByLock {
    while (self.ticketsCount > 0) {
        [self.threadLock lock];
        NSThread *thread = [NSThread currentThread];
        [NSThread sleepForTimeInterval:2];
        self.ticketsCount -- ;
        NSLog(@"当前线程:%@\n剩余票数为:%zd ",thread.name, self.ticketsCount);
        [self.threadLock unlock];
    }
}

- (void)sellTicketByCondition {
    while (self.ticketsCount > 0) {
        [self.condition lock];
        NSThread *thread = [NSThread currentThread];
        [NSThread sleepForTimeInterval:2];
        self.ticketsCount -- ;
        NSLog(@"当前线程:%@\n剩余票数为:%zd ",thread.name, self.ticketsCount);
        [self.condition unlock];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
