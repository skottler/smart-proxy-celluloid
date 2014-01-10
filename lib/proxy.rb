$:.unshift File.join(File.dirname(__FILE__), "..", "lib/")

module Proxy
  MODULES = %w{dns}
  VERSION = "1.3-poc"

  # This is really ugly and needs refactoring, but it works fine for now and
  # global feature def is okay since it won't change after initial load.
  $features = []

  require 'settings'
  ::SETTINGS = Settings.load_from_file

  require 'celluloid/autostart'
  require 'fileutils'
  require 'pathname'
  require 'log'
  require 'util'
  require 'either'
  require 'active_support/inflector'


  Dir.foreach("#{File.dirname(__FILE__)}") do |feature|
    # Dir#foreach includes the current and parent dir, so just skip them.
    next if feature == '.' or feature == '..'
    if File.exist?("#{File.dirname(__FILE__)}/#{feature}/#{feature}.rb")
      begin
        require "#{File.dirname(__FILE__)}/#{feature}/#{feature}.rb"
        $features << feature
      rescue LoadError
        # Just don't load the feature if it doesn't have a proper definition,
        # although this should ultimately be some kind of warning.
      end
    end
  end

  class ProxySupervisor < ::Celluloid::SupervisionGroup
    $features.each do |feature|
      klass = "SmartProxy::#{feature.capitalize}Actor".constantize
      supervise klass, as: feature.to_sym if SETTINGS.feature
    end
  end
  ProxySupervisor.run!

  def self.version
    {:version => VERSION}
  end
end
