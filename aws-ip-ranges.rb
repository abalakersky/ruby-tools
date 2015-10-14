#!/usr/bin/env ruby

# Copyright (c) 10/14/2015
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'open-uri'
require 'json'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-h', '--help', 'Usage') { |o| options.help = o}
  opt.on('-r', '--region REGION', 'AWS Region') { |o| options.region = o }
  opt.on('-s', '--service SERVICE', 'AWS Service') { |o| options.service = o }
end.parse!

USAGE = <<ENDUSAGE

This script is used to display AWS specific IP ranges that could be used for Firewall or Security Group configurations. These ranges specify public IPs that AWS uses for a specific service.

Usage:
   ruby aws-ip-ranges.rb [-h] [-r region] -s service

    Service:
      Valid values: AMAZON | EC2 | CLOUDFRONT | ROUTE53 | ROUTE53_HEALTHCHECKS

    Region:
      Valid values: ap-northeast-1 | ap-southeast-1 | ap-southeast-2 | cn-north-1 | eu-central-1 | eu-west-1 | sa-east-1 | us-east-1 | us-gov-west-1 | us-west-1 | us-west-2 | GLOBAL

    Notes:
      Please remember that some services, such as CloudFront and Route53 are Global and as such use only GLOBAL as their region. Their information can be gathered with or without specifying region name
ENDUSAGE

ipranges_file = JSON.parse(open("https://ip-ranges.amazonaws.com/ip-ranges.json").read)

case
  when options.help || (!options.help && !options.region && !options.service)
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

