#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'ap'

buffer = open("https://ip-ranges.amazonaws.com/ip-ranges.json").read
result = JSON.parse(buffer)


result["prefixes"].each do |k, v|
  puts k["ip_prefix"] if k["service"] == "CLOUDFRONT"
end

result["prefixes"].each do |k, v|
  ap "#{k["region"]} #{k["ip_prefix"]}" if k["service"] == "CLOUDFRONT"
end

result["prefixes"].each do |k,v|
  ap k["ip_prefix"] if k["service"] == "EC2" && k["region"] == "us-west-1"
end
