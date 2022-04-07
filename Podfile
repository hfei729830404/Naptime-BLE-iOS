#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
#source 'https://github.com/EnterTech/PodSpecs.git'

platform :ios, '11.0'
use_frameworks!
 
target 'BLETool' do

    pod 'FixedDFUService', '~> 4.11.2'
    pod 'SnapKit'
    pod 'SVProgressHUD'
    # pod 'RxSwift', '~> 6.0'
    # pod 'RxCocoa', '~> 6.0'
    pod 'SwiftyTimer'
    pod 'Files'
    pod 'NaptimeFileProtocol', :git => "git@github.com:EnterTech/Naptime-FileProtocol-iOS.git", :branch => "develop"
end

target 'NaptimeBLE' do
    # pod 'PromiseKit'
    # pod 'RxBluetoothKit'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['iOSDFULibrary'].include? "#{target}"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end

