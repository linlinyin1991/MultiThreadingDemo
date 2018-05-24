//
//  GCDDemoController.m
//  MultiThreadingDemo
//
//  Created by yin linlin on 2018/5/21.
//  Copyright © 2018年 yin linlin. All rights reserved.
//

#import "GCDDemoController.h"

@interface GCDDemoController ()
@property (nonatomic, copy) NSArray *titles;

@end

@implementation GCDDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"GCD test";
    self.view.backgroundColor = [UIColor lightGrayColor];
//    [self setUI];
    [self setUI2];
    
}

#pragma mark - 测试GCD基础用法
- (void)setUI {
    self.titles = @[@"SyncConCurrentTest",@"AsyncConCurrentTest",@"SyncSerialTest",@"AsyncSerialTest",@"AsyncMainQueue",@"SyncMainQueue",@"BarrierTest"];
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
            [self SyncConcurrentTest];
            break;
        case 1:
            [self AsyncConcurrentTest];
            break;
        case 2:
            [self SyncSerial];
            break;
        case 3:
            [self AsyncSerial];
            break;
        case 4:
            [self AsyncMainQueue];
            break;
        case 5:
            [self SyncMainQueue];
            break;
        case 6:
            [self barrierTest];
            break;
        default:
            break;
    }
}

- (void)testCreate {
    // 主队列的获取方法
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    /*
     全局队列
     dispatch_get_global_queue(long identifier, unsigned long flags);
     第一个参数表示优先级，使用DISPATCH_QUEUE_PRIORITY_DEFAULT就行，第二个参数暂时没用，传0
     */
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    /*
     一般队列的创建方法
     dispatch_queue_create(const char *_Nullable label,
     dispatch_queue_attr_t _Nullable attr);
     参数说明：
     * @param label:队列的唯一标识符，用于 DEBUG，可为空，Dispatch Queue 的名称推荐使用应用程序 ID 这种逆序全程域名
     * @param attr:用来标识是串行队列(DISPATCH_QUEUE_SERIAL)还是并发队列(DISPATCH_QUEUE_CONCURRENT)。文档后面还有一句说明：or the result of a call to a dispatch_queue_attr_make_with_* function，一般不用
     */
    dispatch_queue_t queue1 = dispatch_queue_create("elaine.yin", DISPATCH_QUEUE_SERIAL);//串行队列
    dispatch_queue_t queue2 = dispatch_queue_create("elaine.yin", DISPATCH_QUEUE_CONCURRENT);//并发队列
    //执行任务sync&async
    dispatch_async(mainQueue, ^{
        // 这里放异步执行任务代码
    });
    dispatch_sync(globalQueue, ^{
        // 这里放同步执行任务代码
    });
}

/*
 同步执行 + 并发队列
 异步执行 + 并发队列
 同步执行 + 串行队列
 异步执行 + 串行队列
 */
#pragma mark - 同步执行 + 并发队列
//同步执行 + 并发队列
- (void)SyncConcurrentTest {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"SyncConcurrent---begin");
    dispatch_queue_t queue = dispatch_queue_create("SyncConcurrent.elaine.yin", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"SyncConcurrent---end");
}

#pragma mark - 异步执行 + 并发队列
- (void)AsyncConcurrentTest {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"AsyncConcurrent---begin");
    dispatch_queue_t queue = dispatch_queue_create("AsyncConcurrent.elaine.yin", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1:%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"AsyncConcurrent---end");
}

#pragma mark - 同步执行 + 串行队列
- (void)SyncSerial {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"SyncSerial---begin");
    dispatch_queue_t queue = dispatch_queue_create("SyncSerial.elaine.yin", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:1];
            NSLog(@"2:%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"SyncSerial---end");
}

#pragma mark - 异步执行 + 串行队列
- (void)AsyncSerial {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"AsyncSerial---begin");
    dispatch_queue_t queue = dispatch_queue_create("AsyncSerial.elaine.yin", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1:%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2:%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3:%@",[NSThread currentThread]);
        }
    });
    NSLog(@"AsyncSerial---end");
}

#pragma mark - 异步执行 + 主队列
- (void)AsyncMainQueue {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"AsyncMainQueue---begin");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1:%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2:%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3:%@",[NSThread currentThread]);
        }
    });
    NSLog(@"AsyncMainQueue---end");
}

#pragma mark - 同步执行 + 主队列
- (void)SyncMainQueue {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"SyncMainQueue---begin");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1:%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2:%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i < 2; i ++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3:%@",[NSThread currentThread]);
        }
    });
    NSLog(@"SyncMainQueue---end");
}

#pragma mark - 测试GCD进阶用法
- (void)setUI2 {
    self.titles = @[@"栅栏BarrierTest",@"延时AfterTest",@"一次函数OnceTest",@"快速遍历ApplyTest",@"任务组GroupTest",@"信号量SemaphoreTest"];
    for (NSInteger i = 0; i < self.titles.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.tag = 220 + i;
        [button addTarget:self action:@selector(highGCDBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(50, 100 + 70 * i, self.view.bounds.size.width - 100, 44);
        [self.view addSubview:button];
    }
}

- (void)highGCDBtnPressed:(UIButton *)sender {
    NSInteger tag = sender.tag - 220;
    switch (tag) {
        case 0:
            [self barrierTest];
            break;
        case 1:
            [self afterTest];
            break;
        case 2:
            [self onceTest];
            break;
        case 3:
            [self applyTest];
            break;
        case 4:
            [self groupTest];
            break;
        case 5:
            [self semaphoreTest];
            break;
        default:
            break;
    }
}
#pragma mark - dispatch_barrier_async
- (void)barrierTest {
    dispatch_queue_t queue = dispatch_queue_create("barrier.elaine.yin", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"test1");
    });
    dispatch_async(queue, ^{
        NSLog(@"test2");
    });
    dispatch_async(queue, ^{
        NSLog(@"test3");
    });
    dispatch_barrier_async(queue, ^{
        NSInteger sum = 0;
        for (NSInteger i = 0; i < 100; i ++) {
            sum = sum + i;
        }
        NSLog(@"barrier done---%zd",sum);
    });
    NSLog(@"test5");
    dispatch_async(queue, ^{
        NSLog(@"test4");
    });
    NSLog(@"test6");
}
- (void)afterTest {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = @"title1";
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.title = @"title2";
    });
}
- (void)onceTest {
    static NSString *classString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classString = [NSString stringWithFormat:@"%@",[NSDate date]];
    });
    NSLog(@"%@",classString);
}

- (void)applyTest {
    //dispatch_apply快速遍历
    NSArray *array = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(array.count, queue, ^(size_t index) {
        NSLog(@"%zu: %@", index, [array objectAtIndex:index]);
    });
    NSLog(@"apply done");
}

- (void)groupTest {
    //dispatch_group调度组：分别异步执行2个耗时任务，然后当2个耗时任务都执行完毕后再回到主线程执行任务。这时候我们可以用到GCD的dispatch_group。
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue1, ^{
        [NSThread sleepForTimeInterval:5];
        //加入到queue队列执行的block块
        for (NSInteger i = 0; i < 10000; i ++) {
            if (i == 888) {
                NSLog(@"888");
            }
        }
        NSLog(@"test1");
    });
    
    dispatch_queue_t queue2 = dispatch_queue_create("group.elaine.yin", DISPATCH_QUEUE_SERIAL);
    //调用这个方法标志着一个代码块被加入了group，和dispatch_group_async功能类似；dispatch_group_enter()、dispatch_group_leave()必须成对出现
    dispatch_group_enter(group);
    dispatch_async(queue2, ^{
        //加入到queue队列执行的block块
        for (NSInteger i = 0; i < 10000; i ++) {
            if (i == 9999) {
                NSLog(@"9999");
            }
        }
        NSLog(@"test2");
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"所有任务全部执行完毕，更换title");
        self.title = @"group";
    });
    /*
     和dispatch_group_notify功能类似(多了一个dispatch_time_t参数可以设置超时时间)，在group上任务完成前，dispatch_group_wait会阻塞当前线程(所以不能放在主线程调用)一直等待；当group上任务完成，或者等待时间超过设置的超时时间会结束等待；执行完成返回0，未执行完毕返回非0
    dispatch_group_wait是同步的所以不能放在主线程执行。
     */
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
        if (result == 0) {
            NSLog(@"加入到group的任务能在5秒之内执行完毕");
        } else {
            NSLog(@"加入到group的任务不能在5秒之内执行完毕");
        }
    });
}
//信号量测试
- (void)semaphoreTest {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block long j = 0;
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:5];
        for (NSInteger i = 0; i < 1000; i ++) {
            j ++;
        }
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

//停车场demo
- (void)parkingAreaDemo {
    //假设目前有3个停车位
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //有10辆车过来打算停车
    for (NSInteger i = 1; i <= 10; i ++) {
        dispatch_async(queue, ^{
            NSInteger carId = i;
            if (carId % 3 == 0) {
                //这几位车主不愿意一直等待，所有设定一个能接受的等待时间
                NSUInteger result = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 8 * carId * NSEC_PER_SEC));
                if (result != 0) {//超时，直接离开
                    NSLog(@"第%ld个车主不等了",carId);
                } else {
                    NSLog(@"第%ld个车主在规定的时间内等到了车位，进入停车场",carId);
                    [NSThread sleepForTimeInterval:10];
                    dispatch_semaphore_signal(semaphore);
                    NSLog(@"第%ld个车主离开,有空位了",carId);
                }
            } else {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                NSLog(@"第%ld个车主进入停车场",carId);
                [NSThread sleepForTimeInterval:10 + i * 10];
                dispatch_semaphore_signal(semaphore);
                NSLog(@"第%ld个车主离开,有空位了",carId);
            }
        });
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
