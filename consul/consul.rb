#!/usr/bin/env ruby

# -----------------------------------------------------------------------------
# Simple client for the Consul HTTP API
# Just require 'consul' (well here, require_relative 'consul')
# Then c = Consul.new, and c.setkey('test','somevalue'), puts c.getkey('test')
# -----------------------------------------------------------------------------
require 'curb'
require 'inifile'
require 'json'
require 'base64'
# -----------------------------------------------------------------------------

class Consul
  attr_accessor :baseurl

  def initialize(url = 'http://localhost:8500/v1/kv/')
    @baseurl = url
  end

# -----------------------------------------------------------------------------
# K/V stuff
# -----------------------------------------------------------------------------
  def getkey(k)
    begin
      http = Curl.get(@baseurl + k + '?raw')
      return http.response_code == 200 ? http.body_str : nil
    rescue Exception => e
      puts e.inspect
      return nil
    end
  end

  def setkey(k,v)
    begin
      http = Curl::Easy.new(@baseurl + k).http_put(v)
      return (http == 'true')
    rescue Exception => e
      puts e.inspect
      return false
    end
  end

  def getkeys(kpattern)
    begin
      http = Curl.get(@baseurl + kpattern + '?recurse')
      return nil if http.body_str == ''
      kdataar = JSON.parse(http.body_str)
      kret = {}
      kdataar.each do |kdata|
        kret[kdata['Key']] = Base64.decode64(kdata['Value'])
      end
      return kret
    rescue Exception => e
      puts e.inspect
      return nil
    end
  end
end
# -----------------------------------------------------------------------------

