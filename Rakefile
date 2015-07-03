require 'plist'
task :api_plist do
  keys = [{'PLACES' => ENV["PLACES_API_KEY"]}]
  puts keys.to_plist
  puts "Building API PList"
end

task :default => 'api_plist'
