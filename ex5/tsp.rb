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

  def next_pattern pattern
    temp = (pattern | (pattern - 1)) + 1;
    temp | ((((temp & -temp) / (pattern & -pattern)) >> 1) - 1);
  end

  def indexes(bstr)
    indexes = []
    bstr.each_char.with_index do |b, position|
      indexes << position+1 if b == '1'
    end
    indexes
  end

  def min_cost
    @A = Array.new(@num_cities) {[0]}
    pbar = ProgressBar.new("min cost", @num_cities)
    (2..@num_cities).each do |m|
      first_binary = (('0'*(24-m))+('1'*m)).to_i(2)
      last_binary = (('1'*m)+('0'*(24-m))).to_i(2)
      while first_binary <= last_binary do
        ('%023b'%first_binary).split("").reverse.each.with_index do |c,position|
          if c == '1'
            j = position+1
            s_sub_j = first_binary & ~(1<<position)
            min = Float::INFINITY
            ('%023b'%s_sub_j).split("").reverse.each.with_index do |s,p|
              if s == '1'
                k = s+1
                temp = (k == 1) ? Float::INFINITY : (@A[s_sub_j][k] )#+ dist(k,j))
                debugger unless temp
                min = temp if temp < min
              end
            end
            debugger unless  @A[first_binary]
            @A[first_binary][j] = min
          end
        end
        first_binary = next_pattern first_binary
      end
      pbar.inc
    end
    pbar.finish
  end
end
mc = Tsp.new('tsp.txt').min_cost
puts 'Done.'
