require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Knapsack
  # W: Knapsack capacity
  attr :W, :V
  def initialize(file)
    @file = file
    @w = [0]
    @v = [0]
    @V = {}
    read_data
  end

  def optimal
    pbar = ProgressBar.new("optimizing", @size)

    (1..@size).each do |i|
      weight = @w[i]
      value = @v[i]
      new_weights = {}
      @V.each do |k,v|
        combo_weight = weight + k
        v.each do |j|
          new_weights[combo_weight] = [(value + j)] unless combo_weight > @W
        end
      end
      debugger if new_weights.nil?
      @V.merge!(new_weights){|key, oldval, newval| oldval+newval} unless new_weights.nil?
      if @V[weight]
        @V[weight] << value
      else
        @V[weight] = [value]
      end
      pbar.inc
    end 
    pbar.finish
    @V
  end

  def read_data
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @W, @size = csv.shift
    pbar = ProgressBar.new("reading file", @size)
    csv.each do |row|
      @v << row[0]
      @w << row[1]
      pbar.inc
    end
    pbar.finish
  end
end

k=Knapsack.new('knapsack2.txt').optimal
debugger
highest_weight = k.keys.sort.last
puts "Heightest weight = #{highest_weight}"
puts "2595819 - Optimal solution #{k[highest_weight].sort.last}"
