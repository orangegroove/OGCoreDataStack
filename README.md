# What is this?

A multi-threaded Core Data stack. Design goals are ease of use, compile-time checks, and wrappers for some common use cases.

# Installation

1. Add as a pod.
2. Import OGCoreDataStack.h in prefix.pch.

# Concepts

## To whom it may concern

This is not the be-all and end-all library for Core Data. For that, you might want to check out something more comprehensive, like [MagicalRecord](https://github.com/magicalpanda/MagicalRecord). It is, however, intended to cover most use-cases, favor convention of configuration, and simply make your life easier.

It's probably not for you if you have some special requirements, e.g., a complex setup with multiple managed object models.

## Setup

The library has only one persistent store coordinator and one persistent store. It's lazily loaded. If you need to customize it, call

	+ (void)setupWithStoreType:(NSString *)storeType options:(NSDictionary *)options;

before first use. No other setup is required. It should automatically detect your managed object model (assuming you have and only one).

## NSManagedObjectContext

The library has a context-centric design. You can use contexts in multiple ways. Instead of forcing you to use one or two contexts (for instance, one context for keeping the UI updated and one context for importing data), it's your responsibility to create contexts as needed. You can have a few long-lived contexts, or you can discard them as needed, or mix and match with one context that retains its objects and other contexts for manipulating data as needed. It's up to you.

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

NSManagedObjects can be setup to have an id property, much like tables in relational databases. This is used for keeping data in sync with such a source (most likely you'll be importing JSON from a web service). It's done with the following methods:

	- (void)populateWithDictionary:(NSDictionary *)dictionary options:(OGCoreDataStackPopulationOptions)options;
	- (NSMutableDictionary *)translatedPopulationDictionary:(NSMutableDictionary *)dictionary;

## Notes

- If you don't disable Foundation assertions in production code, you might end with some exceptions.
- Uses the @import keyword, so enable modules.

# Documentation

More specific documentation in the headers. It's really very easy to use if you understand the basic concepts of Core Data. Check out [Apple's documentation](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/coredata/cdProgrammingGuide.html).
