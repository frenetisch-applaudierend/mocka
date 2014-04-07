workspace 'Mocka'
xcodeproj 'Mocka.xcodeproj'
xcodeproj 'Examples/Examples.xcodeproj'

inhibit_all_warnings!


# Mocka.xcodeproj

target "mocka-tests-ios" do
  xcodeproj 'Mocka.xcodeproj'
  platform :ios, '7.0'
  
  pod 'OCMockito'
  pod 'OHHTTPStubs'
  pod 'Expecta'
  pod 'KNMParametrizedTests'
end

target "mocka-tests-osx" do
  xcodeproj 'Mocka.xcodeproj'
  platform :osx, '10.9'
  
  pod 'OCMockito'
  pod 'OHHTTPStubs'
  pod 'Expecta'
  pod 'KNMParametrizedTests'
end


# Examples.xcodeproj

target "examples-tests-ios" do
  xcodeproj 'Examples/Examples.xcodeproj'
  platform :ios, '7.0'
  
  pod 'OHHTTPStubs'
  pod 'Expecta'
  pod 'KNMParametrizedTests'
end

target "examples-tests-osx" do
  xcodeproj 'Examples/Examples.xcodeproj'
  platform :osx, '10.9'
  
  pod 'OHHTTPStubs'
  pod 'Expecta'
  pod 'KNMParametrizedTests'
end
