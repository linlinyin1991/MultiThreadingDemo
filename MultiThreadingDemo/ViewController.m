//
//  ViewController.m
//  MultiThreadingDemo
//
//  Created by yin linlin on 2018/5/21.
//  Copyright © 2018年 yin linlin. All rights reserved.
//

#import "ViewController.h"
#import "ThreadDemoController.h"
#import "GCDDemoController.h"
#import "OperationDemoController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"多线程demo";
    [self.titleArray addObject:@"NSThread"];
    [self.titleArray addObject:@"GCD"];
    [self.titleArray addObject:@"NSOperation"];
    [self.view addSubview:self.table];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableReuse = @"cellTable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableReuse];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableReuse];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[ThreadDemoController new] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[GCDDemoController new] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[OperationDemoController new] animated:YES];
//            break;
        case 3:
            //            [self.navigationController pushViewController:[BKJKBankScanHViewController new] animated:YES];
            break;
        default:
            break;
    }
}
- (UITableView *)table {
    if (_table == nil) {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _table.dataSource = self;
        _table.delegate = self;
    }
    return _table;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [[NSMutableArray alloc] init];
    }
    return _titleArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
