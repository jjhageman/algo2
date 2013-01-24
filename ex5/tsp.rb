require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class City
  attr :x, :y

  def initialize(x,y)
    @x = x
    @y = y
  end
end

class Tsp
  attr :cities, :A, :S

  def initialize(file)
    @file = file
    @cities = []
    read_data
  end

  def read_data
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @num_cities = csv.shift.first
    csv.each do |row|
      @cities << City.new(*row)
    end
  end

  def min_cost
    @A = Array.new(@num_cities) {[0]}
    (2..@num_cities).each do |m|

    end
  end
end
mc = Tsp.new('tsp.txt').min_cost
puts 'Done.'
