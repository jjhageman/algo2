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
  attr :edges, :points

  def initialize(file)
    @file = file
    @size = 0
    @edges = []
    @points = Set.new
    populate
  end
  
  def populate
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @size = csv.shift
    csv.each do |row|
      @points.add(row[0])
      @points.add(row[1])
      @edges << Edge.new(*row)
    end
  end
end

class Cluster
  attr :points
  
  def initialize(points)
    @points = Set.new points
  end
end

class MaxSpacing
  attr :graph, :clusters, :sorted_edges

  def initialize(file)
    @file = file
    @clusters = []
    @graph = Graph.new(file)
    @sorted_edges = @graph.edges.sort_by{|e| e.distance}
    init_clusters
  end

  def init_clusters
    @graph.points.each { |p| @clusters << Cluster.new([p]) }
  end

  def cluster(k)
    while @clusters.size > k do
      edge = @sorted_edges.shift
      merge_clusters edge.p1, edge.p2
    end

    @sorted_edges.each do |e|
      puts e.inspect
      if cluster_connector?(e.p1,e.p2)
        puts "Maximum spacing: #{e.distance}, between #{e.p1} and #{e.p2}"
        puts "#{@clusters}"
        break
      end
    end
    #puts @sorted_edges.first.inspect
  end

  def cluster_connector?(p1,p2)
    c1 = @clusters.detect{|c| c.points.member?(p1)}
    c2 = @clusters.detect{|c| c.points.member?(p2)}
    c1 != c2
  end

  def merge_clusters(p1,p2)
    c1 = @clusters.detect{|c| c.points.member?(p1)}
    c2 = @clusters.detect{|c| c.points.member?(p2)}
    unless c1 == c2
      points = c1.points.merge(c2.points)
      @clusters.delete(c1)
      @clusters.delete(c2)
      c = Cluster.new(points)
      @clusters << c
    end
  end
end

ms=MaxSpacing.new('clustering1.txt')
ms.cluster(4)
puts 'done'
