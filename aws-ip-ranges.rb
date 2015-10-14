#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
OptionParser.new do |opt|
  # opt.banner = "Usage: ruby aws-ip-ranges.rb -r region name "
  opt.on('-h', '--help', 'Usage') { |o| options.help = o}
  opt.on('-r', '--region REGION', 'AWS Region') { |o| options.region = o }
  opt.on('-s', '--service SERVICE', 'AWS Service') { |o| options.service = o }
end.parse!

USAGE = <<ENDUSAGE

This script is used to collect AWS specific IP ranges that could be used for Firewall or Security Group configurations. These ranges specify public IPs that AWS uses for a specific service.

Usage:
   ruby aws-ip-ranges.rb [-h] [-r region] [-s service]

    Regions:
      Valid values: ap-northeast-1 | ap-southeast-1 | ap-southeast-2 | cn-north-1 | eu-central-1 | eu-west-1 | sa-east-1 | us-east-1 | us-gov-west-1 | us-west-1 | us-west-2 | GLOBAL

    Services:
      Valid values: AMAZON | EC2 | CLOUDFRONT | ROUTE53 | ROUTE53_HEALTHCHECKS

    Notes:
      Please remember that some services, such as CloudFront and Route53 are Global and as such use only GLOBAL as their region. Their information can be gathered with or without specifying region name
ENDUSAGE

if options.help
  puts USAGE
  exit
end

ipranges_file = JSON.parse(open("https://ip-ranges.amazonaws.com/ip-ranges.json").read)

case
  when options.help
    puts USAGE
    exit

  when options.region && options.service
    ipranges_file["prefixes"].each do |k, v|
      puts k["ip_prefix"] if k["region"] == options.region && k["service"] == options.service
    end

  when options.service && !options.region
    ipranges_file["prefixes"].each do |k, v|
      puts k["ip_prefix"] if k["service"] == options.service
    end

  when options.region && !options.service
    puts "Service type is a required option. Please include type of service you are looking for\n"

end
# ipranges_file["prefixes"].each do |k, v|
#   puts k["ip_prefix"] if k["service"] == "CLOUDFRONT"
# end
#
# ipranges_file["prefixes"].each do |k, v|
#   puts "#{k["region"]} #{k["ip_prefix"]}" if k["service"] == "CLOUDFRONT"
# end
#
# ipranges_file["prefixes"].each do |k,v|
#   puts k["ip_prefix"] if k["service"] == "EC2" && k["region"] == "us-west-1"
# end
