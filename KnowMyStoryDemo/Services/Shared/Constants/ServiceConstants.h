
// File Name: ServiceConstants
// Created By: Aswathy
// Created On: 02/08/12.
// Purpose: To Handle Constants of Services
// Copyright (c) 2013 Payment Processing Partners, Inc. All rights reserved.


#define HTTP_POST_METHOD @"POST"
#define HTTP_GET_METHOD @"GET"
#define HEADER_APPLICATION_TYPE @"application/json"
#define HEADER_ACCEPT_ENCODING @"gzip, deflate"
#define HEADER_XML_APPLICATION_TYPE @"text/xml; charset=utf-8"

#define API_BASE_URL @"BaseUrl"

#define BASE_URL @"http://mystory.buzz:80/api/"
//#define BASE_URL @"http://kms.fingent.net/api/"

#define CREATE_USER @"adduser"
#define UPDATE_USER @"updateuser"
#define VIEW_USER_DETAIILS @"viewuser"
#define YOUTUBE_UPLOAD @"addselfievideo"
#define CHANNELS_VIEW @"allvideos"
#define MY_SELFIES_VIEW @"selfievideos"
#define TOPIC_LIST @"topiclist"

#define BASE_BIBLE_URL @"http://dbt.io/text/"
#define SCRIPTURE_SEARCH @"verse?key=%@&dam_id=%@&book_id=%@&chapter_id=%@&verse_start=%@&v=2"
#define SCRIPTURE_SEARCH_FOR_KEYWORD @"search?key=%@&dam_id=ENGESVO2ET&query=%@&v=2"

#define FACEBOOK_SHARE_URL  @"facebook.com/sharer"
#define TWITTER_SHARE_URL   @"twitter.com/share"

typedef enum ServiceType
{
   
    ServiceTypeGetDetailsOfUser,
    ServiceTypeUpdateUser,
    ServiceTypeCreateUser,
    ServiceTypeYoutubeResponseUpload,
    ServiceTypeScriptureSearch,
    ServiceTypeChannelsView,
    ServiceTypeScriptureForKeyword,
    ServiceTypeTopicList,
    ServiceTypeMySelfiesView
    
}ServiceType;



