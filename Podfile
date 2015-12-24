source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

target 'HelloWorld' do
    xcodeproj 'HelloWorld.xcodeproj'
    link_with ['HelloWorld']
    pod 'POSRx/Utils', :path => './External/POSRx'
end

target 'HelloWorldTests' do
    xcodeproj 'HelloWorld.xcodeproj'
    pod 'POSRx/Utils', :path => './External/POSRx'
    pod 'POSAllocationTracker', :path => './External/POSAllocationTracker'
end
