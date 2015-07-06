require 'erb'


task :api_plist do
  templ = File.read('ApiKeys.plist.erb')
  erb = ERB.new(templ)
  apikey = ENV["PLACES_API_KEY"]

  File.open("ApiKeys.plist", "w") do |f|
  	f.puts erb.result(binding)
  end
end

task :default => 'api_plist'
