
// File Name: BaseService.h
// Created By: Aswathy
// Created On: 19/09/12.
// Purpose: Base Web Service Class for CIP
// Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.

#import "BaseService.h"

@interface BaseService()
{
    NSString *requestUrl;
    id requestBody;
   
    BOOL operationComplete;
    int statusCode;
}
-(void)sendRequest;
-(void)postRequest;
-(void)getRequest;
-(void)updateStatusCode:(int) code;
@end

@implementation BaseService

@synthesize request,connection;
@synthesize requestType;

-(void) setURL:(NSString *)url
{
    requestUrl = url;
}

-(BOOL)initRequest:(NSString *)url withDelegate:(id)delegate
{
    if(self)
    {
        if(url != nil && delegate != nil)
        {
           
            requestType = HTTP_GET_METHOD;
            requestUrl = url;
            requestBody = nil;
            operationComplete = FALSE;
            _delegateObject = delegate;
             _responseData = [NSMutableData new];
            return TRUE;
            
        }
        else
        {
            return FALSE;
        }
    }
    else
    {
        return FALSE;
    }
    
}

-(BOOL)initRequest:(NSString *)url withBody:(id)body andDelegate:(id)delegate
{
   
    if(self)
    {
        
        if(url != nil && delegate != nil)
        {
            
            if(body != nil)
            {
                requestType = HTTP_POST_METHOD;
            }
            else
            {
                requestType = HTTP_GET_METHOD;
            }
            requestUrl = url;
            requestBody = body;
            _delegateObject = delegate;
            _responseData = [NSMutableData new];
            return TRUE;
        }
        else
        {
            return FALSE;
        }
       
    }
    else
    {
        return FALSE;
    }
}

-(void)postRequest
{
    NSData *requestData;
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    NSError *error;
    requestData = [NSJSONSerialization dataWithJSONObject:requestBody
                                    options:NSJSONWritingPrettyPrinted
                                                    error:&error];
    NSString *jsonString =[[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Json Response: %@",jsonString);
    if(requestData != nil)
    {
        //requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
        [request setHTTPBody:requestData];
        [request setHTTPMethod:HTTP_POST_METHOD];
        
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        [self sendRequest];
    }
    
    
    
}

-(void)getRequest
{
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod:HTTP_GET_METHOD];
    [self sendRequest];

}

-(void)sendRequest
{
    [request setValue:HEADER_APPLICATION_TYPE forHTTPHeaderField:@"Content-Type"];
    [request setValue:HEADER_APPLICATION_TYPE forHTTPHeaderField:@"Accept"];
    [request setValue:HEADER_ACCEPT_ENCODING forHTTPHeaderField:@"Accept-Encoding"];
    [request setTimeoutInterval:30];
    [request setValue:@"111222333444" forHTTPHeaderField:@"Access-Token"];
   // NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"SessionID"]);
    
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)processRequest
{
    if([requestType isEqualToString:HTTP_GET_METHOD])
    {
        [self getRequest];
        
    }
    else if([requestType isEqualToString:HTTP_POST_METHOD])
    {
        [self postRequest];
    }
    else
    {
        //Log error
    }
    
}

-(void)start
{
    if([Reachability connected]){
    if([requestType isEqualToString:HTTP_GET_METHOD])
    {
        [self getRequest];
        
    }
    else if([requestType isEqualToString:HTTP_POST_METHOD])
    {
        [self postRequest];
    }
    else
    {
        //Log error
    }
    NSRunLoop * loop = [NSRunLoop currentRunLoop];
    while (operationComplete != TRUE)
    {
        [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    }else{
        if([_delegateObject respondsToSelector:@selector(networkError)])
        {
            [_delegateObject networkError];
        }
    }
    
    //[super start];
}


//-(void) startProcess
//{
//    if([requestType isEqualToString:HTTP_GET_METHOD])
//    {
//        [self getRequest];
//        
//    }
//    else if([requestType isEqualToString:HTTP_POST_METHOD])
//    {
//        [self postRequest];
//    }
//    else
//    {
//        //Log error
//    }
//    NSRunLoop * loop = [NSRunLoop currentRunLoop];
//    while (operationComplete != TRUE)
//    {
//        [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
//}
-(void)updateStatusCode:(int) code
{
    switch (code)
    {
        case SERVICE_SUCCESSFUL:
        {
            statusCode = SERVICE_SUCCESSFUL;
            break;
        }
        case SERVICE_FAILURE:
        {
            statusCode = SERVICE_FAILURE;
            break;
        }
        case SERVICE_REQUESTTIMEOUT:
        {
            statusCode = SERVICE_INTERNALSERVERERROR;
            break;
        }
            
        case SERVICE_PAGENOTFOUND:
        {
            statusCode = SERVICE_PAGENOTFOUND;
            break;
        }
            
        default:
            statusCode = SERVICE_SUCCESSFUL;
            break;
    }
    
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self responseFailedNotification:error];
    NSLog(@"Response: %@",error.description);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response: %@",response);
   
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    [self updateStatusCode:httpResponse.statusCode];
    
    
    if(statusCode == 100)
    {
        Response *response = [[Response alloc] init];
        response.statusCode = httpResponse.statusCode;
        response.messageString = @"The service unavailable.";
        
        [self responseFailedNotification:response];
    }
    
    
    [_responseData setLength:0];

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSString *responseString = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    if(statusCode != 100)
    {
        [self responseSuccessfulNotification:_responseData];
    }
    
}

-(void)responseSuccessfulNotification:(id)response
{
    if([_delegateObject respondsToSelector:@selector(serviceSuccessful:)])
    {
        [_delegateObject serviceSuccessful:response];
    }
    operationComplete = TRUE;
}

-(void)responseFailedNotification:(id)response
{
    if([_delegateObject respondsToSelector:@selector(serviceFailed:)])
    {
        [_delegateObject serviceFailed:response];
    }
    operationComplete = TRUE;
}

- (void)networkError:(id)delegate
{
    _delegateObject = delegate;
    if([_delegateObject respondsToSelector:@selector(networkError)])
    {
        [_delegateObject networkError];
    }
    operationComplete = TRUE;
}

- (void)dealloc
{
    if(self.requestType)
    {
        requestType = nil;
    }
    if(self.request )
    {
        request= nil;
    }
    if(self.connection)
    {
       connection = nil;
    }
    if (_responseData) {
        _responseData = nil;
    }
    
}

@end   
 