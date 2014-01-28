# What is this?

A multi-threaded Core Data stack. Design goals are ease of use, compile-time checks, and wrappers for some common use cases.

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

There is an option to easily keep track of long-lived contexts, by setting a property on the context:

	context.identifier = @"main";

If the identifier is set, a strong reference to the context is created. Set the identifier to nil to remove the reference.

Important to note is that all contexts are directly tied to the persistent store coordinator. If you need to keep other contexts updated, use

	- (void)observeSavesInContext:(NSManagedObjectContext *)context;

and

	- (void)stopObservingSavesInContext:(NSManagedObjectContext *)context;

Unlike some other Core Data libraries, you do not insert objects into a context by calling a class method on the entity class, but with an instance method on the context object. Like so:

	- (id)createObjectForEntity:(Class)entity;

You fetch, count, and delete objects for an entity in a similar manner, on the context:

	- (NSArray *)fetchFromEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block;
	- (NSUInteger)countEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block;
	- (void)deleteFromEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block;

## Importing data

NSManagedObjects can be setup to have an id property, much like tables in relational databases. This is used for keeping data in sync with such a source (most likely you'll be importing JSON from a web service). It's done with the following method:

	- (void)populateWithDictionary:(NSDictionary *)dictionary options:(OGCoreDataStackPopulationOptions)options;

If you need to modify the dictionary before importing, override

	- (NSMutableDictionary *)translatedPopulationDictionary:(NSMutableDictionary *)dictionary;

in your NSManagedObject subclass and manipulate the keys and values as needed.

## Vending objects

OGCoreDataStackVendor is a decorator for NSFetchedResultsController and there are subclasses to use it as a data source for tableviews and collectionviews. To use a vendor as dataSource for a UITableView, create an instance of the tableview-specific subclass of the vendor:

	self.myVendor = [[OGCoreDataStackTableViewVendor alloc] init];

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
