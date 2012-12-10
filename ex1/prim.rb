require 'debugger'

class Prim
  def initialize(file)
    @file = file    
    @graph = {}
    @t=0    
    @x=[]
    @v=[]
  end
end
