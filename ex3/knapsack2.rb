require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Knapsack
  # W: Knapsack capacity
  attr :W1, :W2, :V, :items
  def initialize(file)
    @file = file
    @w = [0]
    @v = [0]
    @items = []
    @V1 = [[]]
    @V2 = [[]]
    @P = [[]]
    read_data
  end

  def optimal
    (0..@size).each {|r| @V1[r] = []}
    (0..@size).each {|r| @V2[r] = []}
    (0..@size).each {|r| @P[r] = []}
    (0..@W1).each {|w| @V1[0][w]=0}
    (0..@W1).each {|w| @P[0][w]=0}
    (0..@W2).each {|w| @V2[0][w]=0}

    pbar = ProgressBar.new("optimizing", @items.size)
    (1..@items.size).each do |i|
      (0..@W1).each do |j|
        if @w[i] <= j
          p = @V1[i-1][j]
          n = @V1[i-1][j-@w[i]]+@v[i]
          if p > n
            @V1[i][j] = p
            @P[i][j] = -1
          else
            @V1[i][j] = n
            @P[i][j] = 1
          end
        else
          @P[i][j] = -1
          @V1[i][j] = @V1[i-1][j]
        end
      end
      pbar.inc
    end 
    pbar.finish

    puts "Sack 1: #{@V1[@size][@W1]}"

    i = @items.size
    w = @W1
    z = []
    while i > 0 do
      if @P[i][w] == 1
        #@items.delete_at(i-1)
        puts @items[i-1]
        z << i
        w -= @w[i]
        i -= 1
      else
        i -= 1
      end
    end
    puts "Sack 1 items: #{z.join(', ')}"
    #puts "Sack 1 items: #{@P}"
    puts "Remaining items: #{@items}"



  end

  def read_data
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @W1, @W2 = csv.shift
    @size = 0
    pbar = ProgressBar.new("reading file", @size)
    csv.each do |row|
      @v << row[0]
      @w << row[1]
      @items << row
      @size += 1
      pbar.inc
    end
    pbar.finish
  end
end

k=Knapsack.new('double_sack2.txt').optimal
#puts "Optimal solution #{k}"
