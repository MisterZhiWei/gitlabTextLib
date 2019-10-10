Pod::Spec.new do |spec|
  spec.name         = "zhiweiTestLib"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of testLib."
  spec.description  = "testLib"
  spec.homepage     = "http://EXAMPLE/testLib"
  spec.license      = "MIT"
  spec.author       = { "liuzhiwei" => "liuzhiwei1@100tal.com" }
  spec.platform     = :ios, "8.0"
  spec.source       = { :git => "https://github.com/MisterZhiWei/gitlabTextLib.git", :tag => "#{spec.version}" }
  spec.source_files  = "WhiteBoarder/Model/*.{h,m}","WhiteBoarder/Other/*.{h,m}","WhiteBoarder/View/*.{h,m}"

  spec.dependency 'SocketRocket', '~> 0.5.1'
  spec.dependency 'Protobuf', '~> 3.9.0'
  spec.dependency 'YYKit', '~> 1.0.9'
  spec.dependency 'SDWebImage', '~> 4.2.3'

  spec.exclude_files = "WhiteBoarder/Model/SocketMessage.pbobjc.{h,m}"

  spec.subspec 'no-arc' do |sp|
    sp.source_files = "WhiteBoarder/Model/SocketMessage.pbobjc.{h,m}"
    sp.requires_arc = false
    end
end
