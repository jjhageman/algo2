require 'debugger'
require 'csv'
require 'progressbar'

class City
  attr :x, :y, :id

  def initialize(id,x,y)
    @id = id
    @x = x
    @y = y
  end
end

class Tsp
  attr :cities, :A, :D

  def initialize(file)
    @file = file
    @cities = []
    @A = {}
    @D = {}
    read_data
    compute_distances
  end

  def read_data
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :float)
    @num_cities = csv.shift.first.to_i
    csv.each.with_index do |row,i|
      @cities << City.new(i+1,*row)
    end
  end

  def compute_distances
    @cities.each do |c1|
      @D[c1.id] = {c1.id => 0}
      (@cities-[c1]).each do |c2|
        d = (c1.x-c2.x)**2 + (c1.y-c2.y)**2
        d = Math.sqrt(d)
        @D[c1.id][c2.id] = d
      end
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
    pbar = ProgressBar.new("min cost", @num_cities)
    i = @num_cities-1
    key_counter=Array.new(@num_cities){0}
    prev_a = {}
    (1..i).each do |m|
      first_binary = (('0'*(i-m))+('1'*m)).to_i(2)
      last_binary = (('1'*m)+('0'*(i-m))).to_i(2)
      next_a = {}
      while first_binary <= last_binary do
        ("%0#{i}b"%first_binary).split("").reverse.each.with_index do |c,position|
          if c == '1'
            j = position+1
            s_sub_j = first_binary & ~(1<<position)
            if s_sub_j == 0
              key_counter[m] += 1
              next_a[first_binary] = {(j+1) => @D[1][j+1]}
            else
              min = Float::INFINITY
              ("%0#{i}b"%s_sub_j).split("").reverse.each.with_index do |s,p|
                if s == '1'
                  k = p+1
                  temp = (k == 1) ? Float::INFINITY : (prev_a[s_sub_j][k+1] + @D[k+1][j+1])
                  debugger unless temp
                  min = temp if temp < min
                end
              end
              if next_a[first_binary]
                next_a[first_binary][j+1] = min
              else
                key_counter[m] += 1
                next_a[first_binary] = {(j+1) => min}
              end
            end
          end
        end
        first_binary = next_pattern first_binary
      end
      prev_a.clear
      prev_a = next_a.dup
      pbar.inc
    end
    pbar.finish

    min = Float::INFINITY
    n_index = ('1'*i).to_i(2)
    (2..@num_cities).each do |j|
      temp = prev_a[n_index][j] + @D[1][j]
      min = temp if temp < min
    end
    min
  end
end
mc = Tsp.new('test1.txt').min_cost
puts "Min travel cost: #{mc}"
puts 'Done.'
