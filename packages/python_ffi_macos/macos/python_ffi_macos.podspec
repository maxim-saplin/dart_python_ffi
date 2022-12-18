#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint python_ffi_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'python_ffi_macos'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'

  s.platform = :osx, '10.11'
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.xcconfig = {
     # here on LDFLAG, I had to set -l and then the library name (without lib prefix although the file name has it).
     # 'OTHER_LDFLAGS' => '-llibpython3.11',
  }
  # s.vendored_xcframeworks = 'python/libpython3.11.xcframework'
end