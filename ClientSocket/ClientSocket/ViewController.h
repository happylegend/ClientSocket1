//
//  ViewController.h
//  ClientSocket
//
//  Created by 紫冬 on 13-9-16.
//  Copyright (c) 2013年 qsji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>


@interface ViewController : UIViewController
{
    IBOutlet UITextView *textViewReceive;
    IBOutlet UITextView *textViewSend;
    IBOutlet UIButton *buttonSend;
    
    CFSocketRef _socket;
}

-(IBAction)onClickButtonSend:(id)sender;

@end
