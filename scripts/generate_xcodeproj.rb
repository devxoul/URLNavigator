require "xcodeproj"

def run(command)
  puts command
  r = `#{command} 2>&1`.strip
  puts r if r and r.length > 0
  return r
end

def generate_xcodeproj()
  run("swift package generate-xcodeproj --enable-code-coverage #{ARGV.join(" ")}")
end

def add_xctest()
  project = Xcodeproj::Project.open("URLNavigator.xcodeproj") or return
  target = project.targets.find { |t| t.name == "QuickSpecBase" } or return
  phase = target.build_phases.find { |p|
    p.kind_of?(Xcodeproj::Project::Object::PBXFrameworksBuildPhase)
  } or return
  path = "Platforms/iPhoneOS.platform/Developer/Library/Frameworks/XCTest.framework"
  file = project.new_file(path)
  phase.add_file_reference(file)
  project.save
end

generate_xcodeproj()
add_xctest()
