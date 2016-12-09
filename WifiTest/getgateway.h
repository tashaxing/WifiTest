//
//  getgateway.h
//  MSTEnterprise
//
//  Created by chuting  on 13-4-24.
//  Copyright (c) 2013年 chuting . All rights reserved.
//



#ifndef MSTEnterprise_getgateway_h
#define MSTEnterprise_getgateway_h
#include <TargetConditionals.h>


// route.h这个文件存在于模拟器，而不再真机，所以只能拷贝一份放在工程中，You can find the route.h file in /usr/include/net folder in your mac. Just copy it into your xcode project. it works ;)

#if  TARGET_IPHONE_SIMULATOR
#include <net/route.h>
#elif TARGET_OS_IPHONE
#include "route.h"
#endif

unsigned char * getdefaultgateway(in_addr_t * addr);

#endif
