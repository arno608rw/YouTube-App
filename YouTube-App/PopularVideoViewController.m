//
//  PopularVideoViewController.m
//  YouTube-App
//
//  Created by Admin on 18.05.15.
//  Copyright (c) 2015 AShi. All rights reserved.
//

#import "PopularVideoViewController.h"
#import "CustomVideoCell.h"
// #import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "YouTubeVideo.h"
#import "YouTubeTools.h"

#import "YTPlayerView.h"

#import "AFNetworking.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PopularVideoViewController ()<UITableViewDelegate,
                                        UITableViewDataSource,
                                        UISearchBarDelegate,
                                        UISearchControllerDelegate,
                                        YTPlayerViewDelegate>

@property (retain, nonatomic) NSDictionary          *videoListJSON;
@property (strong, nonatomic) NSMutableArray        *popularVideoList;
@property (strong, nonatomic) NSMutableArray        *videoList;
@property (weak, nonatomic)   IBOutlet UITableView  *videoTableView;
@property (strong, nonatomic) UIRefreshControl      *refreshControl;
@property (strong, nonatomic) UISearchController    *searchController;
@property (nonatomic)         int                   rowCount;
@property (nonatomic)         BOOL                  isSearch;

@property (strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property (strong, nonatomic) IBOutlet UIView       *detailsView;

@property (strong, nonatomic) IBOutlet UILabel      *videoTitle;
@property (strong, nonatomic) IBOutlet UILabel      *channelID;
@property (strong, nonatomic) IBOutlet UILabel      *likeCount;
@property (strong, nonatomic) IBOutlet UILabel      *dislikeCount;
@property (strong, nonatomic) IBOutlet UITextView *videoDescription;

@property BOOL                                      statusBarNeeded;
@property BOOL                                      mpRemoved;

@property (strong, nonatomic) NSMutableArray        *totalString;

@property(strong, nonatomic) NSMutableArray *ParsingArray; // Put that in .h file or after @interface in your .m file

@end

@implementation PopularVideoViewController


#pragma mark System methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(backToPopular)];
        
        leftBarButtonItem.tintColor = [UIColor blackColor];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        self.navigationItem.leftBarButtonItem.enabled = NO;


        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(searchIconButtonClicked)];
        
        rightBarButtonItem.tintColor = [UIColor blackColor];
        [self.navigationItem setRightBarButtonItem:rightBarButtonItem];

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    //self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController setHidesNavigationBarDuringPresentation:NO];
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Search...";
    
    //self.searchController.active = NO;
    
    self.videoTableView.delegate = self;
    self.videoTableView.dataSource = self;
    
    self.playerView.delegate = self;
    
    self.videoTableView.tableHeaderView = self.searchController.searchBar;
    
    self.videoList = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"UTube";
    //self.navigationController.navigationBar.translucent = NO;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getPopularVideoList) forControlEvents:UIControlEventValueChanged];
    [self.videoTableView addSubview:self.refreshControl];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.playerView addGestureRecognizer:swipeDown];
    [self.playerView addGestureRecognizer:swipeUp];
    [self.playerView addGestureRecognizer:swipeLeft];
    
    
    [self getPopularVideoList];
    
    self.statusBarNeeded = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // layouting views
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    /*
    CGRect playerViewRect = CGRectMake(self.view.frame.size.width+10,
                                       0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.width / 16 * 9 + 20);
     */
    CGRect playerViewRect = CGRectMake(self.view.frame.size.width+10,
                                       self.view.frame.size.height,
                                       self.view.frame.size.width,
                                       self.view.frame.size.width / 16 * 9 + 20);
    CGRect detailsViewRect = CGRectMake(0,
                                        self.view.frame.size.height,
                                        playerViewRect.size.width,
                                        self.view.frame.size.height - playerViewRect.size.height);
    
    self.playerView.frame = playerViewRect;
    
    self.detailsView.frame = detailsViewRect;
    
    self.videoTableView.frame = self.view.bounds;
    self.mpRemoved = YES;

    }

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark Orientation methods

- (CGFloat) orientationMultiplier
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        return 2;
    }
    else
        return 4;
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    
    CGFloat orientationMiltiplier = [self orientationMultiplier];
    
    CGFloat mpWidth = self.view.frame.size.width / orientationMiltiplier;
    CGFloat mpHeight = self.view.frame.size.width / 16 * 9 / orientationMiltiplier;
    
    CGFloat x = self.view.bounds.size.width-mpWidth - 20;
    CGFloat y = self.view.bounds.size.height-mpHeight - 20;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            if (self.playerView.frame.origin.x == 0)
            {
                NSLog(@"Portrait Orientation");
                CGRect playerViewRect = CGRectMake(0,
                                                   0,
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.width / 16 * 9 + 20 );
                self.playerView.frame = playerViewRect;
                CGRect detailsViewRect = CGRectMake(playerViewRect.origin.x,
                                                    playerViewRect.size.height-1,
                                                    playerViewRect.size.width,
                                                    self.view.frame.size.height - playerViewRect.size.height);
                self.detailsView.frame = detailsViewRect;
            }
            else if (!self.mpRemoved)
            {

                CGRect containerFrame = CGRectMake(x, y, mpWidth, mpHeight);
                [UIView animateWithDuration:0.5 animations:^{
                    self.playerView.frame = containerFrame;
                }];

            }
            self.videoTableView.frame = self.view.frame;
            
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            if (self.playerView.frame.origin.x == 0)
            {
                CGRect playerViewRect = CGRectMake(0,
                                                   0,
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height);
                self.playerView.frame = playerViewRect;
                NSLog(@"%@",NSStringFromCGRect(self.playerView.frame));
            }
            else if (!self.mpRemoved)
            {
                
                CGRect containerFrame = CGRectMake(x, y, mpWidth, mpHeight);
                [UIView animateWithDuration:0.5 animations:^{
                    self.playerView.frame = containerFrame;
                }];
            }

 
            self.videoTableView.frame = self.view.frame;
    
            
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}

#pragma mark Network methods

- (void)getPopularVideoList
{
//    self.popularVideoList = [YouTubeTools popularVideoArrayWithMaxResults:@"25"
//                                             withCompletitionBlock:^()
    self.popularVideoList = [YouTubeTools popularVideoListArrayWithMaxResults:@"25" videoCategoryId:@"" regionCode:@"TH" withCompletitionBlock:^()
                      {
                          self.isSearch = NO;
                          [self.videoTableView reloadData];
                          [self.refreshControl endRefreshing];
                          self.navigationItem.title = @"UTube";
                      }
                      ];
    self.isSearch = NO;
}

- (void) handleRefresh
{
    if (!self.isSearch)
        [self getPopularVideoList];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.videoList = [YouTubeTools findVideoArrayWithString:self.searchController.searchBar.text
                                                 maxResults:@"50"
                                      withCompletitionBlock:^
                      {
                          self.isSearch = YES;
                          self.navigationItem.leftBarButtonItem.enabled = YES;
                          [self.videoTableView reloadData];
                          self.navigationItem.title = @"Search";
                      }
                      ];
    [self.view endEditing:YES];
}

#pragma mark UITableView methods

// Number of sections in tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Number of rows in sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearch)
        return [self.videoList count];
    else
        return [self.popularVideoList count];
}

// Performing actions to update the cell in tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    CustomVideoCell *cell = (CustomVideoCell *)[self.videoTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSString *nibName;
        if (self.isSearch)
            nibName = @"SearchCustomCell";
        else
            nibName = @"CustomVideoCell";
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //[cell.playerView loadWithVideoId:@"M7lc1UVf-VE" playerVars:playerVars];
    YouTubeVideo *youTubeVideo;
    if (self.isSearch)
        youTubeVideo = self.videoList[indexPath.row];
    else
        youTubeVideo = self.popularVideoList[indexPath.row];

    
    [cell.previewImage setImageWithURL: [NSURL URLWithString: youTubeVideo.previewUrl]];
    [cell.previewImage setImageWithURL: [NSURL URLWithString: youTubeVideo.previewUrl]];
    cell.title.text = youTubeVideo.title;
    
    NSNumberFormatter *aFormatter = [NSNumberFormatter new];
    [aFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *myNumberLikesCount = [aFormatter numberFromString:youTubeVideo.likesCount];
    cell.likeCount.text = [NSString stringWithFormat:@"%@", [aFormatter stringFromNumber:myNumberLikesCount]];
    
    NSNumber *myNumberDislikesCount = [aFormatter numberFromString:youTubeVideo.dislikesCount];
    cell.dislikeCount.text = [NSString stringWithFormat:@"%@", [aFormatter stringFromNumber:myNumberDislikesCount]];
    
    //cell.likeCount.text = [NSString stringWithFormat:@"Просмотров: %@", youTubeVideo.viewsCount];
    cell.chanelTitle.text = youTubeVideo.channelTitle;
    
    
    NSNumber *myNumberViewsCount = [aFormatter numberFromString:youTubeVideo.viewsCount];
    cell.viewCount.text = [NSString stringWithFormat:@"View: %@", [aFormatter stringFromNumber:myNumberViewsCount]];
    
    cell.time.text = youTubeVideo.duration;
    
    //cell.frame = CGRectMake(0, 0, 500, cell.frame.size.height);
    
    return cell;

}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    YouTubeVideo *youTubeVideo;
    if (self.isSearch)
        youTubeVideo = self.videoList[indexPath.row];
    else
        youTubeVideo = self.popularVideoList[indexPath.row];
    
    self.mpRemoved = NO;
    
    NSDictionary *playerVars = @{
                                 @"playsinline" : @"1",
                                 @"autoplay" :@1,
                                 @"showinfo" :@0,
                                 @"controls" :@1,
                                 @"enablejsapi" :@1,
                                 @"modestbranding" :@1,
                                 @"rel": @0,
                                 @"fs": @1,
                                 @"theme" :@"light"
                                 
                                 };
    
    //NSDictionary *playerParams = @{@"videoId" : youTubeVideo.videoID, @"playerVars" : playerVars};
    
    [self.playerView loadWithVideoId:youTubeVideo.videoID playerVars:playerVars];

    [self.playerView playVideo];
    
    self.videoTitle.text = youTubeVideo.title;
    self.videoDescription.text = youTubeVideo.videoDescription;
    self.likeCount.text = youTubeVideo.likesCount;
    self.dislikeCount.text = youTubeVideo.dislikesCount;
    self.channelID.text = youTubeVideo.channelTitle;
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.statusBarNeeded = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.searchController.active = NO;
    [self.view endEditing:YES];

    [UIView animateWithDuration:0.3 animations:^
    {
        CGRect playerViewRect = self.playerView.frame;
        CGRect detailsViewRect = self.detailsView.frame;
        
        playerViewRect.origin.x = 0;
        playerViewRect.origin.y = 0;
        playerViewRect.size.width = self.view.bounds.size.width;
        playerViewRect.size.height = playerViewRect.size.width / 16 * 9 + 20;
        self.playerView.frame = playerViewRect;
        
        detailsViewRect.origin.x = 0;
        detailsViewRect.origin.y = playerViewRect.size.height;
        self.detailsView.frame = detailsViewRect;
        self.detailsView.alpha = 1.0;
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        //[self.playerView setSizeOfIFrameToWidth:160 Height:90];
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearch)
        return 88;
    else
        return 296;
}

#pragma mark Gesture Recognizers

-(void)swipeLeft:(UIGestureRecognizer *)gr
{
    if (![self mpIsMinimized])
        return;
    [self.playerView stopVideo];
    
    CGRect playerFrame = self.playerView.frame;
    playerFrame.origin.x = -self.playerView.frame.size.width;
    
    [UIView animateWithDuration:0.3 animations:^
     {
         self.playerView.frame = playerFrame;
     }
     completion:^(BOOL finished)
     {
         self.playerView.frame = CGRectMake(self.view.frame.size.width, 0, 0, 0);
     }];
    
    self.mpRemoved = YES;
    
}

- (void)swipeDown:(UIGestureRecognizer *)gr
{
    [self minimizeMp:YES animated:YES];
}

- (void)swipeUp:(UIGestureRecognizer *)gr
{
    [self minimizeMp:NO animated:YES];
}


#pragma mark Minimization methods

-(BOOL)mpIsMinimized {
    return self.playerView.frame.origin.y > 50;
}


- (void)minimizeMp:(BOOL)minimized animated:(BOOL)animated {
    
    NSLog(@"X: %f Y: %f", self.playerView.frame.origin.x, self.playerView.frame.origin.y);
    if ([self mpIsMinimized] == minimized) return;
    
    CGRect tallContainerFrame, containerFrame;
    CGFloat tallContainerAlpha;
    
    CGFloat orientationMultiplier = [self orientationMultiplier];
    if (minimized)
    {
        CGFloat mpWidth = self.playerView.frame.size.width / orientationMultiplier;
        CGFloat mpHeight = self.playerView.frame.size.height / orientationMultiplier;
        
        CGFloat x = self.view.bounds.size.width-mpWidth - 20;
        CGFloat y = self.view.bounds.size.height-mpHeight - 20;
        
        tallContainerFrame = CGRectMake(0, self.view.frame.size.height,
                                        self.detailsView.frame.size.width, self.detailsView.frame.size.height);
        containerFrame = CGRectMake(x, y, mpWidth, mpHeight);
        tallContainerAlpha = 0.0;
        
        self.searchController.active = NO;
        [self.view endEditing:YES];
        
        self.statusBarNeeded = TRUE;
        [self setNeedsStatusBarAppearanceUpdate];
        
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
    else
    {
        containerFrame.origin.x = 0;
        containerFrame.origin.y = 0;
        containerFrame.size.width = self.view.bounds.size.width;
        containerFrame.size.height = containerFrame.size.width / 16 * 9 + 20;
        
        tallContainerFrame = self.detailsView.frame;
        tallContainerFrame.origin.y = containerFrame.size.height;
        tallContainerAlpha = 1.0;
        
        self.statusBarNeeded = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        
        
        
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
    
    NSTimeInterval duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        
        //self.youTubePlayer.frame = containerFrame;
        self.playerView.frame = containerFrame;
       // self.playerView.webView.frame = CGRectMake(0, 0, containerFrame.size.width, containerFrame.size.height);
        self.detailsView.frame = tallContainerFrame;
        self.detailsView.alpha = tallContainerAlpha;
        
    }];
}

#pragma mark SearchBar methods

- (IBAction)searchIconButtonClicked {
    /*
    if (self.searchController.active || (self.videoTableView.contentOffset.y < 44))
    {
        if (self.searchController.active)
        {
            self.searchController.searchBar.text = nil;
            [self.searchController setActive:YES];
           // [self.videoTableView reloadData];
        }
        [self hideSearchBar];
    }
    else
    {
        [self.videoTableView scrollRectToVisible:CGRectMake(100, 0, 1, 1) animated:YES];
        //CGRect searchBarFrame = self.searchController.searchBar.frame;
        //[self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    }
     */
    
    if (self.searchController.isActive)
        self.searchController.active = NO;
    else
    {
        CGRect searchBarFrame = self.searchController.searchBar.frame;
        [self.videoTableView scrollRectToVisible:searchBarFrame animated:NO];
        self.searchController.active = YES;
    }
    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    //self.searchController.active = NO;
}

#pragma mark Other methods

- (BOOL)prefersStatusBarHidden
{
    return !self.statusBarNeeded;
}

- (void)hideSearchBar {
    //NSLog(@"Hiding SearchBar");
    //[self.videoTableView setContentOffset:CGPointMake(0,44)];
    [UIView animateWithDuration:0.5 animations:^{
        /*
        CGRect rect = self.searchController.searchBar.frame;
        rect.size.height = 0;
        self.searchController.searchBar.frame = rect;
        self.searchController.searchBar.alpha = 0.0;
         */
        
        CGRect rect2 = self.videoTableView.frame;
        rect2.origin.y = -44;
        self.videoTableView.frame = rect2;
    }];
}

-(void)backToPopular
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.isSearch = NO;
    self.navigationItem.title = @"UTube";
    [self.videoTableView reloadData];
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started" object:self];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(VideoExitFullScreen)
    //                                                 name:UIWindowDidBecomeVisibleNotification
    //                                               object:self.view.window];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(VideoEnterFullScreen)
    //                                                 name:UIWindowDidBecomeHiddenNotification
    //                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VideoExitFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    
    [self.playerView playVideo];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStateEnded:
            NSLog(@"Ended");
            break;
        case kYTPlayerStatePaused:
            NSLog(@"Paused");
            break;
        default:
            break;
    }
}

- (void)VideoExitFullScreen{
    NSLog(@"VideoExitFullScreen");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started" object:self];
    
    
    [self.playerView playVideo];
}

- (void)VideoEnterFullScreen{
    NSLog(@"VideoEnterFullScreen");
}

-(void)autocompleteSegesstions : (NSString *)searchWish{
    //searchWish is the text from your search bar (self.searchBar.text)
    
    
    // getting json from YouTube API
    NSString *urlString = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?client=youtube&ds=yt&client=firefox&q=%@", searchWish];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {

         NSLog(@"%@", responseObject);
         self.totalString = [[NSMutableArray alloc] initWithObjects:[responseObject objectAtIndex:1], nil];
         NSLog(@"%@", self.totalString);
         
//         if ([[self.totalString objectAtIndex:0] count] >= 1) {
//             //NSArray *suffixs = @[@"163.com", @"qq.com", @"126.com", @"vip.188.com", @"188.com"];
//             self.autoCompleteSuffixView = [[AutoCompleteSuffixView alloc] initWithInputField:self.ursTextField
//                                                                                      suffixs:[self.totalString objectAtIndex:0]];
//             self.autoCompleteSuffixView.tag = 99;
//             
//             [self.view addSubview:self.autoCompleteSuffixView];
//             
//             //you can use the original UITextField's delegate too.
//             //self.ursTextField.delegate = self;
//             
//         }
         
         


     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Video playlist"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
     }];
    
    // 5
    [operation start];

    
//    NSString *jsonString = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?client=youtube&ds=yt&client=firefox&q=%@", searchWish];
//    NSString *URLString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // Encoding to identify where, for example, there are spaces in your query.
//    
//    
//    NSLog(@"%@", URLString);
//    
//    NSData *allVideosData = [[NSData alloc]initWithContentsOfURL:[[NSURL alloc]initWithString:URLString]];
//    
//    NSString *str = [[NSString alloc]initWithData:allVideosData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", str); //Now you have NSString contain JSON.
//    NSString *json = nil;
//    NSScanner *scanner = [NSScanner scannerWithString:str];
//    [scanner scanUpToString:@"[[" intoString:NULL]; // Scan to where the JSON begins
//    [scanner scanUpToString:@"]]" intoString:&json];
//    //The idea is to identify where the "real" JSON begins and ends.
//    json = [NSString stringWithFormat:@"%@%@", json, @"]]"];
//    NSLog(@"json = %@", json);
//    
//    
//    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] //Push all the JSON autocomplete detail in to jsonObject array.
//                                                          options:0 error:NULL];
//    self.ParsingArray = [[NSMutableArray alloc]init]; //array that contains the objects.
//    for (int i=0; i != [jsonObject count]; i++) {
//        for (int j=0; j != 1; j++) {
//            NSLog(@"%@", [[jsonObject objectAtIndex:i] objectAtIndex:j]);
//            [self.ParsingArray addObject:[[jsonObject objectAtIndex:i] objectAtIndex:j]];
//            //Parse the JSON here...
//            
//        }
//        
//    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self autocompleteSegesstions:self.searchController.searchBar.text];
}


@end
