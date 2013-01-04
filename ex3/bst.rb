require 'debugger'

class Bst
  def initialize
    @P = [0,0.05,0.4,0.08,0.04,0.1,0.1,0.23]
    @size = @P.size - 1
    @C = Array.new(@size+2) { [] }
    (1..@size+1).each do |i|
      @C[i][i-1] = 0
    end
    @prob_sum = [0]
    (1..@size).each do |i|
      @prob_sum[i] = @P[i] + @prob_sum[i-1]
      @C[i][i] = @P[i]
    end
  end

  def min_search_time
    (1..@size-1).each do |d|
      (1..@size-d).each do |i|
        j = i + d
        min_cost = Float::INFINITY
        (i..j).each do |m|
          c = @C[i][m-1] + @C[m+1][j] + @prob_sum[j] - @prob_sum[i-1]
          if c < min_cost
            min_cost = c
          end
        end
        @C[i][j] = min_cost
      end
    end
    puts @C[1][@size]
  end
end

Bst.new.min_search_time
