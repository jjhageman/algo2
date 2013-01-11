require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Knapsack
  # W: Knapsack capacity
  attr :W, :V, :items
  def initialize(file)
    @file = file
    @w = [0]
    @v = [0]
    @items = []
    @V = [[]]
    read_data
  end

  def optimal
    (0..@size).each {|r| @V[r] = []}
    (0..@W).each {|w| @V[0][w]=0}

    pbar = ProgressBar.new("optimizing", @items.size)
    (0..@W).each do |j|
      (1..@items.size).each do |i|
        if @w[i] <= j
          p = @V[i-1][j]
          n = @V[i-1][j-@w[i]]+@v[i]
          @V[i][j] = (p > n) ? p : n
        else
          @V[i][j] = @V[i-1][j]
        end
      end
      pbar.inc
    end 
    pbar.finish
    @V[@size][@W]
  end

  def read_data
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @W, @size = csv.shift
    pbar = ProgressBar.new("reading file", @size)
    csv.each do |row|
      @v << row[0]
      @w << row[1]
      @items << row
      pbar.inc
    end
    pbar.finish
  end
end

k=Knapsack.new('knapsack1.txt').optimal
puts "Optimal solution #{k}"
