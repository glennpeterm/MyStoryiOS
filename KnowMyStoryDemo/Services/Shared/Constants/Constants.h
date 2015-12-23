
//  File Name   : Constants.h
//  Created by  : Aswathy Bose
//  Created on  : 12/19/13.
//  Copyright (c) 2014 Payment Processing Partners, Inc. All rights reserved.

#import <Foundation/Foundation.h>

@protocol Constants <NSObject>



typedef NS_ENUM(NSInteger, WizardStep) {
    WizardStepUndefined = -1,
    WizardStepTitle = 0,
    WizardStepIntroduction = 1,
    WizardStepStruggle = 2,
    WizardStepIntervention = 3,
    WizardStepVerse = 4,
    WizardStepLight = 5,
    WizardStepMusic = 6,
    WizardStepDescription = 7,
    WizardStepRegion = 8,
    WizardStepUpload = 9,
};

#define kWizardViewCameraLanding    @"WizardCameraLanding"
#define kWizardViewCamera           @"WizardCamera"
#define kWizardViewClipPreview      @"WizardClipPreview"
#define kWizardViewTrim             @"WizardTrim"
#define kWizardViewFinalPreview     @"FinalPreview"
#define kWizardViewMusic            @"WizardMusic"
#define kWizardViewTitle            @"WizardTitle"
#define kWizardViewUpload           @"WizardUpload "
#define kWizardViewDescription      @"WizardDescription"
#define kWizardViewRegion           @"WizardRegion"
#define kWizardViewScripture        @"WizardScripture"
#define kWizardViewVideoPlayer      @"WizardVideoPlayer"



#define kAPP_NAME @"Know My Story"
#define kLOADING_MESSAGE @"Loading"
#define kALERT_OK_BUTTON @"OK"
#define kALERT_TITLE @"My Story"

#define IS_USER__TO_BE_CREATED @"tobecreated"
#define LOGGED_IN_USER @"loggedInUser"
#define CONFIG_ID_USER @"configIdOfUser"
#define IS_FROM_POS_APP @"isFRomPOSApp"
#define PREVIOUS_TRANSACTION_IS_FROM  @"isFromWhichApp"
#define POS_AMOUNT @"pos_amount"
#define FROM_POS_APP_AMOUNT @"fromposappamount"
#define NO_SERVER_RESPONSE @"No Server response"
#define kSERVICE_NETWORK_NOT_AVAILABLE_MSG @"Sorry, Currently Network is not available !!!"






#define kLOGGED_IN_USER_CARD_TYPE @"loggedInUserCardType"

//#define GOOGLE_APP_ID @"184749014984-9ecdg72hp5qppvdpn8j59kb0ktkb52q0.apps.googleusercontent.com"
//#define GOOGLE_APP_SECREAT @"df-g0NNr-Wht0jldTMykubvc"

#define GOOGLE_PLUS_API_KEY @"AIzaSyAj3wYUTIQuAzd_CYuSGk4RQQr4WlaCMcQ" // used for Google Plus Profile pic

#define GOOGLE_APP_ID @"861883157614-qn9i0rnh6tnampomhhfusrpv68o28tsh.apps.googleusercontent.com"
#define GOOGLE_APP_SECREAT @"LF-hXRzgMluXHiovUnPXYC09"

#define k_TWITTER_CONSUMER_KEY @"CC7mvyR7SR7i52nHWEuAI3mth"
#define k_TWITTER_CONSUMER_SECREAT @"n6EYGjG2Y1aGIfkZsLqhwwN0wuA3WFNot6LusMbINaJEtQWTzU"

#define IS_GOOGLE_SIGN_IN @"isgooglesignin"
#define IS_FB_SIGN_IN @"isfbsignin"
#define IS_TWITTER_SIGN_IN @"isTwittersignin"

#define BIBLE_KEYWORD @"c850c2830657874c0a1ca5e68724ed15"


#define VIDEO_B_ROLL_FOOTAGE_FILENAME @"MyStory_Slate_v2_720p"
#define VIDEO_TUTORIAL_ENG  @"MyStory_Exp_v3_720p"
#define PLIST_SELFIE_WIZARD_TEMPLATE_FILENAME @"SelfieWizardDataTemplate"
#define PLIST_MY_SELFIE_DATA_FILE @"MySelfieData.plist"
#define MY_SELFIE_DIRNAME   @"MyStory"

#define ACTIVITY_LOADING_ORANGE_IMAGENAME_PREFIX @"ActivityLoadingOrange_"
#define ACTIVITY_LOADING_IMAGENAME_PREFIX   @"ActivityLoading_"
#define ACTIVITY_LOADING_IMAGES_COUNT   12

//Activity Loader Texts
//#define ACTIVITY_LOADING_TEXT_PREPARING @"Preparing..."
#define ACTIVITY_LOADING_TEXT_COMPRESSING @"Compressing..."
#define ACTIVITY_LOADING_TEXT_FETCHING_DATA @"Fetching data..."
#define ACTIVITY_LOADING_TEXT_LOADING @"Loading..."
#define ACTIVITY_LOADING_TEXT_MERGING @"Merging..."
#define ACTIVITY_LOADING_TEXT_FETCHING_VERSE @"Fetching verse..."
#define ACTIVITY_LOADING_TEXT_SAVING @"Saving..."
#define ACTIVITY_LOADING_TEXT_SIGNING_IN @"Signing In..."
#define ACTIVITY_LOADING_TEXT_TRIMMING @"Trimming..."
#define ACTIVITY_LOADING_TEXT_SYNCING_WITH_SEVER @"Syncing With Server..."


#define kMenuIconSize   72

// Log include the function name and source code line number in the log statement
#ifdef KMS_DEBUG
#define KMSDebugLog(fmt, ...) NSLog((@"Func: %s, Line: %d, " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define KMSDebugLog(...)
#endif

#ifdef KMS_DEBUG
#define KMSDebugLog(fmt, ...) NSLog((@"Func: %s, Line: %d, " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define KMSDebugLog(...)
#endif


@end
