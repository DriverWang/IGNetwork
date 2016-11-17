Pod::Spec.new do |s|  
  s.name             = "IGNetwork"  
  s.version          = "1.2.1"  
 s.summary      = " iGluco "

  s.homepage         = "https://github.com/DriverWang/IGNetwork"  
  s.license          = 'MIT'  
  s.author           = { "YC" => "wangyucheng@ihealthlabs.com.cn" }  
  s.source           = { :git => "https://github.com/DriverWang/IGNetwork.git", :tag => "1.2.1"   }  
  
  s.platform     = :ios, '7.0'  
 
  s.requires_arc = true  
  
  s.source_files = 'IGNetWorkDemo/IGNetWork/*'  
  s.dependency "AFNetworking"

  
end  
