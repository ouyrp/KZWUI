//
//  KZWWebViewController.m
//  KZWfinancial
//
//  Created by ouy on 2017/3/15.
//  Copyright © 2017年 ouy. All rights reserved.
//

#import "KZWWebViewController.h"
#import "WKCookieSyncManager.h"
#import "KZWHUD.h"
#import "KZWDSJavaScripInterface.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "KZWNetStateView.h"
#import <KZWUtils/KZWUtils.h>

@interface KZWWebViewController ()<WKNavigationDelegate, KZWDSJavaScripInterfaceDelegate>

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *baseUrlString;
@property (copy, nonatomic) NSNumber *backType;
@property (strong, nonatomic) KZWDSJavaScripInterface *JavaScripInterface;

@end

@implementation KZWWebViewController

- (instancetype)initWithUrl:(NSString *)urlString {
    if (self = [super init]) {
        self.baseUrlString = urlString;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initWebView];
    [self.view addSubview:self.progressView];
    [self getWebUrl];
    [self loadURLRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.JavaScripInterface = [[KZWDSJavaScripInterface alloc] init];
    self.JavaScripInterface.delegate = self;
    [self leftBar];
}

- (void)getWebUrl {
    self.url = [NSURL URLWithString:[self.baseUrlString KZW_URLDecodedString]];
}

- (void)leftBar {
    NSString *bundlePath = [[NSBundle bundleForClass:[KZWNetStateView class]].resourcePath
                            stringByAppendingPathComponent:@"/KZWFundation.bundle/KZWFundation.bundle"];
    NSBundle *resource_bundle = [NSBundle bundleWithPath:bundlePath];
    UIImage *image = [UIImage imageNamed:@"ic_colorback.png"
                                inBundle:resource_bundle
           compatibleWithTraitCollection:nil];
    UIBarButtonItem *itemone = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, 30, 30);
        button;
    })];
    self.navigationItem.leftBarButtonItems = @[itemone];
}

- (void)setNavTitl:(NSString *)model {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initWebView {
    WKUserContentController* userContentController = WKUserContentController.new;
    WKUserScript * cookieScript = [[WKUserScript alloc]
                                   initWithSource:[NSString stringWithFormat:@"document.cookie = '%@'", [self setCurrentCookie]]
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    WKCookieSyncManager *cookiesManager = [WKCookieSyncManager sharedWKCookieSyncManager];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.processPool = cookiesManager.processPool;
    configuration.userContentController = userContentController;
    self.webView = [[DWKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - KZW_StatusBarAndNavigationBarHeight) configuration:configuration];
    if (KZW_iPhoneX) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.webView.scrollView.bounces = NO;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    [self.webView addJavascriptObject:self.JavaScripInterface namespace:nil];
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:NSKeyValueObservingOptionNew context:NULL];
}

- (NSString *)readCurrentCookie {
    return @"";
}

- (NSString *)setCurrentCookie {
    return @"";
}

- (void)rightAction:(UIButton *)sender {

}

-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 2);
        
        [_progressView setTrackTintColor:[UIColor clearColor]];
        _progressView.progressTintColor = [UIColor baseColor];
    }
    return _progressView;
}

- (void)loadURLRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    [request addValue:[self readCurrentCookie] forHTTPHeaderField:@"Cookie"];
    [self.webView loadRequest:request];
}

#pragma mark wkwebdelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = NO;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlString = [[navigationAction.request URL] absoluteString];
    urlString = [urlString stringByRemovingPercentEncoding];//解析url
    //url截取根据自己业务增加代码
    if ([[navigationAction.request.URL host] isEqualToString:@"itunes.apple.com"] && [[UIApplication sharedApplication] openURL:navigationAction.request.URL]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }else if([urlString hasPrefix:@"tel"]){
        decisionHandler(WKNavigationActionPolicyCancel);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress
                              animated:animated];
        if (self.webView.estimatedProgress >= 1.0f) {
            @WeakObj(self)
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 @StrongObj(self)
                                 [self.progressView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 @StrongObj(self)
                                 [self.progressView setProgress:0.0f animated:NO];
                             }];
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            NSString *title = @"";
            if (title.length <= 0 && self.webView.title.length <=0 ) {
                self.title = @"xxxx";
            }else {
                self.title = (title.length > 0)?title:self.webView.title;
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

-(void)dismissModalStack {
    UIViewController *vc = self.presentingViewController;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:NULL];
}

- (void)back {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)comeBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)fullString:(NSString *)path {
    NSString *domain = nil;
    switch ([KZWEnvironmentManager environment]) {
        case KZWEnvBeta:
            domain = @"xxxxx";
            break;
        case KZWEnvAlpha:
            domain = @"xxxxx";
            break;
        case KZWEnvProduction:
            domain = @"xxxxx";
            break;
        default:
            domain = @"xxxxx";
            break;
    }
    if ([path containsString:@"http"]) {
        return path;
    }else {
       return [domain stringByAppendingString:path];
    }
}

- (void)dealloc {
    self.webView.UIDelegate = nil;
    [self.webView stopLoading];
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
    self.webView = nil;
}

@end
