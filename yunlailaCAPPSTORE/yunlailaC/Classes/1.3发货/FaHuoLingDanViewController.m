//
//  FaHuoLingDanViewController.m
//  yunlailaC
//
//  Created by admin on 17/1/5.
//  Copyright © 2017年 com.yunlaila. All rights reserved.
//

#import "FaHuoLingDanViewController.h"
#import "SevenSwitch.h"

#import "XuanFaHuoDiZhiViewController.h"
@interface FaHuoLingDanViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,XuanFaHuoDiZhiViewControllerDelegate>
{
    UITableView *_tableView;
    UILabel *fahuoLabel;
    
    UILabel *fahuoText;   //发货地址
    UILabel *fahuorenText;   //发货人
    UILabel *fahuoPhoneText;   //发货人电话
     NSMutableDictionary *fahuodizhiDic;
    
    UILabel *wuliuText;   //物流公司
    
    UIButton *cheBtn1;
    UIButton *cheBtn2;
    UIButton *cheBtn3;
    
    UITextField *huoNameText; //货物名称
    UITextField *huoNumText;  //货物件数量
    
    SevenSwitch *switchFanPiao;
    UIButton *gouBtn;
    UILabel *valueLabel;  //预计费用
}
@end

@implementation FaHuoLingDanViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        fahuodizhiDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[fahuodizhiDic objectForKey:@"ship_address_id"] length]==0)
    {
        //获取默认发货地址
        [self getShipaddress_obtain];
    }
    
    //获取默认收货地址
    //    [self getReceiptaddress_obtain];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNav];
    [self initView];
    [APP_DELEGATE() storyBoradAutoLay:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getShipaddress_obtain
{
    NHNetworkHelper *helper = [NHNetworkHelper shareInstance];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     @"hex_client_shipaddress_obtain",@"funcId",
                                     nil];
    
    [helper Soap:commonURL Parameters:paramDic Success:^(id responseObject)
     {
         
         
         ResponseObject *obj =[ResponseObject yy_modelWithDictionary:responseObject];
         if (obj.global.flag.intValue==-4001)
         {
             [MBProgressHUD showAutoMessage:@"登录失效，请重新登录。"];
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                 sleep(2);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     //清空保存的token等数据
                     NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
                     for (int i = 0; i < [cookies count]; i++)
                     {
                         NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
                         [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                         
                     }
                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginUser];
                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfo];
                     
                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsCookie];
                     ((YLLTabBarController *)self.view.window.rootViewController).selectedIndex = 0;
                     [self.navigationController popToRootViewControllerAnimated:NO];
                     
                     
                 });
             });
             
             return;
         }
         if (obj.global.flag.intValue==-4002)
         {
             [MBProgressHUD showAutoMessage:@"该功能暂时已关闭"];
             return;
         }
         if (obj.global.flag.intValue==-4003)
         {
             [MBProgressHUD showAutoMessage:@"服务器异常，请稍后再试"];
             return;
         }
         if (obj.global.flag.intValue!=1)
         {
             [MBProgressHUD showAutoMessage:@"服务器异常，请稍后再试"];
             return;
         }
         
         if (((response *)obj.responses[0]).flag.intValue==1)
         {
             NSDictionary *item = ((response *)obj.responses[0]).items[0];
             [fahuodizhiDic removeAllObjects];
             [fahuodizhiDic setDictionary:item];
             [_tableView reloadData];
         }
         else
         {
             
         }
         NSLog(@"%@",responseObject);
     } Failure:^(NSError *error)
     {
         NSLog(@"%@",error);
         
     }];
    
}

- (void)setUpNav
{
    self.title = @"发货";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"arrow_left-" highIcon:@"arrow_left-" target:self action:@selector(pop:)];
}

- (void) initView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-TabbarHeight-20-40*APP_DELEGATE().autoSizeScaleY)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = bgViewColor;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:_tableView];
    if (IsIOS7)
        _tableView.separatorInset = UIEdgeInsetsZero;
    
    UIView *baiView = [[UIView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height-TabbarHeight-20-40*APP_DELEGATE().autoSizeScaleY, 320*APP_DELEGATE().autoSizeScaleX, 45*APP_DELEGATE().autoSizeScaleY)];
    baiView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:baiView];
    
    
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0*APP_DELEGATE().autoSizeScaleY, 150*APP_DELEGATE().autoSizeScaleX, 45*APP_DELEGATE().autoSizeScaleY)];
    valueLabel.numberOfLines = 0;
    valueLabel.textAlignment = NSTextAlignmentLeft;
    valueLabel.font = viewFont1;
    [baiView addSubview:valueLabel];
    
    NSMutableAttributedString *value = [[NSMutableAttributedString alloc] initWithString:@"预计:￥1000"];
    [value addAttribute:NSForegroundColorAttributeName value:font1_13Color range:NSMakeRange(0,3)];
    [value addAttribute:NSForegroundColorAttributeName value:titleViewColor range:NSMakeRange(3,value.length-3)];
    valueLabel.attributedText = value;
    
//    UIButton *infoBtn = [[UIButton alloc] initWithFrame: CGRectMake(160*APP_DELEGATE().autoSizeScaleX, 0, 60*APP_DELEGATE().autoSizeScaleX, 45*APP_DELEGATE().autoSizeScaleY)];
//    [infoBtn setTitle:@"明细" forState:UIControlStateNormal];
//    [infoBtn setTitle:@"明细" forState:UIControlStateHighlighted];
//   
//    infoBtn.imageEdgeInsets = UIEdgeInsetsMake(0,0 ,0,-60*APP_DELEGATE().autoSizeScaleX);
//    infoBtn.titleEdgeInsets = UIEdgeInsetsMake(0,-30*APP_DELEGATE().autoSizeScaleX ,0,0);
//    
//    [infoBtn setImage:[UIImage imageNamed:@"arrow_-down"] forState:UIControlStateNormal];
//    [infoBtn setImage:[UIImage imageNamed:@"arrow_-down"] forState:UIControlStateHighlighted];
//    [infoBtn setTitleColor:font1_13Color forState:UIControlStateNormal];
//    [infoBtn setTitleColor:font1_13Color forState:UIControlStateHighlighted];
//    [infoBtn setBackgroundImage:[UIImage imageWithColor:titleView13Color] forState:UIControlStateNormal];
//    [infoBtn setBackgroundImage:[UIImage imageWithColor:titleView13Color] forState:UIControlStateHighlighted];
//    [infoBtn addTarget:self
//                  action:@selector(infoBtnClick:)
//        forControlEvents:UIControlEventTouchUpInside];
//    infoBtn.titleLabel.font = viewFont3;
//    [baiView addSubview:infoBtn];

    
    UIButton *submitBtn = [[UIButton alloc] initWithFrame: CGRectMake(220*APP_DELEGATE().autoSizeScaleX, 0, 100*APP_DELEGATE().autoSizeScaleX, 45*APP_DELEGATE().autoSizeScaleY)];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [submitBtn setTitle:@"提交" forState:UIControlStateHighlighted];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [submitBtn setBackgroundImage:[UIImage imageWithColor:titleViewColor] forState:UIControlStateNormal];
    [submitBtn setBackgroundImage:[UIImage imageWithColor:titleViewColor] forState:UIControlStateHighlighted];
    [submitBtn addTarget:self
                  action:@selector(submitBtnClick:)
        forControlEvents:UIControlEventTouchUpInside];
    submitBtn.titleLabel.font = viewFont1;
    [baiView addSubview:submitBtn];

}

- (void)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 2;
    }
    else if (section == 2)
    {
        return 2;
    }
    else
    {
        return 3;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0||section==1)
     {
         return 10*APP_DELEGATE().autoSizeScaleY;
     }
    else
    {
        return 25*APP_DELEGATE().autoSizeScaleY;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0||section==1)
    {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320*APP_DELEGATE().autoSizeScaleX, 10*APP_DELEGATE().autoSizeScaleY)];
        headView.backgroundColor = fgx_13Color;
        return headView;

    }
    else if (section==2)
    {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320*APP_DELEGATE().autoSizeScaleX, 25*APP_DELEGATE().autoSizeScaleY)];
        headView.backgroundColor = fgx_13Color;
        
        
        UILabel *titleLable2 = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0, 290*APP_DELEGATE().autoSizeScaleX, 25*APP_DELEGATE().autoSizeScaleY)];
        titleLable2.numberOfLines = 0;
        titleLable2.textAlignment = NSTextAlignmentLeft;
        titleLable2.font = viewFont4;
        titleLable2.textColor = font1_13Color;
        titleLable2.text = @"货物信息";
        [headView addSubview:titleLable2];
        
        return headView;

    }
    else if (section==3)
    {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320*APP_DELEGATE().autoSizeScaleX, 25*APP_DELEGATE().autoSizeScaleY)];
        headView.backgroundColor = fgx_13Color;
        
        UILabel *titleLable2 = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0, 290*APP_DELEGATE().autoSizeScaleX, 25*APP_DELEGATE().autoSizeScaleY)];
        titleLable2.numberOfLines = 0;
        titleLable2.textAlignment = NSTextAlignmentLeft;
        titleLable2.font = viewFont4;
        titleLable2.textColor = font1_13Color;
        titleLable2.text = @"其他服务";
        [headView addSubview:titleLable2];

        
        return headView;

    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0)
    {
        return 60*APP_DELEGATE().autoSizeScaleY;
    }
    else if (indexPath.section==1&&indexPath.row==0)
    {
        return 30*APP_DELEGATE().autoSizeScaleY;
    }
    else if (indexPath.section==1&&indexPath.row==1)
    {
        return 180*APP_DELEGATE().autoSizeScaleY;
    }
    else if (indexPath.section==3&&indexPath.row==2)
    {
        return 80*APP_DELEGATE().autoSizeScaleY;
    }
    return 44*APP_DELEGATE().autoSizeScaleY;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier3 = @"CellIdentifier3";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier3];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
     cell.backgroundColor = [UIColor whiteColor];
    #pragma mark - 发货地点
    if(indexPath.section==0&&indexPath.row==0)
    {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 20*APP_DELEGATE().autoSizeScaleY, 16*APP_DELEGATE().autoSizeScaleY, 21*APP_DELEGATE().autoSizeScaleY)];
        icon.image = [UIImage imageWithName:@"fahuo_qidian"];
        [cell.contentView addSubview:icon];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //发货地址编号
        if ([[fahuodizhiDic objectForKey:@"ship_address_id"] length]==0)
        {
            if (!fahuoLabel)
            {
                fahuoLabel = [[UILabel alloc] initWithFrame:CGRectMake(40*APP_DELEGATE().autoSizeScaleX, 0, 70*APP_DELEGATE().autoSizeScaleX, 60*APP_DELEGATE().autoSizeScaleY)];
                fahuoLabel.backgroundColor = [UIColor clearColor];
                fahuoLabel.textColor = font2_13Color;
                fahuoLabel.textAlignment = NSTextAlignmentLeft;
                fahuoLabel.lineBreakMode = NSLineBreakByWordWrapping;
                fahuoLabel.numberOfLines = 0;
                fahuoLabel.font = viewFont1;
                fahuoLabel.text = @"发货地址";
            }
            [cell.contentView addSubview:fahuoLabel];
        }
        else
        {
            if (!fahuoText)
            {
                fahuoText = [[UILabel alloc] initWithFrame:CGRectMake(40*APP_DELEGATE().autoSizeScaleX, 0, 252*APP_DELEGATE().autoSizeScaleX, 40*APP_DELEGATE().autoSizeScaleY)];
                fahuoText.backgroundColor = [UIColor clearColor];
                fahuoText.textColor = font2_13Color;
                fahuoText.textAlignment = NSTextAlignmentLeft;
                fahuoText.lineBreakMode = NSLineBreakByTruncatingHead;
                fahuoText.numberOfLines = 0;
                fahuoText.font = viewFont2;
            }
//            fahuoText.text = [NSString stringWithFormat:@"%@%@",[fahuodizhiDic objectForKey:@"region_city"],[fahuodizhiDic objectForKey:@"address"]];
             fahuoText.text = [NSString stringWithFormat:@"%@",[fahuodizhiDic objectForKey:@"region_city"]];
            [cell.contentView addSubview:fahuoText];
            if (!fahuorenText)
            {
                fahuorenText = [[UILabel alloc] initWithFrame:CGRectMake(40*APP_DELEGATE().autoSizeScaleX, 35*APP_DELEGATE().autoSizeScaleY, 180*APP_DELEGATE().autoSizeScaleX, 22*APP_DELEGATE().autoSizeScaleY)];
                fahuorenText.backgroundColor = [UIColor clearColor];
                fahuorenText.textColor = fontInfo_13Color;
                fahuorenText.textAlignment = NSTextAlignmentLeft;
                fahuorenText.lineBreakMode = NSLineBreakByWordWrapping;
                fahuorenText.numberOfLines = 0;
                fahuorenText.font = viewFont2;
            }
            fahuorenText.text = [NSString stringWithFormat:@"%@",[fahuodizhiDic objectForKey:@"user_name"]];
            [cell.contentView addSubview:fahuorenText];
            CGSize size = [fahuorenText boundingRectWithSize:CGSizeMake(180*APP_DELEGATE().autoSizeScaleX, 22*APP_DELEGATE().autoSizeScaleY)];
            fahuorenText.frame = CGRectMake(40*APP_DELEGATE().autoSizeScaleX, 35*APP_DELEGATE().autoSizeScaleY, size.width,22*APP_DELEGATE().autoSizeScaleY);
            
            if (!fahuoPhoneText)
            {
                fahuoPhoneText = [[UILabel alloc] initWithFrame:CGRectMake((40+size.width+20)*APP_DELEGATE().autoSizeScaleX, 35*APP_DELEGATE().autoSizeScaleY, 100*APP_DELEGATE().autoSizeScaleX, 22*APP_DELEGATE().autoSizeScaleY)];
                fahuoPhoneText.backgroundColor = [UIColor clearColor];
                fahuoPhoneText.textColor = fontInfo_13Color;
                fahuoPhoneText.textAlignment = NSTextAlignmentLeft;
                fahuoPhoneText.lineBreakMode = NSLineBreakByWordWrapping;
                fahuoPhoneText.numberOfLines = 0;
                fahuoPhoneText.font = viewFont2;
            }
            fahuoPhoneText.frame = CGRectMake((40+size.width+20)*APP_DELEGATE().autoSizeScaleX, 35*APP_DELEGATE().autoSizeScaleY, 100*APP_DELEGATE().autoSizeScaleX, 22*APP_DELEGATE().autoSizeScaleY);
            fahuoPhoneText.text = [NSString stringWithFormat:@"%@",[fahuodizhiDic objectForKey:@"phone"]];
            [cell.contentView addSubview:fahuoPhoneText];
            
            UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fahuorenphoneTap:)];
            tapGr.cancelsTouchesInView = YES;
            [fahuoPhoneText addGestureRecognizer:tapGr];
            fahuoPhoneText.userInteractionEnabled = YES;
            
        }
        
        
        UILabel *fgx = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 59*APP_DELEGATE().autoSizeScaleY, 290*APP_DELEGATE().autoSizeScaleX, 1)];
        fgx.backgroundColor = fgx_13Color;
        [cell.contentView addSubview:fgx];
        
        
    }
       #pragma mark - 物流公司选择
    else if(indexPath.section==0&&indexPath.row==1)
    {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 14*APP_DELEGATE().autoSizeScaleY, 18*APP_DELEGATE().autoSizeScaleY, 16*APP_DELEGATE().autoSizeScaleY)];
        icon.image = [UIImage imageWithName:@"fh_wuliu"];
        [cell.contentView addSubview:icon];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (!wuliuText)
        {
            wuliuText = [[UILabel alloc] initWithFrame:CGRectMake(40*APP_DELEGATE().autoSizeScaleX, 0, 70*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY)];
            wuliuText.backgroundColor = [UIColor clearColor];
            wuliuText.textColor = font2_13Color;
            wuliuText.textAlignment = NSTextAlignmentLeft;
            wuliuText.lineBreakMode = NSLineBreakByWordWrapping;
            wuliuText.numberOfLines = 0;
            wuliuText.font = viewFont1;
            wuliuText.text = @"绍平物流";
        }
        [cell.contentView addSubview:wuliuText];
        
        UILabel *infoText = [[UILabel alloc] initWithFrame:CGRectMake(240*APP_DELEGATE().autoSizeScaleX, 0, 70*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY)];
        infoText.backgroundColor = [UIColor clearColor];
        infoText.textColor = fontInfo_13Color;
        infoText.textAlignment = NSTextAlignmentLeft;
        infoText.lineBreakMode = NSLineBreakByWordWrapping;
        infoText.numberOfLines = 0;
        infoText.font = viewFont2;
        infoText.text = @"物流可选";
        [cell.contentView addSubview:infoText];

        
    }
       #pragma mark - 提示和收费标准
    else if (indexPath.section==1&&indexPath.row==0)
    {
        UILabel *jieshaolabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0*APP_DELEGATE().autoSizeScaleY, 200*APP_DELEGATE().autoSizeScaleX, 30*APP_DELEGATE().autoSizeScaleY)];
        jieshaolabel1.backgroundColor = [UIColor clearColor];
        jieshaolabel1.textColor = font2_13Color;
        jieshaolabel1.textAlignment = NSTextAlignmentLeft;
        jieshaolabel1.lineBreakMode = NSLineBreakByWordWrapping;
        jieshaolabel1.numberOfLines = 0;
        jieshaolabel1.font = viewFont2;
        jieshaolabel1.text = @"选择接货车型";
        [cell.contentView addSubview:jieshaolabel1];
        
        UIImageView *arrowIMG = [[UIImageView alloc] initWithFrame:CGRectMake(245*APP_DELEGATE().autoSizeScaleX, 9*APP_DELEGATE().autoSizeScaleY, 12*APP_DELEGATE().autoSizeScaleX, 12*APP_DELEGATE().autoSizeScaleY)];
        arrowIMG.image = [UIImage imageNamed:@"YFQ-help"];
        [cell.contentView addSubview:arrowIMG];
        
        UILabel *jieshaolabel2 = [[UILabel alloc] initWithFrame:CGRectMake(230*APP_DELEGATE().autoSizeScaleX, 0*APP_DELEGATE().autoSizeScaleY, 80*APP_DELEGATE().autoSizeScaleX, 30*APP_DELEGATE().autoSizeScaleY)];
        jieshaolabel2.backgroundColor = [UIColor clearColor];
        jieshaolabel2.textColor = fontOrangeColor;
        jieshaolabel2.textAlignment = NSTextAlignmentRight;
        jieshaolabel2.lineBreakMode = NSLineBreakByWordWrapping;
        jieshaolabel2.numberOfLines = 0;
        jieshaolabel2.font = viewFont3;
        jieshaolabel2.text = @"收费标准";
        [cell.contentView addSubview:jieshaolabel2];
        
        
        
        UITapGestureRecognizer *tapGr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTap:)];
        tapGr2.cancelsTouchesInView = YES;
        [jieshaolabel2 addGestureRecognizer:tapGr2];
        jieshaolabel2.userInteractionEnabled = YES;
        
        UILabel *fgx = [[UILabel alloc] initWithFrame:CGRectMake(0, 29*APP_DELEGATE().autoSizeScaleY, 320*APP_DELEGATE().autoSizeScaleX, 1)];
        fgx.backgroundColor = fgx_13Color;
        [cell.contentView addSubview:fgx];

    }
       #pragma mark - 车型选择
    else if (indexPath.section==1&&indexPath.row==1)
    {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320*APP_DELEGATE().autoSizeScaleX,180*APP_DELEGATE().autoSizeScaleY)];
        scrollView.backgroundColor = bg_13Color;
        scrollView.contentSize = CGSizeMake(450*APP_DELEGATE().autoSizeScaleX, 180*APP_DELEGATE().autoSizeScaleY);
        [cell.contentView addSubview:scrollView];
        scrollView.userInteractionEnabled = YES;
        
        {
            if (!cheBtn1)
            {
                cheBtn1 = [[UIButton alloc] initWithFrame: CGRectMake(10*APP_DELEGATE().autoSizeScaleX,8*APP_DELEGATE().autoSizeScaleY,140*APP_DELEGATE().autoSizeScaleY,165*APP_DELEGATE().autoSizeScaleY)];
                [cheBtn1 setImage:[UIImage imageNamed:@"fh_sanlunche"] forState:UIControlStateNormal];
                [cheBtn1 setImage:[UIImage imageNamed:@"fh_sanlunche2"] forState:UIControlStateSelected];
                [cheBtn1 setBackgroundImage:[UIImage imageNamed:@"fh_wxcx"]  forState:UIControlStateNormal];
                [cheBtn1 setBackgroundImage:[UIImage imageNamed:@"fh_xzcx"]  forState:UIControlStateSelected];
                cheBtn1.selected = YES;
            }
           
            
            cheBtn1.imageEdgeInsets = UIEdgeInsetsMake(-50*APP_DELEGATE().autoSizeScaleY,0 ,0,0);
            
            UILabel *che1Label = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX, 75*APP_DELEGATE().autoSizeScaleY, 130*APP_DELEGATE().autoSizeScaleX, 20*APP_DELEGATE().autoSizeScaleY)];
            che1Label.backgroundColor = [UIColor clearColor];
            che1Label.textColor = font1_13Color;
            che1Label.textAlignment = NSTextAlignmentCenter;
            che1Label.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label.numberOfLines = 0;
            che1Label.font = viewFont2;
            che1Label.text = @"油三轮/电三轮";
            [cheBtn1 addSubview:che1Label];
            
            UILabel *che1Label1 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX, 100*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label1.backgroundColor = [UIColor clearColor];
            che1Label1.textColor = fontInfo_13Color;
            che1Label1.textAlignment = NSTextAlignmentLeft;
            che1Label1.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label1.numberOfLines = 0;
            che1Label1.font = viewFont2;
            che1Label1.text = @"起步价:50.0元(5公里)";
            [cheBtn1 addSubview:che1Label1];
            
            UILabel *che1Label2 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX, 115*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label2.backgroundColor = [UIColor clearColor];
            che1Label2.textColor = fontInfo_13Color;
            che1Label2.textAlignment = NSTextAlignmentLeft;
            che1Label2.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label2.numberOfLines = 0;
            che1Label2.font = viewFont2;
            che1Label2.text = @"超公里费:3元/公里";
            [cheBtn1 addSubview:che1Label2];
            
            UILabel *che1Label3 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX,130*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label3.backgroundColor = [UIColor clearColor];
            che1Label3.textColor = fontInfo_13Color;
            che1Label3.textAlignment = NSTextAlignmentLeft;
            che1Label3.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label3.numberOfLines = 0;
            che1Label3.font = viewFont2;
            che1Label3.text = @"长*宽*高:2*1.4*0.3米";
            [cheBtn1 addSubview:che1Label3];
            
            UILabel *che1Label4 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX,145*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label4.backgroundColor = [UIColor clearColor];
            che1Label4.textColor = fontInfo_13Color;
            che1Label4.textAlignment = NSTextAlignmentLeft;
            che1Label4.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label4.numberOfLines = 0;
            che1Label4.font = viewFont2;
            che1Label4.text = @"体积/载重:1.5/0.5吨";
            [cheBtn1 addSubview:che1Label4];
            [cheBtn1 addTarget:self
                        action:@selector(cheBtn1Click:)
              forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:cheBtn1];
        }
       
        {
            if (!cheBtn2)
            {
                 cheBtn2 = [[UIButton alloc] initWithFrame: CGRectMake(155*APP_DELEGATE().autoSizeScaleX,8*APP_DELEGATE().autoSizeScaleY,140*APP_DELEGATE().autoSizeScaleY,165*APP_DELEGATE().autoSizeScaleY)];
                [cheBtn2 setImage:[UIImage imageNamed:@"fh_pingbanche"] forState:UIControlStateNormal];
                [cheBtn2 setImage:[UIImage imageNamed:@"fh_pingbanche1"] forState:UIControlStateSelected];
                [cheBtn2 setBackgroundImage:[UIImage imageNamed:@"fh_wxcx"]  forState:UIControlStateNormal];
                [cheBtn2 setBackgroundImage:[UIImage imageNamed:@"fh_xzcx"]  forState:UIControlStateSelected];
            }
           
           
            
            cheBtn2.imageEdgeInsets = UIEdgeInsetsMake(-50*APP_DELEGATE().autoSizeScaleY,0 ,0,0);
            
            UILabel *che1Label = [[UILabel alloc] initWithFrame:CGRectMake(0*APP_DELEGATE().autoSizeScaleX, 75*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 20*APP_DELEGATE().autoSizeScaleY)];
            che1Label.backgroundColor = [UIColor clearColor];
            che1Label.textColor = font1_13Color;
            che1Label.textAlignment = NSTextAlignmentCenter;
            che1Label.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label.numberOfLines = 0;
            che1Label.font = viewFont2;
            che1Label.text = @"油三轮/电三轮";
            [cheBtn2 addSubview:che1Label];
            
            UILabel *che1Label1 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX, 100*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label1.backgroundColor = [UIColor clearColor];
            che1Label1.textColor = fontInfo_13Color;
            che1Label1.textAlignment = NSTextAlignmentLeft;
            che1Label1.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label1.numberOfLines = 0;
            che1Label1.font = viewFont2;
            che1Label1.text = @"起步价:50.0元(5公里)";
            [cheBtn2 addSubview:che1Label1];
            
            UILabel *che1Label2 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX, 115*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label2.backgroundColor = [UIColor clearColor];
            che1Label2.textColor = fontInfo_13Color;
            che1Label2.textAlignment = NSTextAlignmentLeft;
            che1Label2.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label2.numberOfLines = 0;
            che1Label2.font = viewFont2;
            che1Label2.text = @"超公里费:3元/公里";
            [cheBtn2 addSubview:che1Label2];
            
            UILabel *che1Label3 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX,130*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label3.backgroundColor = [UIColor clearColor];
            che1Label3.textColor = fontInfo_13Color;
            che1Label3.textAlignment = NSTextAlignmentLeft;
            che1Label3.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label3.numberOfLines = 0;
            che1Label3.font = viewFont2;
            che1Label3.text = @"长*宽*高:2*1.4*0.3米";
            [cheBtn2 addSubview:che1Label3];
            
            UILabel *che1Label4 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX,145*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label4.backgroundColor = [UIColor clearColor];
            che1Label4.textColor = fontInfo_13Color;
            che1Label4.textAlignment = NSTextAlignmentLeft;
            che1Label4.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label4.numberOfLines = 0;
            che1Label4.font = viewFont2;
            che1Label4.text = @"体积/载重:1.5/0.5吨";
            [cheBtn2 addSubview:che1Label4];
            [cheBtn2 addTarget:self
                        action:@selector(cheBtn2Click:)
              forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:cheBtn2];
        }

        
        {
            if (!cheBtn3)
            {
                cheBtn3 = [[UIButton alloc] initWithFrame: CGRectMake(300*APP_DELEGATE().autoSizeScaleX,8*APP_DELEGATE().autoSizeScaleY,140*APP_DELEGATE().autoSizeScaleY,165*APP_DELEGATE().autoSizeScaleY)];
                [cheBtn3 setImage:[UIImage imageNamed:@"fh_xiaohuoche1"] forState:UIControlStateNormal];
                [cheBtn3 setImage:[UIImage imageNamed:@"fh_xiaohuoche"] forState:UIControlStateSelected];
                [cheBtn3 setBackgroundImage:[UIImage imageNamed:@"fh_wxcx"]  forState:UIControlStateNormal];
                [cheBtn3 setBackgroundImage:[UIImage imageNamed:@"fh_xzcx"]  forState:UIControlStateSelected];
            }
           
            
            cheBtn3.imageEdgeInsets = UIEdgeInsetsMake(-50*APP_DELEGATE().autoSizeScaleY,0 ,0,0);
            
            UILabel *che1Label = [[UILabel alloc] initWithFrame:CGRectMake(0*APP_DELEGATE().autoSizeScaleX, 75*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 20*APP_DELEGATE().autoSizeScaleY)];
            che1Label.backgroundColor = [UIColor clearColor];
            che1Label.textColor = font1_13Color;
            che1Label.textAlignment = NSTextAlignmentCenter;
            che1Label.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label.numberOfLines = 0;
            che1Label.font = viewFont2;
            che1Label.text = @"油三轮/电三轮";
            [cheBtn3 addSubview:che1Label];
            
            UILabel *che1Label1 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX, 100*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label1.backgroundColor = [UIColor clearColor];
            che1Label1.textColor = fontInfo_13Color;
            che1Label1.textAlignment = NSTextAlignmentLeft;
            che1Label1.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label1.numberOfLines = 0;
            che1Label1.font = viewFont2;
            che1Label1.text = @"起步价:50.0元(5公里)";
            [cheBtn3 addSubview:che1Label1];
            
            UILabel *che1Label2 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX, 115*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label2.backgroundColor = [UIColor clearColor];
            che1Label2.textColor = fontInfo_13Color;
            che1Label2.textAlignment = NSTextAlignmentLeft;
            che1Label2.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label2.numberOfLines = 0;
            che1Label2.font = viewFont2;
            che1Label2.text = @"超公里费:3元/公里";
            [cheBtn3 addSubview:che1Label2];
            
            UILabel *che1Label3 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX,130*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label3.backgroundColor = [UIColor clearColor];
            che1Label3.textColor = fontInfo_13Color;
            che1Label3.textAlignment = NSTextAlignmentLeft;
            che1Label3.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label3.numberOfLines = 0;
            che1Label3.font = viewFont2;
            che1Label3.text = @"长*宽*高:2*1.4*0.3米";
            [cheBtn3 addSubview:che1Label3];
            
            UILabel *che1Label4 = [[UILabel alloc] initWithFrame:CGRectMake(10*APP_DELEGATE().autoSizeScaleX,145*APP_DELEGATE().autoSizeScaleY, 140*APP_DELEGATE().autoSizeScaleX, 15*APP_DELEGATE().autoSizeScaleY)];
            che1Label4.backgroundColor = [UIColor clearColor];
            che1Label4.textColor = fontInfo_13Color;
            che1Label4.textAlignment = NSTextAlignmentLeft;
            che1Label4.lineBreakMode = NSLineBreakByWordWrapping;
            che1Label4.numberOfLines = 0;
            che1Label4.font = viewFont2;
            che1Label4.text = @"体积/载重:1.5/0.5吨";
            [cheBtn3 addSubview:che1Label4];
            [cheBtn3 addTarget:self
                        action:@selector(cheBtn3Click:)
              forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:cheBtn3];
        }
    }
#pragma mark - 货物名称
    else if (indexPath.section==2&&indexPath.row==0)
    {
        UILabel *titleLable1 = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0, 70*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY)];
        titleLable1.numberOfLines = 0;
        titleLable1.textAlignment = NSTextAlignmentLeft;
        titleLable1.font = viewFont1;
        titleLable1.textColor = font1_13Color;
         titleLable1.text = @"货物名称";
        [cell.contentView addSubview:titleLable1];

        UILabel *fgx = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 43*APP_DELEGATE().autoSizeScaleY, 290*APP_DELEGATE().autoSizeScaleX, 1)];
        fgx.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
        [cell.contentView addSubview:fgx];
      
        if (!huoNameText)
        {
            huoNameText = [[UITextField alloc] init];
            huoNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
            huoNameText.borderStyle = UITextBorderStyleNone;
            huoNameText.frame = CGRectMake(90*APP_DELEGATE().autoSizeScaleX, 0, 200*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY);
            huoNameText.delegate = self;
            huoNameText.placeholder = @"请输入货物名称";
            huoNameText.returnKeyType = UIReturnKeyDone;
            huoNameText.keyboardType = UIKeyboardTypeDefault;
            huoNameText.font = viewFont1;
            huoNameText.textColor = fontColor;
            huoNameText.text = @"";
            
        }
        [cell.contentView addSubview:huoNameText];

    }
    
    
#pragma mark - 货物件数
    else if (indexPath.section==2&&indexPath.row==1)
    {
        UILabel *titleLable1 = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0, 70*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY)];
        titleLable1.numberOfLines = 0;
        titleLable1.textAlignment = NSTextAlignmentLeft;
        titleLable1.font = viewFont1;
        titleLable1.textColor = font1_13Color;
        titleLable1.text = @"货物件数";
        [cell.contentView addSubview:titleLable1];
        
        if (!huoNumText)
        {
            huoNumText = [[UITextField alloc] init];
            huoNumText.clearButtonMode = UITextFieldViewModeWhileEditing;
            huoNumText.borderStyle = UITextBorderStyleNone;
            huoNumText.textColor = fontColor;
            huoNumText.frame = CGRectMake(90*APP_DELEGATE().autoSizeScaleX, 0, 200*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY);
            huoNumText.delegate = self;
            huoNumText.placeholder = @"请输入货物件数";
            huoNumText.returnKeyType = UIReturnKeyDone;
            huoNumText.keyboardType = UIKeyboardTypeNumberPad;
            huoNumText.font = viewFont1;
            huoNumText.text = @"";
            
        }
        [cell.contentView addSubview:huoNumText];
    }

#pragma mark - 请选择您想要优先派车的司机
    else if (indexPath.section==3&&indexPath.row==0)
    {
        UILabel *titleLable1 = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0, 210*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY)];
        titleLable1.numberOfLines = 0;
        titleLable1.textAlignment = NSTextAlignmentLeft;
        titleLable1.font = viewFont1;
        titleLable1.textColor = font1_13Color;
        titleLable1.text = @"请选择您想要优先派车的司机";
        [cell.contentView addSubview:titleLable1];
        
        UILabel *fgx = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 43*APP_DELEGATE().autoSizeScaleY, 290*APP_DELEGATE().autoSizeScaleX, 1)];
        fgx.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
        [cell.contentView addSubview:fgx];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

#pragma mark - 需要返票
    else if (indexPath.section==3&&indexPath.row==1)
    {
        UILabel *titleLable1 = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 0, 180*APP_DELEGATE().autoSizeScaleX, 44*APP_DELEGATE().autoSizeScaleY)];
        titleLable1.numberOfLines = 0;
        titleLable1.textAlignment = NSTextAlignmentLeft;
        titleLable1.font = viewFont1;
        titleLable1.textColor = font1_13Color;
        titleLable1.text = @"需要返票";
        [cell.contentView addSubview:titleLable1];
        
        if (!switchFanPiao)
        {
            switchFanPiao = [[SevenSwitch alloc] initWithFrame:CGRectMake(260*APP_DELEGATE().autoSizeScaleX, 12*APP_DELEGATE().autoSizeScaleY, 40*APP_DELEGATE().autoSizeScaleX, 20*APP_DELEGATE().autoSizeScaleY)];
            switchFanPiao.on = NO;
            [switchFanPiao addTarget:self action:@selector(switchChanged2:) forControlEvents:UIControlEventValueChanged];
            switchFanPiao.onTintColor = titleViewColor;
            
        }
        
        
        [cell.contentView addSubview:switchFanPiao];

    }
#pragma mark - 同意
    else if (indexPath.section==3&&indexPath.row==2)
    {
        cell.backgroundColor = fgx_13Color;
        
        gouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        gouBtn.frame = CGRectMake(0, 0,40*APP_DELEGATE().autoSizeScaleY, 40*APP_DELEGATE().autoSizeScaleY);
        [gouBtn setImage:[[UIImage imageNamed:@"fh_butongyi"] imageByScalingToSize:CGSizeMake(14*APP_DELEGATE().autoSizeScaleY, 14*APP_DELEGATE().autoSizeScaleY)] forState:UIControlStateNormal];
        [gouBtn setImage:[[UIImage imageNamed:@"fh_tongyi"] imageByScalingToSize:CGSizeMake(14*APP_DELEGATE().autoSizeScaleY, 14*APP_DELEGATE().autoSizeScaleY)] forState:UIControlStateSelected];
        [gouBtn addTarget:self
                   action:@selector(guoBtnClick:)
         forControlEvents:UIControlEventTouchUpInside];
        gouBtn.selected = YES;
        [cell.contentView addSubview:gouBtn];
        
        
        UILabel *agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30*APP_DELEGATE().autoSizeScaleX, 5*APP_DELEGATE().autoSizeScaleY, 100*APP_DELEGATE().autoSizeScaleX, 30*APP_DELEGATE().autoSizeScaleY)];
        agreeLabel.numberOfLines = 0;
        agreeLabel.textAlignment = NSTextAlignmentLeft;
        agreeLabel.font = viewFont3;
        agreeLabel.textColor = fontColor;
        agreeLabel.text = @"我同意";
        [cell.contentView addSubview:agreeLabel];
        
        UILabel *clauseLabel = [[UILabel alloc] initWithFrame:CGRectMake(70*APP_DELEGATE().autoSizeScaleX, 5*APP_DELEGATE().autoSizeScaleY, 200*APP_DELEGATE().autoSizeScaleX, 30*APP_DELEGATE().autoSizeScaleY)];
        clauseLabel.numberOfLines = 0;
        clauseLabel.textAlignment = NSTextAlignmentLeft;
        clauseLabel.font = viewFont3;
        clauseLabel.textColor = titleViewColor;
        clauseLabel.text = @"《托运邦运单契约条款》";
        [cell.contentView addSubview:clauseLabel];
        
        clauseLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clauseLabelTap:)];
        tapGr.cancelsTouchesInView = YES;
        [clauseLabel addGestureRecognizer:tapGr];
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 35*APP_DELEGATE().autoSizeScaleY, 290*APP_DELEGATE().autoSizeScaleX, 30*APP_DELEGATE().autoSizeScaleY)];
        descLabel.numberOfLines = 0;
        descLabel.textAlignment = NSTextAlignmentLeft;
        descLabel.font = viewFont3;
        [cell.contentView addSubview:descLabel];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"注意:显示支付价格为预计价格，等待司机接单联系后根据具体需要的其他服务进行改价"];
         [str addAttribute:NSForegroundColorAttributeName value:fontInfo_13Color range:NSMakeRange(0,str.length)];
//        [str addAttribute:NSForegroundColorAttributeName value:titleViewColor range:NSMakeRange(0,5)];
//        [str addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(5,str.length-5)];
        descLabel.attributedText = str;
        
    }
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0&&indexPath.row==0)
    {
        NSLog(@"发货地址");
        XuanFaHuoDiZhiViewController *vc = [[XuanFaHuoDiZhiViewController alloc] init];
        vc.mydelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }
    
}

- (void)sendformattedAddress:(NSString *)formattedAddress AndCoordinate:(CLLocationCoordinate2D)coordinate
{

    [fahuodizhiDic removeAllObjects];
     NSDictionary *loginUser = [[NSUserDefaults standardUserDefaults] objectForKey:kUserInfo];
    
    NSDictionary *dict = @{
                                 @"region_city" :formattedAddress,
                                 @"user_name" : [loginUser objectForKey:@"real_name"],
                                  @"phone" : [loginUser objectForKey:@"account_id"],
                                 @"ship_address_id":@"111",
                                 };
 [fahuodizhiDic setDictionary: dict];
    
//    region_city
    [_tableView reloadData];
}

- (void)infoBtnClick:(id)sender
{
    NSLog(@"明细");
}
- (void)submitBtnClick:(id)sender
{
    NSLog(@"提交了");
}
- (void)guoBtnClick:(id)sender
{
    gouBtn.selected = !gouBtn.selected;
}

- (void)clauseLabelTap:(UITapGestureRecognizer*)tapGr
{
    NSLog(@"条款");
    YLLWebViewController *vc = [[YLLWebViewController alloc] init];
    vc.webTitle = @"托运邦运单契约条款";
    vc.webURL = [NSString stringWithFormat:@"%@",contractClauseURL];
    YLLNavigationController *nav = [[YLLNavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
}

//- (void)switchChanged1:(SevenSwitch *)sender
//{
//    isYouXian = sender.on;
//    //延时执行
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
//        [_tableView reloadData];
//    });
//
//    
//   
////    NSLog(@"Changed value to: %@", sender.on ? @"ON" : @"OFF");
//}

- (void)switchChanged2:(SevenSwitch *)sender
{
    NSLog(@"Changed value to: %@", sender.on ? @"ON" : @"OFF");
}

- (void)cheBtn1Click:(UIButton *)sender
{
    if (cheBtn1.selected==YES)
        return;
    cheBtn1.selected = !cheBtn1.selected;
    cheBtn2.selected = !cheBtn1.selected;
    cheBtn3.selected = !cheBtn1.selected;
}

- (void)cheBtn2Click:(UIButton *)sender
{
    if (cheBtn2.selected==YES)
        return;
    cheBtn2.selected = !cheBtn2.selected;
    cheBtn1.selected = !cheBtn2.selected;
    cheBtn3.selected = !cheBtn2.selected;
}

- (void)cheBtn3Click:(UIButton *)sender
{
    if (cheBtn3.selected==YES)
        return;
    cheBtn3.selected = !cheBtn3.selected;
    cheBtn1.selected = !cheBtn3.selected;
    cheBtn2.selected = !cheBtn3.selected;
}

- (void)fahuorenphoneTap:(UITapGestureRecognizer*)tapGr
{
    NSLog(@"拨打电话");
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[@"telprompt://" stringByAppendingString:[fahuodizhiDic objectForKey:@"phone"]]]];
}

- (void)openTap:(UITapGestureRecognizer*)tapGr
{
    NSLog(@"收费标准");
    YLLWebViewController *vc = [[YLLWebViewController alloc] init];
    vc.webTitle = @"收费标准";
    vc.webURL = [NSString stringWithFormat:@"%@",CouponIntroductionURL];
    YLLNavigationController *nav = [[YLLNavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
