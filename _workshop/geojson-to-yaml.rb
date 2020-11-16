#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'byebug'

geojson = JSON.parse(File.read('wax-main/OHCleveland1939.geojson'))
yaml = []

geojson['features'].each do |feature|
  properties = feature['properties']
  area = properties['area_description_data']
  yaml << {
    'id' => properties['holc_id'],
    'description' => area['8'],
    'name' => area['9'].sub(/\ (1st|2nd|3rd|4th).*/, ''),
    'class' => area['1b'],
    'nationalities' => area['1c'],
    'blacks' => area['1d']
  }
end

File.open("holc.yml", "w") { |file| file.write(yaml.to_yaml) }
