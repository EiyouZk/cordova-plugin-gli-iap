#import "AlipayPlugin.h"
#import "Order.h"

#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#import<StoreKit/StoreKit.h>

#define ProductID_IAP0p99 @"com.buytest.one"//$0.99
#define ProductID_IAP1p99 @"com.buytest.two" //$1.99
#define ProductID_IAP4p99 @"com.buytest.three" //$4.99
#define ProductID_IAP9p99 @"com.buytest.four" //$19.99
#define ProductID_IAP24p99 @"com.gli.dchapp" //$24.99

@interface AlipayPlugin () <SKRequestDelegate, SKProductsRequestDelegate>
@end

@implementation AlipayPlugin

-(void)pluginInitialize{
    CDVViewController *viewController = (CDVViewController *)self.viewController;
    self.partner = [viewController.settings objectForKey:@"partner"];
    self.seller = [viewController.settings objectForKey:@"seller"];
    self.privateKey = [viewController.settings objectForKey:@"privatekey"];
    
}

-(void)buy:(int)type
{
    buyType = type;
    if ([SKPaymentQueue canMakePayments]) {
        //[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        [self RequestProductData];
        NSLog(@"允许程序内付费购买");
    }
    else
    {
        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"You can‘t purchase in app store（Himi说你没允许应用程序内购买）"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
        
        [alerView show];
//        [alerView release];
        
    }
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}

-(void)RequestProductData
{
    NSLog(@"---------请求对应的产品信息------------");
    NSArray *product = nil;
    switch (buyType) {
        case IAP0p99:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP0p99,nil];
            break;
        case IAP1p99:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP1p99,nil];
            break;
        case IAP4p99:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP4p99,nil];
            break;
        case IAP9p99:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP9p99,nil];
            break;
        case IAP24p99:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP24p99,nil];
            break;
            
        default:
            break;
    }
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
//    [product release];
}

//<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", [myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }
    SKPayment *payment = nil;
    switch (buyType) {
        case IAP0p99:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP0p99];    //支付$0.99
            break;
        case IAP1p99:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP1p99];    //支付$1.99
            break;
        case IAP4p99:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP4p99];    //支付$9.99
            break;
        case IAP9p99:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP9p99];    //支付$19.99
            break;
        case IAP24p99:
            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP24p99];    //支付$29.99
            break;
        default:
            break;
    }
    NSLog(@"---------发送购买请求------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
//    [request autorelease];
    
}

- (void)requestProUpgradeProductData
{
    NSLog(@"------请求升级数据---------");
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.productid"];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}

//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    [alerView show];
//    [alerView release];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
    
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
//    [transactions release];
}

//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {[self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                NSLog(@"不允许程序内付费购买");
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:@"Himi说你购买成功啦～娃哈哈"
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
                
                [alerView show];
                break;}
                
            case SKPaymentTransactionStateFailed:
            {[self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                     message:@"Himi说你购买失败，请重新尝试购买～"
                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil) otherButtonTitles:nil];
                [alerView2 show];
                break;}
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction

{
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    
}
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction

{
    NSLog(@" 交易恢复处理");
    
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----");
}


#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@",  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    switch([(NSHTTPURLResponse *)response statusCode]) {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"test");
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
//    [super dealloc];
}



- (void) pay:(CDVInvokedUrlCommand*)command
{
    self.currentCallbackId = command.callbackId;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    ////////////////////////
    [self buy:IAP24p99];
    
    
    
    
    

    

//    /*
//     *商户的唯一的parnter和seller。
//     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
//     */
//
//    //partner和seller获取失败,提示
//    if ([self.partner length] == 0 ||
//        [self.seller length] == 0 ||
//        [self.privateKey length] == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"缺少partner或者seller或者私钥。"
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//
//    /*
//     *生成订单信息及签名
//     */
//
//    //从API请求获取支付信息
//    NSMutableDictionary *args = [command argumentAtIndex:0];
//    NSString   *tradeId  = [args objectForKey:@"tradeNo"];
//    NSString   *subject  = [args objectForKey:@"subject"];
//    NSString   *body     = [args objectForKey:@"body"];
//    NSString   *price    = [args objectForKey:@"price"];
//    NSString   *notifyUrl    = [args objectForKey:@"notifyUrl"];
//    NSString   *payinfo    = [args objectForKey:@"payinfo"];
//
//    Order *order = [[Order alloc] init];
//    order.partner = self.partner;
//    order.seller = self.seller;
//    order.tradeNO = tradeId; //订单ID（由商家自行制定）
//    order.productName = subject; //商品标题
//    order.productDescription = body; //商品描述
//    order.amount = price; //商品价格
//    order.notifyURL =  notifyUrl; //回调URL
//
//    order.service = @"mobile.securitypay.pay";
//    order.paymentType = @"1";
//    order.inputCharset = @"utf-8";
//    order.itBPay = @"30m";
//    order.showUrl = @"m.alipay.com";
//
//    //将商品信息拼接成字符串
//    NSString *orderSpec = [order description];
//    NSLog(@"orderSpec = %@",orderSpec);
//
//    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
//    id<DataSigner> signer = CreateRSADataSigner(self.privateKey);
//    NSString *signedString = [signer signString:orderSpec];
//
//    //将签名成功字符串格式化为订单字符串,请严格按照该格式
//    NSString *orderString = nil;
//    if (signedString != nil) {
//        //orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderSpec, signedString, @"RSA"];
//        
//        orderString = payinfo;
//		NSString * schemename = @"GliAlipay";
//		
//        [[AlipaySDK defaultService] payOrder:orderString fromScheme:schemename callback:^(NSDictionary *resultDic) {
//            if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
//                [self successWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
//            } else {
//                [self failWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
//            }
//            
//            NSLog(@"reslut = %@",resultDic);
//        }];
//
//    }
}

- (void)handleOpenURL:(NSNotification *)notification
{
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:[NSString stringWithFormat:@"a%@", self.partner]])
    {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
                [self successWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
            } else {
                [self failWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
            }
        }];
    }
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}
- (void)successWithCallbackID:(NSString *)callbackID messageAsDictionary:(NSDictionary *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID messageAsDictionary:(NSDictionary *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

@end
