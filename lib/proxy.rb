$:.unshift File.join(File.dirname(__FILE__), "..", "lib/")

module Proxy
  MODULES = %w{dns}
  VERSION = "1.3-poc"

  require "settings"
  ::SETTINGS = Settings.load_from_file

  require 'celluloid/autostart'
  require "fileutils"
  require "pathname"
  require "log"
  require "util"
  require "dns/dns"         if SETTINGS.dns
  require "either"

  class ProxySupervisor < ::Celluloid::SupervisionGroup
    supervise SmartProxy::DnsActor, as: :dns if SETTINGS.dns
  end
  ProxySupervisor.run!

  def self.version
    {:version => VERSION}
  end
end
