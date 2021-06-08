#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

data = YAML.load_file('../_data/holc.yml')

page = { 
  'layout'=> 'section',
  'title' => 'Section',
  'show_title' => true,
  'map' => 'yes',
  'section' => 'Section'
}

data.each do |section|
  page['title'] = "Section #{section['id']}: #{section['name']}"
  page['section'] = section['id']

  File.open("../sections/#{section['id']}.md", "w") { |file| file.write(page.to_yaml + "---\n") }

end
