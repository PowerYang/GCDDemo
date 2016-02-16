//
//  ViewController.m
//  gcdDemo
//
//  Created by YangJingchao on 16/2/16.
//  Copyright © 2016年 YangJingchao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark 串行队列
-(void)testGCD1{
    //队列：串行、主  分为同步、异步执行
    //  串行队列
    //在当前线程中执行，不新开线程，顺序执行，同步的
    //注：DISPATCH_QUEUE_SERIAL（连续的）DISPATCH_QUEUE_CONCURRENT（并发）
        dispatch_queue_t queue = dispatch_queue_create("yjc", DISPATCH_QUEUE_SERIAL);//此处如果换为并发，下面的for循环里使用异步的话，会产生多个子线程
        for(int i= 0;i<5;i++){
            //同步
            dispatch_sync(queue, ^{
                NSLog(@"%@-----%zd",[NSThread currentThread],i);
            });
            //异步
//            dispatch_async(queue, ^{
//                NSLog(@"%@-----%zd",[NSThread currentThread],i);
//            });
        }
    
    //  串行队列，并发队列同理   创建队列的时候用DISPATCH_QUEUE_CONCURRENT
    
}

#pragma mark 主队列
-(void)testGCD2{
    //一般用法，是把主队列放在子线程中执行，这样不会造成死锁
    //新开线程执行
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"全局队列%@",[NSThread currentThread]);
            for(int i= 0;i<5;i++){
                //主队列 同步任务 在子线程中运行 同步执行不用等主线程执行此任务
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSLog(@"主队列%@-----%zd",[NSThread currentThread],i);
                });
            }
            NSLog(@"over%@",[NSThread currentThread]);
        });
}

#pragma mark 全局队列 异步任务
-(void)testGCD3{
    //后台耗时操作，并且有互相依赖的关系
    //全局队列  异步任务
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        //全局队列 同步任务
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"同步任务1");
        });
        //全局队列 同步任务
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"同步任务2");
        });
        //全局队列 同步任务
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"同步任务3");
        });
        //全局队列 同步任务
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"同步任务4");
        });
        NSLog(@"over%@",[NSThread currentThread]);
    });
    
    /*dispatch_get_global_queue(long identifier, unsigned long flags)
     // 第一个参数 identifier
     // 在iOS7中表示调度的优先级(让线程响应的更快还是更慢)
     DISPATCH_QUEUE_PRIORITY_HIGH 2 高优先级
     DISPATCH_QUEUE_PRIORITY_DEFAULT 0 默认优先级
     DISPATCH_QUEUE_PRIORITY_LOW (-2) 低优先级
     DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN 后台优先级
     // 在iOS8中表示服务质量
     QOS_CLASS_USER_INTERACTIVE 用户希望线程快点执行完毕 不要使用耗时操作
     QOS_CLASS_USER_INITIATED 用户需要的 不要使用耗时操作
     QOS_CLASS_DEFAULT 默认
     QOS_CLASS_UTILITY 耗时操作
     QOS_CLASS_BACKGROUND 后台
     QOS_CLASS_UNSPECIFIED 0 未指定优先级
     // 为了在iOS7和iOS8中适配此参数 可以直接传入0
     DISPATCH_QUEUE_PRIORITY_HIGH: QOS_CLASS_USER_INITIATED
     DISPATCH_QUEUE_PRIORITY_DEFAULT: QOS_CLASS_DEFAULT
     DISPATCH_QUEUE_PRIORITY_LOW: QOS_CLASS_UTILITY
     DISPATCH_QUEUE_PRIORITY_BACKGROUND: QOS_CLASS_BACKGROUND
     // 第二个参数 为将来保留使用 始终传入0
     */
    
}
#pragma mark Dispatch Group调度组
-(void)testGCD4{
    //还有一种方式用的比较多的就是，异步下载、上传，然后提示用户，跳转等操作
    //dispatch_group_notify
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"下载歌曲1%@-----",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"下载歌曲2%@-----",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"下载歌曲3%@-----",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"下载歌曲4%@-----",[NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //回到主队列，通知用户下载完成，进行下一步操作。跳转或提示等操作
        NSLog(@"完成！%@-----",[NSThread currentThread]);
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //测试可放开任意一个方法
    [self testGCD1];
//    [self testGCD2];
//    [self testGCD3];
//    [self testGCD4];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
