require 'debugger'
require 'csv'
require 'progressbar'

class Mwis
  attr :V, :S, :P, :size
  def initialize(file)
    @file = file
    @S = []
    @P = []
    read_data
  end

  def read_data
    @V = CSV.read(@file, col_sep: ' ', converters: :integer)
    @size = @V.size
    @V.unshift([0, 0])
  end

  def max_weight
    @S[0] = @V[0].last
    @S[1] = @V[1].last
    (2..@size).each do |i|
      s1 = @S[i-1]
      s2 = @S[i-2] + @V[i].last
      @S[i] = s1 > s2 ? s1 : s2
    end
    @S.last
  end

  def max_path
    i = @size
    while i >= 1 do
      if @S[i-1] >= @S[i-2] + @V[i].last
        i -= 1
      else
        @P << @V[i].first
        i -= 2
      end
    end
    @P
  end
end

m = Mwis.new('mwis1.txt')
puts "Max Weight: #{m.max_weight}"
puts "Path: #{m.V[1..-1]}"
debugger
puts "Max Weight Path: #{m.max_path.sort}"
