Pod::Spec.new do |s|
  s.name                 = "OrangeGroove Core Data Stack"
  s.version              = "0.1.0"
  s.summary              = "Core Data stack"
  s.homepage             = "https://github.com/jksk/OGCoreDataStack"
  s.license              = :type => "MIT"
  s.authors              = "Jesper" => "jesper@orangegroove.net"
  s.source               = :git => "https://github.com/jksk/OGCoreDataStack.git", :tag => s.version.to_s
  s.platform             = :ios, "7.0"
  s.source_files         = "OGCoreDataStack/"
  s.private_header_files = "OGCoreDataStack/*Private.h"
  s.framework            = "CoreData"
  s.requires_arc         = true
end
