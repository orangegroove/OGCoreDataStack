//
//  OGCoreDataStackCommon.h
//
//  Created by Jesper <jesper@orangegroove.net>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

@import Foundation;

typedef void (^OGCoreDataStackStoreSetupCallbackBlock)(BOOL success, NSError* error);
typedef void (^OGCoreDataStackFetchRequestBlock)(NSFetchRequest* request);
typedef void (^OGCoreDataStackVendorObjectsUpdated)(NSIndexSet* insertedSections, NSIndexSet* deletedSections, NSArray* insertedItems, NSArray* deletedItems, NSArray* updatedItems);

typedef NS_ENUM(NSUInteger, OGCoreDataStackContextConcurrency)
{
	/**
	 Runs on the main thread. Use for contexts that interact with the UI.
	 */
	OGCoreDataStackContextConcurrencyMainQueue,
	
	/**
	 Runs on a serial queue. Use for long running operations, such as large data imports.
	 */
	OGCoreDataStackContextConcurrencyBackgroundQueue
};

typedef NS_OPTIONS(uint64_t, OGCoreDataStackPopulationOptions)
{
	/**
	 Default behaviour.
	 */
	OGCoreDataStackPopulationOptionNone = 0,
	
	/**
	 Only attempts to populate a value if the value class matches the attribute type.
	 */
	OGCoreDataStackPopulationOptionTypeCheck = 1 << 1,
	
	/**
	 Sends KVO notifications in batches (per object) instead of per value.
	 */
	OGCoreDataStackPopulationOptionBatchNotifications = 1 << 2,
	
	/**
	 Skips calling +translatedPopulationDictionary:.
	 */
	OGCoreDataStackPopulationOptionSkipTranslation = 1 << 3
};
