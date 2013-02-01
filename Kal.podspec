Pod::Spec.new do |s|
  s.name         = "Kal"
  s.version      = "1.0.0"
  s.summary      = "A calendar component for the iPhone (the UI is designed to match MobileCal)."
  s.homepage     = "http://www.thepolypeptides.com"
  s.license      = 'MIT'
  s.authors      = { "Keith Lazuka" => "klazuka@gmail.com",
                     "Alexsander Akers" => "a2@pandamonia.us" }
  s.source       = { :git => "https://github.com/a2/Kal.git", :branch => "master" }
  s.platform     = :ios, '5.0'
  s.source_files = 'Kal/*.{h,m}'
  s.resource     = 'Kal/Kal.bundle'
  s.requires_arc = true
end
