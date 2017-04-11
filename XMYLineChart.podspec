Pod::Spec.new do |s|
  s.name         = "XMYLineChart"
  s.version      = "0.0.3"
  s.summary      = "Can be customized line chart"
  s.homepage     = "https://github.com/xumoyan/XMYLineChart"
  s.license      = "MIT"
  s.author       = { "xumoyan" => "13391572563@163.com" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/xumoyan/XMYLineChart.git", :tag => s.version.to_s }
  s.source_files  = 'XMYLineChart/*.{h,m}'
end
