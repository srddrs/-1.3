//
//  HomePage13ViewController.m
//  yunlailaC
//
//  Created by admin on 16/12/26.
//  Copyright © 2016年 com.yunlaila. All rights reserved.
//

#import "HomePage13ViewController.h"
#import "UpdatePassWordViewController.h"
#import "OrdersViewController.h"
#import "SaoMaViewController.h"

#import <PgySDK/PgyManager.h>
#import <PgyUpdate/PgyUpdateManager.h>


#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

#import "FaHuoLingDanViewController.h"
#import "FaHuoZhengCheViewController.h"
@interface HomePage13ViewController ()<WJSegmentMenuDelegate,UITextFieldDelegate,SaoMaViewControllerDelegate,MAMapViewDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITextField *searchText;  //搜索栏
    
    MAMapView *_mapView;
    
    AMapSearchAPI *_search;
    
    AMapReGeocode *reGeocode;
    
    CLLocationCoordinate2D currentCoordinate;
    NSString *currentformattedAddress;
    
    UILabel *label;

    
    UIView *ModeView;
    UITableView *_tableView;
    NSMutableArray *addressArray;
    
    int  type;
}
@end

@implementation HomePage13ViewController
- (void)sendCode:(NSString *)code
{
    YLLWebViewController *vc = [[YLLWebViewController alloc] init];
    vc.webTitle = @"运单跟踪";
    vc.webURL = [NSString stringWithFormat:@"%@?waybillNum=%@&type=1",waybillDetailsURL,code];
    YLLNavigationController *nav = [[YLLNavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)noPassWordTip:(NSNotification *)notification
{
    [UIAlertView showAlert:@"您还没有设置登录密码，现在设置吗?" delegate:self cancelButton:@"取消" otherButton:@"设置" tag:1];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        NSLog(@"设置密码");
        UpdatePassWordViewController *vc = [[UpdatePassWordViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        NSLog(@"不设置");
    }
}

-(void)goSendList:(NSNotification *)notification
{
    OrdersViewController *vc = [[OrdersViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)checkMapView
{
    [self clearMapView];
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))
    {
        //定位功能可用，开始定位
        [_mapView setHidden:NO];
        _mapView.delegate = self;
        _mapView.zoomLevel = 15;
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode  = MAUserTrackingModeFollow;
        
        _search.delegate = self;
        
        _mapView.pausesLocationUpdatesAutomatically = NO;
        
        //        _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
        
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        NSLog(@"定位功能不可用，提示用户或忽略");
        [UIAlertView showAlert:@"请设置允许托运邦货主使用定位服务的权限" delegate:self cancelButton:@"取消" otherButton:@"去设置" tag:1];
        
    }
    
}

- (void)clearMapView
{
    [_mapView setHidden:YES];
    _mapView.delegate = nil;
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode  = MAUserTrackingModeNone;
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
    
    _search.delegate = nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(goSendList:)
                                                     name:KNOTIFICATION_fahuolist
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noPassWordTip:)
                                                     name:KNOTIFICATION_noPassWord
                                                   object:nil];
        
        
        addressArray = [[NSMutableArray alloc] init];
        NSDictionary *threedict1 = @{
                                     @"id" :[NSString stringWithFormat:@"%d",1] ,
                                     @"name" : @"华联",
                                     @"info" : @"成都市盐市口",
                                     };
        NSDictionary *threedict2 = @{
                                     @"id" :[NSString stringWithFormat:@"%d",2] ,
                                     @"name" : @"北城天街",
                                     @"info" : @"成都市金牛区",
                                     };

        NSDictionary *threedict3 = @{
                                     @"id" :[NSString stringWithFormat:@"%d",3] ,
                                     @"name" : @"火车北站",
                                     @"info" : @"成都市金牛区人民北路",
                                     };

        
        [addressArray addObject:threedict1];
        [addressArray addObject:threedict2];
        [addressArray addObject:threedict3];
        
        type = 0;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"首页"];
     [self clearMapView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"首页"];
     [self checkMapView];
    
    //如果没有用户资料 前往登录  否则检查更新
    NSDictionary *user =  [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUser];
    if (user==nil)
    {
        [AppTool presentDengLu:self];
    }
    else
    {
        if (ISAPPSTORE==0)
        {
            [[PgyUpdateManager sharedPgyManager] checkUpdate];
        }
        else
        {
            [self checkUpdateWithAppID:@"1142144828" success:^(NSDictionary *resultDic, BOOL isNewVersion, NSString *newVersion) {
                
                if (isNewVersion)
                {
                    if (resultDic!=nil)
                    {
                        [self showUpdateView:resultDic];
                    }
                    
                }
                else
                {
                    
                }
                
            } failure:^(NSError *error)
             {
                 
             }];
            
        }
        
        
        //        968615456  测试
        //        1142144828  微门店
        
    }
}


- (void)checkUpdateWithAppID:(NSString *)appID success:(void (^)(NSDictionary *resultDic , BOOL isNewVersion , NSString * newVersion))success failure:(void (^)(NSError *error))failure
{
    NHNetworkHelper *helper = [NHNetworkHelper shareInstance];
    NSString *encodingUrl=[[@"http://itunes.apple.com/lookup?id=" stringByAppendingString:appID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //    NSString *OLDVERSION =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //     NSString *encodingUrl=[NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@",OLDVERSION];
    
    
    
    
    
    
    [helper GET:encodingUrl Parameters:nil Success:^(id responseObject)
     {
         
         NSLog(@"responseObject:%@",responseObject);
         NSArray *results = [responseObject objectForKey:@"results"];
         if (results.count>0)
         {
             NSDictionary *versionInfo = [results objectAtIndex:0];
             NSString * versionStr = [versionInfo valueForKey:@"version"];
             float version =[versionStr floatValue];
             //self.iTunesLink=[[[resultDic objectForKey:@"results"] objectAtIndex:0] valueForKey:@"trackViewUrl"];
             NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
             float currentVersion = [[infoDic valueForKey:@"CFBundleShortVersionString"] floatValue];
             
             if(version>currentVersion)
             {
                 success(responseObject, YES, versionStr);
                 NSLog(@"要升级");
                 
             }else{
                 //                  success(responseObject, YES, versionStr);
                 success(responseObject, NO, versionStr);
                 NSLog(@"不要升级");
                 
             }
             
         }
         else
         {
             success(responseObject, NO, nil);
             NSLog(@"不要升级");
         }
         
         
         
     } Failure:^(NSError *error)
     {
         failure(nil);
         NSLog(@"%@",error);
     }];
    
    
}

- (void)showUpdateView:(NSDictionary *)resultDic
{
    NSArray *results = [resultDic objectForKey:@"results"];
    NSDictionary *result = [results objectAtIndex:0];
    NSString *alertMsg=
    [[[@"托运邦货主" stringByAppendingString:[NSString stringWithFormat:@"%0.1f",[[result objectForKey:@"version"] floatValue]]]
      stringByAppendingString:@"，赶快体验最新版本吧！"]
     stringByAppendingString:[NSString stringWithFormat:@"\n\n%@",[result objectForKey:@"releaseNotes"] ]];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加按钮
    //    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    //
    //    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        UIWindow *window = app.window;
        
        [UIView animateWithDuration:1.0f animations:^{
            window.alpha = 0;
            window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
        } completion:^(BOOL finished) {
            NSString *str = @"https://itunes.apple.com/app/id1142144828";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
            exit(0);
        }];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initTitle];
    [self initView];
    [self initModeView];
    [APP_DELEGATE() storyBoradAutoLay:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTitle
{
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"sy_kefu" highIcon:@"sy_kefu" target:self action:@selector(phoneBtnClick:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"sy_erweima" highIcon:@"sy_erweima" target:self action:@selector(scanBtnClick:)];
    
    UIImageView *searchBg = [[UIImageView alloc] initWithFrame:CGRectMake(45*APP_DELEGATE().autoSizeScaleX, 7, 230*APP_DELEGATE().autoSizeScaleX, 30)];
    searchBg.image = [UIImage imageNamed:@"sy_shuru"];
    searchBg.userInteractionEnabled = YES;
    
    UIImageView *iconView1 = [[UIImageView alloc]initWithImage:[UIImage imageWithName:@"sy_sousuo"]];
    iconView1.contentMode = UIViewContentModeCenter;
    
    searchText = [[UITextField alloc] init];
    searchText.leftView = iconView1;
    searchText.leftViewMode = UITextFieldViewModeAlways;
    searchText.leftView.frame = CGRectMake(0, 0, 30, 30);
    searchText.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchText.borderStyle = UITextBorderStyleNone;
    searchText.frame = CGRectMake(0, 0, 215*APP_DELEGATE().autoSizeScaleX, 30);
    searchText.delegate = self;
    searchText.placeholder = @"请输入您的运单号";
    searchText.returnKeyType = UIReturnKeySearch;
    searchText.keyboardType = UIKeyboardTypeDefault;
    searchText.font = viewFont2;
    searchText.textColor = font1_13Color;
    [searchText setValue:[UIColor colorWithRed:167/255.0 green:167/255.0 blue:167/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    [searchText setValue:viewFont2 forKeyPath:@"_placeholderLabel.font"];
    [searchBg addSubview:searchText];
    self.navigationItem.titleView = searchBg;
}

- (void)initView
{
    WJSegmentMenu *segmentMenu = [[WJSegmentMenu alloc]initWithFrame:CGRectMake(0, 1, 320, 30)];
    segmentMenu.delegate = self;
    [segmentMenu segmentWithTitles:@[@"零担",@"整车"]];
     [self.view addSubview:segmentMenu];
    
    
    UILabel *fgx = [[UILabel alloc] initWithFrame:CGRectMake(0, 31, 320, 2)];
    fgx.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
    [self.view addSubview:fgx];
    
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 33, 320,  568-33  )];
    [self.view addSubview:_mapView];
    
    _mapView.showsCompass = YES;
    _mapView.showsScale = YES;
    _mapView.zoomLevel = 15;
    
    _search = [[AMapSearchAPI alloc] init];
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 56)];
    bg.backgroundColor = [UIColor whiteColor];
    [_mapView addSubview:bg];
    
    bg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)];
    tapGr.cancelsTouchesInView = YES;
    [bg addGestureRecognizer:tapGr];
    
    
    UIImageView *img1 = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 16, 21)];
    img1.image = [UIImage imageWithName:@"fahuo_qidian"];
    [bg addSubview:img1];

    
    label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 240, 36)];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = font1_13Color;
    label.textAlignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.font = viewFont1;
    label.text = @"单击地图选择发货地点";
    [bg addSubview:label];
    
    
    UIButton *submitBtn = [[UIButton alloc] initWithFrame: CGRectMake(101, _mapView.frame.size.height/2-10-44-38, 115, 40)];
    [submitBtn setBackgroundImage:[UIImage imageNamed:@"sy_fahuo"] forState:UIControlStateNormal];
    [submitBtn setBackgroundImage:[UIImage imageNamed:@"sy_fahuo"] forState:UIControlStateHighlighted];
    [submitBtn addTarget:self
                  action:@selector(submitBtnClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:submitBtn];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(160-6, _mapView.frame.size.height/2-10-44, 13, 30) ];
    icon.image = [UIImage imageNamed:@"sy_dingwei"];
    [_mapView addSubview:icon];

    
    UIButton *dingweiBtn = [[UIButton alloc] initWithFrame: CGRectMake(30, CGRectGetHeight(_mapView.bounds)-160, 18, 20)];
    [dingweiBtn setBackgroundImage:[UIImage imageNamed:@"sy_wdzb"] forState:UIControlStateNormal];
    [dingweiBtn setBackgroundImage:[UIImage imageNamed:@"sy_wdzb"] forState:UIControlStateHighlighted];
    [dingweiBtn addTarget:self
                action:@selector(dingweiBtnClick:)
      forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:dingweiBtn];
    
    UIButton *liwuBtn = [[UIButton alloc] initWithFrame: CGRectMake(290, CGRectGetHeight(_mapView.bounds)-160, 18, 20)];
    [liwuBtn setBackgroundImage:[UIImage imageNamed:@"sy_huodong"] forState:UIControlStateNormal];
    [liwuBtn setBackgroundImage:[UIImage imageNamed:@"sy_huodong"] forState:UIControlStateHighlighted];
    [liwuBtn addTarget:self
                  action:@selector(liwuBtnClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:liwuBtn];
    
    
}

- (void)initModeView
{
    ModeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    ModeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    ModeView.userInteractionEnabled = YES;
    [self.view addSubview:ModeView];
    
 
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(20,600, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height - TabbarHeight -71-20)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = bg_13Color;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [ModeView addSubview:_tableView];
    if (IsIOS7)
        _tableView.separatorInset = UIEdgeInsetsZero;
    
//    UITapGestureRecognizer *tapGr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap:)];
//    tapGr1.cancelsTouchesInView = YES;
//    [_tableView addGestureRecognizer:tapGr1];
}

- (void)segmentWithIndex:(NSInteger)index title:(NSString *)title
{
    if (index==0)
    {
        NSLog(@"零担");
        type = 0;
    }
    else
    {
        
        NSLog(@"整车");
        type = 1;
    }
}

- (void)phoneBtnClick:(id)sender
{
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[@"telprompt://" stringByAppendingString:@"02866000100"]]];
}

- (void)scanBtnClick:(id)sender
{
    NSLog(@"扫码");
    //     [[BeforeScanSingleton shareScan] ShowSelectedType:QQStyle WithViewController:self];
    SaoMaViewController *vc = [[SaoMaViewController alloc] init];
    vc.mydelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)submitBtnClick:(id)sender
{
    
    if (type==0)
    {
        FaHuoLingDanViewController *vc = [[FaHuoLingDanViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        NSLog(@"零担");
    }
    else
    {
        NSLog(@"整车");
        FaHuoZhengCheViewController *vc = [[FaHuoZhengCheViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
  
}

- (void)dingweiBtnClick:(id)sender
{
    NSLog(@"定位");
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
}

- (void)liwuBtnClick:(id)sender
{
    NSLog(@"新闻或者礼物");
}

- (void)bgTap:(UITapGestureRecognizer*)tapGr
{
    NSLog(@"去发货地址列表");
    ModeView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView animateWithDuration:0.5
                     animations:^{
                         _tableView.frame = CGRectMake(20, 10, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height - TabbarHeight -71-20);
                         
                     }
                     completion:^(BOOL finished) {
                        
    
                     }];

}

- (void)closeTap:(UITapGestureRecognizer*)tapGr
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         _tableView.frame = CGRectMake(20,600, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height - TabbarHeight -71-20);
                     }
                     completion:^(BOOL finished) {
                         ModeView.frame = CGRECT_NO_NAV(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }];
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        //        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
        //        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
        //        pre.image = [UIImage imageNamed:@"location.png"];
        //        pre.lineWidth = 3;
        //        pre.lineDashPattern = @[@6, @3];
        pre.showsAccuracyRing = NO;
        [_mapView updateUserLocationRepresentation:pre];
        
        view.calloutOffset = CGPointMake(0, 0);
    }
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction
{
    label.text = @"移动图钉";
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    NSLog(@"拖动结束");
    [_mapView removeAnnotations:_mapView.annotations];
    [self searchReGeocodeWithCoordinate:mapView.centerCoordinate];
    
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        //        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
//    [_mapView removeAnnotations:_mapView.annotations];
//    [self searchReGeocodeWithCoordinate:coordinate];
}
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension            = YES;
    
    [_search AMapReGoecodeSearch:regeo];
}

#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        
        //        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        //        pointAnnotation.coordinate = coordinate;
        //        [_mapView addAnnotation:pointAnnotation];
        
        label.text = response.regeocode.formattedAddress;
         label.textAlignment = NSTextAlignmentLeft;
        currentCoordinate = coordinate;
        currentformattedAddress = response.regeocode.formattedAddress;
    }
}

#pragma mark - tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return addressArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*APP_DELEGATE().autoSizeScaleY;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
 
    cell.contentView.backgroundColor = [UIColor whiteColor];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *info = [addressArray objectAtIndex:indexPath.section];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 19*APP_DELEGATE().autoSizeScaleY, 12*APP_DELEGATE().autoSizeScaleY, 12*APP_DELEGATE().autoSizeScaleY)];
    icon.image = [UIImage imageNamed:@"mdd_shijian"];
    [cell.contentView addSubview:icon];
    
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(40*APP_DELEGATE().autoSizeScaleX, 0, 225*APP_DELEGATE().autoSizeScaleX, 25*APP_DELEGATE().autoSizeScaleY)];
    nameLable.numberOfLines = 0;
    nameLable.textAlignment = NSTextAlignmentLeft;
    nameLable.font = viewFont3;
    nameLable.textColor = font1_13Color;
    nameLable.text = [NSString stringWithFormat:@"%@",[info objectForKey:@"name"]];
    [cell.contentView addSubview:nameLable];
    
    
    UILabel *infoLable = [[UILabel alloc] initWithFrame:CGRectMake(40*APP_DELEGATE().autoSizeScaleX, 25*APP_DELEGATE().autoSizeScaleY, 225*APP_DELEGATE().autoSizeScaleX, 25*APP_DELEGATE().autoSizeScaleY)];
    infoLable.numberOfLines = 0;
    infoLable.textAlignment = NSTextAlignmentLeft;
    infoLable.font = viewFont3;
    infoLable.textColor = fontInfo_13Color;
    infoLable.text = [NSString stringWithFormat:@"%@",[info objectForKey:@"info"]];
    [cell.contentView addSubview:infoLable];

    
    
    UILabel *fgx = [[UILabel alloc] initWithFrame:CGRectMake(15*APP_DELEGATE().autoSizeScaleX, 49, 290*APP_DELEGATE().autoSizeScaleX, 1)];
    fgx.backgroundColor = fgx_13Color;
    [cell.contentView addSubview:fgx];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [addressArray objectAtIndex:indexPath.section];
    label.text = [info objectForKey:@"info"];
    
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _tableView.frame = CGRectMake(20,600, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height - TabbarHeight -71-20);
                     }
                     completion:^(BOOL finished) {
                         ModeView.frame = CGRECT_NO_NAV(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
