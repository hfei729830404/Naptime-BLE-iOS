#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
#source 'https://github.com/EnterTech/PodSpecs.git'

platform :ios, '9.0'
use_frameworks!

target 'BLETool' do

    pod 'iOSDFULibrary', :git => "https://github.com/Entertech/IOS-Pods-DFU-Library.git" , :branch => "innerpeace"
    pod 'SnapKit'
    pod 'SVProgressHUD'
    pod 'RxSwift', '5.1.1'
    pod 'RxCocoa', '5.1.1'
    pod 'SwiftyTimer'
    pod 'Files'
    pod 'NaptimeFileProtocol', :git => "git@github.com:EnterTech/Naptime-FileProtocol-iOS.git", :branch => "develop"
    pod 'PromiseKit'
    pod 'RxBluetoothKit'
end

target 'NaptimeBLE' do
    pod 'PromiseKit'
    pod 'RxBluetoothKit'
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

