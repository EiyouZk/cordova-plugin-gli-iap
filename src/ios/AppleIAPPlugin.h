#import <Cordova/CDV.h>
#import<StoreKit/StoreKit.h>


enum{
    IAP0p99=10,
    IAP1p99,
    IAP4p99,
    IAP9p99,
    IAP24p99,
}buyCoinsTag;



@interface AlipayPlugin : CDVPlugin<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    int buyType;
}

//+(CCScene *) scene;
- (void) requestProUpgradeProductData;
-(void)RequestProductData;
-(bool)CanMakePay;
-(void)buy:(int)type;
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
-(void)provideContent:(NSString *)product;
-(void)recordTransaction:(NSString *)product;


//@interface AlipayPlugin : CDVPlugin

@property(nonatomic,strong)NSString *partner;
@property(nonatomic,strong)NSString *seller;
@property(nonatomic,strong)NSString *privateKey;
@property(nonatomic,strong)NSString *currentCallbackId;

- (void) pay:(CDVInvokedUrlCommand*)command;
@end
