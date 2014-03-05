# What is this?

A lightweight, multi-threaded Core Data stack. Design goals are ease of use, compile-time checks, and wrappers for some common use cases.

This library is intended to cover most use-cases, favor convention of configuration, and simply make your life easier. It's probably not for you if you have some special requirements, e.g., a complex setup with multiple managed object models. For something that covers all your bases, you might want to check out [MagicalRecord](https://github.com/magicalpanda/MagicalRecord).

# Installation and setup

1. Add as a [pod](https://github.com/CocoaPods/CocoaPods).
2. Import OGCoreDataStack.h in prefix.pch.

The library has only one persistent store coordinator and one persistent store. It's lazily loaded. If you need to customize it, call

	+ (void)setupWithStoreType:(NSString *)storeType options:(NSDictionary *)options;

before first use. No other setup is required. It should automatically detect your managed object model (assuming you have one and only one).

# Concepts

## Context-centric design

You can use contexts in multiple ways. Instead of forcing you to use one or two contexts (for instance, one context for keeping the UI updated and one context for importing data), it's your responsibility to create contexts as needed. You can have a few long-lived contexts, or you can discard them as needed, or mix and match with one context that retains its objects and other contexts for manipulating data as needed. It's up to you.

Important to note is that all contexts are directly tied to the persistent store coordinator. If you need to keep other contexts updated, use

	- (void)observeSavesInContext:(NSManagedObjectContext *)context;

and

	- (void)stopObservingSavesInContext:(NSManagedObjectContext *)context;

## CRUD

Managing objects is done via class methods on the managed object subclasses.

### Create

To create an object:

	MyManagedObjectClass* object = [MyManagedObjectClass createObjectInContext:context];

### Fetch

To fetch objects:

	NSArray* objects = [MyManagedObjectClass fetchWithRequest:^(NSFetchRequest *request) {
	
		// set filter predicate and sort descriptors here
	
	} context:context];

### Count

To count objects:

	NSUInteger count = [MyManagedObjectClass countWithRequest:^(NSFetchRequest *request) {
	
		// set filter predicate here
	
	} context:context];

### Delete

To delete objects, you can either do it directly:

	[myObject delete];

or via a fetch:

	[MyManagedObjectClass deleteWithRequest:^(NSFetchRequest *request) {
	
		// set filter predicate here
	
	} context:context];

## Vending objects

OGCoreDataStackVendor is a decorator for NSFetchedResultsController and there are subclasses to use it as a data source for tableviews and collectionviews. To use a vendor as dataSource for a UITableView, create an instance of the tableview-specific subclass of the vendor:

	self.myVendor = [[OGTableViewManagedObjectVendor alloc] init];

	[self.myVendor setEntity:EntityClass.class request:^(NSFetchRequest* request) {
		
		// sort and filter the entity here

	} context:myUIContext sectionNameKeyPath:nil cacheName:nil];
	
	self.myVendor.tableView = myTableView;
	self.myVendor.vending = YES;

You still need to implement the UITableViewDataSource protocol, but use the vendor to keep track of number of sections, number of objects per section and fetching objects for an indexpath. The vendor will then keep your tableview updated as the underlying objects are updated.

## Notes

- If you don't disable Foundation assertions in production code, you might end up with some unnecessary exceptions.
- Uses the @import keyword, so enable modules.

# Documentation

More specific documentation in the headers. It's really very easy to use if you understand the basic concepts of Core Data. Check out [Apple's documentation](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/coredata/cdProgrammingGuide.html).
