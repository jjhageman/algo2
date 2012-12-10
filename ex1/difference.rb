require 'csv'
require 'debugger'

class Difference
  def initialize(file)
    @file = file    
    @jobs={}
  end

  def run
    CSV.foreach(@file, :col_sep => "\t", :row_sep => "\t\r\n") do |row|
     row 
    end    
  end
end
