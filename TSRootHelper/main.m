#import <stdio.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "uicache.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <spawn.h>
#import <objc/runtime.h>
#import "TSUtil.h"
#import <sys/utsname.h>

#import <SpringBoardServices/SpringBoardServices.h>
#import <Security/Security.h>

NSSet<NSString*>* immutableAppBundleIdentifiers(void)
{
	NSMutableSet* systemAppIdentifiers = [NSMutableSet new];

	LSEnumerator* enumerator = [LSEnumerator enumeratorForApplicationProxiesWithOptions:0];
	LSApplicationProxy* appProxy;
	while(appProxy = [enumerator nextObject])
	{
		if(appProxy.installed)
		{
			if(![appProxy.bundleURL.path hasPrefix:@"/private/var/containers"])
			{
				[systemAppIdentifiers addObject:appProxy.bundleIdentifier.lowercaseString];
			}
		}
	}

	return systemAppIdentifiers.copy;
}

void refreshAppRegistrations()
{
	registerPath((char*)trollStoreAppPath().UTF8String, 0, YES);

	for(NSString* appPath in trollStoreInstalledAppBundlePaths())
	{
		registerPath((char*)appPath.UTF8String, 0, YES);
	}
}

void refreshAppRegistration(NSString* appBundle)
{
    registerPath((char*)appBundle.UTF8String, 1, YES);
}

// Apparently there is some odd behaviour where TrollStore installed apps sometimes get restricted
// This works around that issue at least and is triggered when rebuilding icon cache
void cleanRestrictions(void)
{
	NSString* clientTruthPath = @"/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/ClientTruth.plist";
	NSURL* clientTruthURL = [NSURL fileURLWithPath:clientTruthPath];
	NSDictionary* clientTruthDictionary = [NSDictionary dictionaryWithContentsOfURL:clientTruthURL];

	if(!clientTruthDictionary) return;

	NSArray* valuesArr;

	NSDictionary* lsdAppRemoval = clientTruthDictionary[@"com.apple.lsd.appremoval"];
	if(lsdAppRemoval && [lsdAppRemoval isKindOfClass:NSDictionary.class])
	{
		NSDictionary* clientRestrictions = lsdAppRemoval[@"clientRestrictions"];
		if(clientRestrictions && [clientRestrictions isKindOfClass:NSDictionary.class])
		{
			NSDictionary* unionDict = clientRestrictions[@"union"];
			if(unionDict && [unionDict isKindOfClass:NSDictionary.class])
			{
				NSDictionary* removedSystemAppBundleIDs = unionDict[@"removedSystemAppBundleIDs"];
				if(removedSystemAppBundleIDs && [removedSystemAppBundleIDs isKindOfClass:NSDictionary.class])
				{
					valuesArr = removedSystemAppBundleIDs[@"values"];
				}
			}
		}
	}

	if(!valuesArr || !valuesArr.count) return;

	NSMutableArray* valuesArrM = valuesArr.mutableCopy;
	__block BOOL changed = NO;

	[valuesArrM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString* value, NSUInteger idx, BOOL *stop)
	{
		if(![value hasPrefix:@"com.apple."])
		{
			[valuesArrM removeObjectAtIndex:idx];
			changed = YES;
		}
	}];

	if(!changed) return;

	NSMutableDictionary* clientTruthDictionaryM = (__bridge_transfer NSMutableDictionary*)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFDictionaryRef)clientTruthDictionary, kCFPropertyListMutableContainersAndLeaves);
	
	clientTruthDictionaryM[@"com.apple.lsd.appremoval"][@"clientRestrictions"][@"union"][@"removedSystemAppBundleIDs"][@"values"] = valuesArrM;

	[clientTruthDictionaryM writeToURL:clientTruthURL error:nil];
}


int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
        [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/testrebuild" withIntermediateDirectories:true attributes:nil error:nil];

		// loadMCMFramework();
        NSString* action = [NSString stringWithUTF8String:argv[1]];
        NSString* source = [NSString stringWithUTF8String:argv[2]];
        NSString* destination = [NSString stringWithUTF8String:argv[3]];
//        NSString* bundle = [NSString stringWithUTF8String:argv[4]];


        if ([action isEqual: @"write"]) {
			[source writeToFile:destination atomically:YES encoding:NSUTF8StringEncoding error:nil];
        } else if ([action isEqual: @"mv"]) {
            [[NSFileManager defaultManager] moveItemAtPath:source toPath:destination error:nil];
        } else if ([action isEqual: @"cp"]) {
            [[NSFileManager defaultManager] copyItemAtPath:source toPath:destination error:nil];
        } else if ([action isEqual: @"mkdir"]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:source withIntermediateDirectories:true attributes:nil error:nil];
        } else if ([action isEqual: @"rm"]) {
            [[NSFileManager defaultManager] removeItemAtPath:source error:nil];
        } else if ([action isEqual: @"chmod"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:511]  forKey:NSFilePosixPermissions];
            [[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:source error:nil];
        } else if ([action isEqual: @"rebuildiconcache"]) {
            cleanRestrictions();
            [[LSApplicationWorkspace defaultWorkspace] _LSPrivateRebuildApplicationDatabasesForSystemApps:YES internal:YES user:YES];
            refreshAppRegistrations();
            killall(@"backboardd", true);
        } else if ([action isEqual: @"refregapp"]) {
//            refreshAppRegistration(bundle);
        } else if ([action isEqual: @"ln"]) {
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:destination withDestinationPath:source error:nil];
        } else {
			NSLog(@"Unknown action: %@", action);
			return -1;	
		}

        return 0;
    }
}
