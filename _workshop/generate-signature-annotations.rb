#!/usr/bin/env ruby

require 'byebug'

centrePoint = [{ x: 505, y: 633 }, { x: 510, y: 130 }]
width = 505 - 127
height = 676 - 633
overlap = 15
rows = [13, 28]

signatures = {}

(1..rows).each do |row|
  y = centrePoint[:y] + ((row - 1) * height)

  col1_x = centrePoint[:x] - width
  col2_x = centrePoint[:x]

  signatures[row] = [col1_x, y, width, height + overlap]
  signatures[row + rows] = [col2_x, y, width, height + overlap]
end

byebug

puts 'done'
