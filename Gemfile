source "https://rubygems.org"

ruby '1.9.3'

Dir["#{File.dirname(__FILE__)}/bundler.d/*.rb"].each do |bundle|
  self.instance_eval(Bundler.read_file(bundle))
end
