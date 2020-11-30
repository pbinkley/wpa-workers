#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'csv'
require 'yaml'
require 'byebug'

list_dimensions = [
  { x: 505, y1: 633, y2: 1156, rows: 13 },
  { x: 510, y1: 130, y2: 1255, rows: 28 }
]

width = 505 - 127
overlap = 0

item_signatures = {}
page_num = 1
row_offset = 0

workers = CSV.parse(File.read('../_data/workers.csv'), headers: true)

list_dimensions.each do |page|
  height = (page[:y2] - page[:y1]) / page[:rows]
  signatures = {}

  (1..page[:rows]).each do |row|
    y = (page[:y1] + ((row - 1) * height)).round

    col1_x = page[:x] - width
    col2_x = page[:x]

    worker = workers.find {|worker| worker['id'] == (row + row_offset).to_s}

    signatures[row + row_offset] = [worker['signature'], col1_x, y, width, height + overlap]
    col2_id = row + row_offset + page[:rows]
    if col2_id <= 73
      worker = workers.find {|worker| worker['id'] == col2_id.to_s}
      signatures[col2_id] = [worker['signature'], col2_x, y, width, height + overlap] 
    end
  end
  item_signatures[page_num] = signatures.sort_by { |e| e.first }

  resources = []
  item_signatures[page_num].each do |signature|
    worker = workers.find {|worker| worker['id'] == signature.first.to_s}
    resources << {
      'xywh' => signature[1][1..4].join(','),
      'chars' => "<h4>#{signature.first}: #{signature[1][0]}</h4><p><em>Census Data</em>: occupation: '#{worker['occupation_28']}'; industry: '#{worker['industry_29']}'</p>"
    }
  end

  signature_yaml = {
    'uri' => "{{ '/' | absolute_url }}img/derivatives/iiif/annotation/doc9031_#{page_num}.json",
    'collection' => 'documents',
    'canvas' => page_num.to_s,
    'label' => "doc9031_#{page_num}",
    'target' => "{{ '/' | absolute_url }}img/derivatives/iiif/canvas/doc9031_#{page_num}.json",
    'resources' => resources
  }

  File.open("./doc9031_#{page_num}.yaml", 'w') { |file| file.write(signature_yaml.to_yaml) }

  page_num += 1
  row_offset += (page[:rows] * 2)
end

File.write('./output-data.json', JSON.dump(item_signatures))

puts 'done'
