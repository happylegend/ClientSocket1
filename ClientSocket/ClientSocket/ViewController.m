//
//  ViewController.m
//  ClientSocket
//
//  Created by 紫冬 on 13-9-16.
//  Copyright (c) 2013年 qsji. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //第一步:创建客户端的Socket监听
    CFSocketContext socketContext = {
        0,                           //结构体的版本，必须为0
        self,                        //一个任意指针的数据，可以用在创建时CFSocket对象相关联。这个指针被传递给所有的上下文中定义的回调。
        NULL,                        //一个任意指针的数据，可以用在创建是CFSocket对象相关联。这个指针被传递给所有的上下文中定义的回调。
        NULL,
        NULL
    };
    
    _socket = CFSocketCreate(kCFAllocatorDefault,// 为新对象分配内存，可以为nil
                            
                            PF_INET, // 协议族，如果为0或者负数，则默认为PF_INET
                            
                            SOCK_STREAM, // 套接字类型，如果协议族为PF_INET,则它会默认为SOCK_STREAM
                            
                            IPPROTO_TCP, // 套接字协议，如果协议族是PF_INET且协议是0或者负数，它会默认为IPPROTO_TCP
                            
                            kCFSocketConnectCallBack, // 触发回调函数的socket消息类型，具体见CallbackTypes
                            
                            TCPServerConnectCallBack, // 上面情况下触发的回调函数
                            
                            &socketContext // 一个持有CFSocket结构信息的对象，可以为nil
                
                            );
    
    //设置将要连接的服务器的地址
    struct sockaddr_in addr4;  //IPV4
    
    if (_socket)
    {
        NSString *serverAddress = @"192.168.0.110";
        int port = 8888;                 
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = htons(port);
        addr4.sin_addr.s_addr = inet_addr([serverAddress UTF8String]);        // 把字符串的地址转换为机器可识别的网络地址
    }    
    
    // 把sockaddr_in结构体中的地址转换为Data
    CFDataRef dataAddress = CFDataCreate(kCFAllocatorDefault, (UInt8*)&addr4, sizeof(addr4));
    
    
    //执行连接服务器
    
    CFSocketConnectToAddress(_socket,                    //连接的Socket
                             dataAddress,                    //CFDataRef类型的包含上面socket的远程地址的对象
                             -1);                        //连接超时时间，如果为负，则不尝试连接，而是把连接放在后台进行，
                                                         //如果_socket消息类型为kCFSocketConnectCallBack，将会在连接成功或失败的时候在后台触发回调函数
    
    CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();     //获取当前线程的循环
    
    //将_socket加入到循环资源，进而可以让socket来不停的监听端口
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);  //定义循环对象
    
    //将循环资源对象想加入到当前循环中
    CFRunLoopAddSource(runLoopRef,               //运行循环
                       sourceRef,                //增加的运行循环源，他会被retain一次
                       kCFRunLoopCommonModes);   //增加的运行循环源的模式
    
    CFRelease(sourceRef);    
    
}


//设置回调函数,连接成功以及发送成功接受的回调函数：
//socket回调函数的格式
static void TCPServerConnectCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    if (data)
    {
        // 当socket为kCFSocketConnectCallBack时，失败时回调失败会返回一个错误代码指针，其他情况返回NULL
        NSLog(@"连接失败");
        return;
    }
    else
    {
        NSLog(@"连接成功");
        NSObject *object = (NSObject *)info;
        [object performSelectorInBackground:@selector(readStream) withObject:nil];  //读取数据
    }

}


-(void)readStream
{
    char buffer[1024];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    while (recv(CFSocketGetNative(_socket),                    //与本机关联的Socket 如果已经失效返回－1:INVALID_SOCKET                
                                             buffer, sizeof(buffer), 0))
    {
        textViewReceive.text = [NSString stringWithUTF8String:buffer];
        NSLog(@"%@", textViewReceive.text);
    }
    
    [pool release];
}


-(void)printmy
{
    NSLog(@"printmy");
}

//发送数据
-(IBAction)onClickButtonSend:(id)sender
{
    if ((textViewSend.text == nil) || [textViewSend.text isEqualToString:@""])
    {
        NSLog(@"内容不能为空");
        return;
    }
    
    NSString *stringTosend = textViewSend.text;
    
    const char *data = [stringTosend UTF8String];
    
    send(CFSocketGetNative(_socket), data, strlen(data) + 1, 0);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
