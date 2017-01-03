#!/usr/bin/env ruby

require 'json_converter'

json_converter = JsonConverter.new

json = File.open("/home/abalakersky/Downloads/tmp/instances.json")
csv = json_converter.generate_csv json
json_converter.write_to_csv json, 'output.csv'
