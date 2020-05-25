
Pod::Spec.new do |spec|

  spec.name         = "CRUILib"
  spec.version      = "0.0.1"
  spec.summary      = "自定义控件"
  spec.description  = "Crazs"
  spec.homepage     = "https://github.com/Crazs/CRUILib"
  spec.license      = "MIT"
  spec.author       = { "Crazs" => "zhouwtzs@163.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/Crazs/CRUILib.git", :tag => "#{spec.version}" }
  
  spec.source_files = "CRHelperLib/*.{h,m}"
  
  spec.subspec 'ScrollBarView' do |ss|
    ss.source_files = "CRUILib/ScrollBarView/*.{h,m}"
  end
  
end
