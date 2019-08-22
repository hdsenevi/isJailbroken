//
//  JB.m
//  isJailbroken
//
//  Created by Anthony Viriya on 8/21/19.
//  Copyright © 2019 AVL. All rights reserved.
//  Reference : https://www.theiphonewiki.com/wiki/Bypassing_Jailbreak_Detection
//

#import "JB.h"

@implementation JB

BOOL canOpen(NSString * path)
{
    FILE *file = fopen([path UTF8String], "r");
    if(file==nil){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = YES;
        if([fileManager fileExistsAtPath:path isDirectory:&isDirectory]){
            return YES;
        }
        return NO;
    }
    fclose(file);
    return YES;
}

BOOL isJb()
{
    //Check installed app
    if(canOpen(@"/Applications/Cydia.app") ||
       canOpen(@"/Library/MobileSubstrate/MobileSubstrate.dylib") ||
       canOpen(@"/bin/bash") ||
       canOpen(@"/usr/sbin/sshd") ||
       canOpen(@"/etc/apt") ||
       canOpen(@"/usr/bin/ssh") ||
       canOpen(@"/private/var/lib/apt") ||
       canOpen(@"/private/var/lib/cydia") ||
       canOpen(@"/private/var/tmp/cydia.log") ||
       canOpen(@"/private/var/lib/cydia"))
    {
        return YES;
    }
    
    //symlink verification
    struct stat sym;
    if(lstat("/Applications", &sym) || lstat("/var/stash/Library/Ringtones", &sym) ||
       lstat("/var/stash/Library/Wallpaper", &sym) ||
       lstat("/var/stash/usr/include", &sym) ||
       lstat("/var/stash/usr/libexec", &sym)  ||
       lstat("/var/stash/usr/share", &sym) ||
       lstat("/var/stash/usr/arm-apple-darwin9", &sym))
    {
        if(sym.st_mode & S_IFLNK){
            return YES;
        }
    }
    
    //Check process forking
    int pid = fork();
    if(!pid)
    {
        exit(1);
    }
    if(pid >= 0)
    {
        return YES;
    }
    
    //Check permission to write to /private
    NSMutableString *path = [[NSMutableString alloc] initWithString:@"/private/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [path appendString:[[NSUUID UUID] UUIDString]];
    @try {
        NSString *test = @"test";
        [test writeToFile:test atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
        [fileManager removeItemAtPath:test error:nil];
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
    
    
}

@end
