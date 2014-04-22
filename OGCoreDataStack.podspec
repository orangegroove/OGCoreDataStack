Pod::Spec.new do |s|
  s.name                 = "OGCoreDataStack"
  s.version              = "0.3.8"
  s.summary              = "A multi-threaded Core Data stack. Design goals are ease of use, compile-time checks, and wrappers for some common use cases."
  s.homepage             = "https://github.com/OrangeGroove/OGCoreDataStack"
  s.license              = { :type => "MIT" }
  s.authors              = { "Jesper" => "jesper@orangegroove.net" }
  s.source               = { :git => "https://github.com/OrangeGroove/OGCoreDataStack.git", :tag => s.version.to_s }
  s.platform             = :ios, "7.0"
  s.private_header_files = "OGCoreDataStack/*Private.h"
  s.framework            = "CoreData"
  s.requires_arc         = true
  
  s.subspec "Core" do |sc|
    sc.source_files      = "OGCoreDataStack/OGCoreDataStack*.[hm]", "OGCoreDataStack/*+OGCoreDataStack.[hm]", "OGCoreDataStack/OGManagedObject.[hm]", "OGCoreDataStack/OGManagedObjectContext.[hm]", "OGCoreDataStack/OGPersistentStoreCoordinator.[hm]"
  end
  
  s.subspec "Vendor" do |sv|
    sv.dependency          "OGCoreDataStack/Core"
    sv.source_files      = "OGCoreDataStack/*ManagedObjectVendor.[hm]"
  end
  
  s.subspec "UniqueId" do |su|
    su.dependency          "OGCoreDataStack/Core"
	su.source_files      = "OGCoreDataStack/*+OGCoreDataStackUniqueId.[hm]"
  end
end
