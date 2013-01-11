require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Bst
  def initialize
    @frequencies = [0.05, 0.4, 0.08, 0.04, 0.1, 0.1, 0.23]
    @A = [[]]
  end

  def opt
    @frequencies.each_with_index do |f,s|
      (1..@frequencies.size).each do |i|
        debugger
        @A
      end
    end
  end
end
bst = Bst.new.opt
