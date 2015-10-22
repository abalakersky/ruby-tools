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

# Amazon IP Ranges file url. Change it to current one if Amazon moves it.
url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
ipranges_file = JSON.parse(open(url).read)

# Collect options from command line
options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-h', '--help', 'Usage') { |o| options.help = o}
  opt.on('-r', '--region REGION', 'AWS Region') { |o| options.region = o }
  opt.on('-s', '--service SERVICE', 'AWS Service') { |o| options.service = o }
end.parse!

# Create lists of available regions and services
$service, $region = [], []
ipranges_file["prefixes"].each do |k|
  $service.push(k["service"])
  $region.push(k["region"])
end
$service.uniq!.sort!.compact!
$region.uniq!.sort!.compact!
services = $service.join(' | ')
regions = $region.join(' | ')

# Help and Usage text.
USAGE = <<ENDUSAGE

This script is used to display AWS specific IP ranges that could be used for Firewall or Security Group configurations. These ranges specify public IPs that AWS uses for a each public facing service.

Usage:
   ruby aws-ip-ranges.rb [-h] [-r region] -s service

    Service:
      Valid values: #{services}

    Region:
      Valid values: #{regions}

    Notes:
      Please remember that some services, such as CloudFront and Route53 are Global and as such use only GLOBAL as their region. Their information can be gathered with or without specifying region name
ENDUSAGE

# The actual work happens here.
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

