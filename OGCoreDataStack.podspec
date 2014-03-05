Pod::Spec.new do |s|
  s.name                 = "OGCoreDataStack"
  s.version              = "0.3.2"
  s.summary              = "A multi-threaded Core Data stack. Design goals are ease of use, compile-time checks, and wrappers for some common use cases."
  s.homepage             = "https://github.com/OrangeGroove/OGCoreDataStack"
  s.license              = { :type => "MIT" }
  s.authors              = { "Jesper" => "jesper@orangegroove.net" }
  s.source               = { :git => "https://github.com/OrangeGroove/OGCoreDataStack.git", :tag => s.version.to_s }
  s.platform             = :ios, "7.0"
  s.private_header_files = "OGCoreDataStack/**/*Private.h"
  s.framework            = "CoreData"
  s.requires_arc         = true
  
  s.subspec "Core" do |sc|
    sc.source_files      = "OGCoreDataStack/Core/*.[hm]"
  end
  
  s.subspec "Vendor" do |sv|
    sv.dependency          "OGCoreDataStack/Core"
    sv.source_files      = "OGCoreDataStack/Vendor/*.[hm]"
  end
end
