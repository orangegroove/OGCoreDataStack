Pod::Spec.new do |s|
  s.name                 = "OGCoreDataStack"
  s.version              = "0.4.10"
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
    sc.source_files      = "OGCoreDataStack/OGCoreDataStack*.[hm]", "OGCoreDataStack/*+OGCoreDataStack.[hm]", "OGCoreDataStack/NSManagedObject+OGCoreDataStack.[hm]", "OGCoreDataStack/NSManagedObjectContext+OGCoreDataStack.[hm]", "OGCoreDataStack/NSPersistentStoreCoordinator+OGCoreDataStack.[hm]"
	sc.exclude_files     = "OGCoreDataStack/OGCoreDataStackPopulationMapper.[hm]"
  end
  
  s.subspec "Vendor" do |sv|
    sv.dependency          "OGCoreDataStack/Core"
    sv.source_files      = "OGCoreDataStack/OG*ManagedObjectVendor.[hm]"
  end
  
  s.subspec "UniqueId" do |su|
    su.dependency          "OGCoreDataStack/Core"
	  su.source_files      = "OGCoreDataStack/NSManagedObject+OGCoreDataStackUniqueId.[hm]"
  end
  
  s.subspec "Contexts" do |sc|
    sc.dependency          "OGCoreDataStack/Core"
    sc.source_files      = "OGCoreDataStack/NSManagedObjectContext+OGCoreDataStackContexts.[hm]"
  end
  
  s.subspec "Population" do |sp|
    sp.dependency          "OGCoreDataStack/Core"
    sp.dependency          "OGCoreDataStack/UniqueId"
	sp.source_files      = "OGCoreDataStack/OGCoreDataStackMappingConfiguration.[hm]", "OGCoreDataStack/NSManagedObject+OGCoreDataStackPopulation.[hm]"
  end
  
end
