//
//  OperationDemoController.m
//  MultiThreadingDemo
//
//  Created by yin linlin on 2018/5/21.
//  Copyright © 2018年 yin linlin. All rights reserved.
//

#import "OperationDemoController.h"

@interface OperationDemoController ()

@property (nonatomic, copy) NSArray *titles;

@end

@implementation OperationDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setUI];
}

- (void)setUI {
    self.titles = @[@"InvocationOperation", @"invocationInOtherThread", @"BlockOperation", @"blockOperationInOtherThread", @"simpleQueueTest", @"dependencyQueueTest",@"queuePriorityTest",@"communicationTest"];
    
    for (NSInteger i = 0; i < self.titles.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.tag = 110 + i;
        [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(50, 100 + 70 * i, self.view.bounds.size.width - 100, 44);
        [self.view addSubview:button];
    }
}

- (void)btnPressed:(UIButton *)sender {
    NSInteger tag = sender.tag - 110;
    switch (tag) {
        case 0:
            [self invocationOperationTest];
            break;
        case 1:
            [self invocationInOtherThread];
            break;
        case 2:
            [self blockOperationTest];
            break;
        case 3:
            [self blockOperationInOtherThread];
            break;
        case 4:
            [self simpleQueueTest];
            break;
        case 5:
            [self dependencyQueueTest];
            break;
        case 6:
            [self queuePriorityTest];
            break;
        case 7:
            [self communicationTest];
            break;
        default:
            break;
    }
}

#pragma mark - NSOperation Test
- (void)invocationOperationTest {
    NSLog(@"InvocationOperationCurrentThread:%@", [NSThread currentThread]); // 打印当前线程
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskTest:) object:@{@"name":@"InvocationOperation"}];
    [operation start];
}

- (void)invocationInOtherThread {
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(invocationOperationTest) object:nil];
    thread1.name=@"invocationThread";
    [thread1 start];
}
/*
 和NSInvocationOperation相比，NSBlockOperation对象不用添加到操作队列也能开启新线程，但是开启新线程是有条件的。前提是一个blockOperation中需要封装多个任务。如果只开启一个任务，默认会在当前线程执行
 */
- (void)blockOperationTest {
    NSLog(@"BlockOperationCurrentThread:%@", [NSThread currentThread]); // 打印当前线程
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self taskTest:@{@"name":@"BlockOperation1"}];
    }];
    [operation addExecutionBlock:^{
        [self taskTest:@{@"name":@"BlockOperation2"}];
    }];
    [operation addExecutionBlock:^{
        [self taskTest:@{@"name":@"BlockOperation3"}];
    }];
    [operation start];
}

- (void)blockOperationInOtherThread {
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(blockOperationTest) object:nil];
    thread1.name = @"blockThread";
    [thread1 start];
}

- (void)taskTest:(NSDictionary *)dict {
    NSString *name = [dict valueForKey:@"name"];
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"%@---%@", name,[NSThread currentThread]); // 打印当前线程
    }
}


#pragma mark - NSOperationQueue Test

- (void)simpleQueueTest {
    //主队列的获取方法
    NSOperationQueue *mainqueue = [NSOperationQueue mainQueue];
    //创建自定义队列，默认是并发执行，可以设置最大并发数
    /*
     最大并发操作数：maxConcurrentOperationCount
     maxConcurrentOperationCount 默认情况下为-1，表示不进行限制，可进行并发执行。
     maxConcurrentOperationCount 为1时，队列为串行队列。只能串行执行。
     maxConcurrentOperationCount 大于1时，队列为并发队列。
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //添加InvocationOperation
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskTest:) object:@{@"name":@"Invocation1InQueue"}];
    NSInvocationOperation *operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskTest:) object:@{@"name":@"Invocation2InQueue"}];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    //添加BlockOperation
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        [self taskTest:@{@"name":@"Block1InQueue"}];
    }];
    [operation3 addExecutionBlock:^{
        [self taskTest:@{@"name":@"Block2InQueue"}];
    }];
    [queue addOperation:operation3];
    //直接添加block
    [queue addOperationWithBlock:^{
        [self taskTest:@{@"name":@"AddBlockInQueue"}];
    }];
}

- (void)dependencyQueueTest {
    //依赖在开发中还是经常使用到的：有 A、B 两个操作，其中 A 执行完操作，B 才能执行操作
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //添加InvocationOperation
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskTest:) object:@{@"name":@"dependency1InQueue"}];
    NSInvocationOperation *operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskTest:) object:@{@"name":@"dependency2InQueue"}];
    //添加BlockOperation
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        [self taskTest:@{@"name":@"dependency3InQueue"}];
    }];
    [operation1 addDependency:operation3];
    [operation2 addDependency:operation1];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
}

- (void)queuePriorityTest {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //添加operation1，设置operation1的优先级为VeryLow
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskTest:) object:@{@"name":@"PriorityVeryLow"}];
    operation1.queuePriority = NSOperationQueuePriorityVeryLow;
    //添加operation2，默认优先级为normal
    NSInvocationOperation *operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskTest:) object:@{@"name":@"PriorityNormal"}];
    //添加operation3，优先级为VeryHigh
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        [self taskTest:@{@"name":@"PriorityVeryHigh"}];
    }];
    operation3.queuePriority = NSOperationQueuePriorityVeryHigh;
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
}

- (void)communicationTest {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5]; // 模拟耗时操作
        // 执行完当前任务刷新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"task1 have done");
        }];
    }];
    [queue addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:5]; // 模拟耗时操作
        // 执行完当前任务刷新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"task2 have done");
        }];
    }];
    
//    //阻塞当前线程，直到队列中的操作全部执行完毕。
//    [queue waitUntilAllOperationsAreFinished];
//
//    // 执行完所有任务回到主线程刷新UI
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        NSLog(@"all tasks have done");
//        self.title = @"all tasks have done";
//    }];
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
