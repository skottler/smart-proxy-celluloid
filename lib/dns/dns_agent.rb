require 'either'
require 'settings'

module SmartProxy
  class DnsAgent
    include Celluloid

    def dns_setup(opts)
      raise "Smart Proxy is not configured to support DNS" unless SETTINGS.dns
      case SETTINGS.dns_provider
      when "nsupdate"
        require 'nsupdate'
        Proxy::DNS::Nsupdate.new(opts.merge(
          :server => SETTINGS.dns_server,
          :ttl => SETTINGS.dns_ttl
        ))
      when "nsupdate_gss"
        require 'nsupdate_gss'
        Proxy::DNS::NsupdateGSS.new(opts.merge(
          :server => SETTINGS.dns_server,
          :ttl => SETTINGS.dns_ttl,
          :tsig_keytab => SETTINGS.dns_tsig_keytab,
          :tsig_principal => SETTINGS.dns_tsig_principal
        ))
      else
        raise "Unrecognized or missing DNS provider: #{SETTINGS.dns_provider || "MISSING"}"
      end
    end

    def new_record(fqdn, value, type)
      server = dns_setup({:fqdn => fqdn, :value => value, :type => type})
      Either.try {server.create}
    rescue Exception => e
      Failure(e)
    end

    def delete_record(val)
      case val
      when /\.(in-addr|ip6)\.arpa$/
        type = "PTR"
        value = val
      else
        fqdn = val
      end
      server = dns_setup({:fqdn => fqdn, :value => value, :type => type})
      Either.try {server.remove}
    rescue => e
      Failure(e)
    end
  end
end