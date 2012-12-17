require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Edge
  attr :p1, :p2, :distance
  def initialize(p1,p2,distance)
    @p1 = p1
    @p2 = p2
    @distance = distance
  end
end

class Graph
  attr :edges

  def initialize(file)
    @file = file
    @size = 0
    @edges = []
    populate
  end
  
  def populate
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @size = csv.shift
    csv.each do |row|
      @edges << Edge.new(*row)
    end
  end
end

class Cluster
  attr :points
  
  def initialize(point)
    @points = Set.new(point)
  end
end

class MaxSpacing
  attr :graph

  def initialize(file)
    @file = file
    @clusters = []
    @graph = Graph.new(file)
    @sorted_edges = @graph.edges.sort_by{|e| e.distance}
  end
end

ms=MaxSpacing.new('clustering1.txt')
puts 'done'
