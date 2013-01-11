require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Graph
  attr :E, :V, :num_vertices, :num_edges

  def initialize(file)
    @file = file
    @E = {}
    @V = Set.new
    populate
  end

  def add_or_append(u,v,weight)
    @V << u
    @V << v
    if @E.has_key?(u)
      @E[u][v] = weight
    else
      @E[u] = {v => weight}
    end
  end

  def populate
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @num_vertices, @num_edges = csv.shift
    pbar = ProgressBar.new("reading file", @num_edges)
    csv.each do |row|
      add_or_append(*row)
      pbar.inc
    end
    pbar.finish
  end
end

class Bf
  attr :graph, :A
  def initialize(file)
    @graph = Graph.new(file)
    @A = Array.new(@graph.num_vertices) { [] }
  end

  def shortest_paths(source)
    # initialize base cases
    @graph.V.each do |v|
      @A[0][source] = 0
      @A[0][v] = Float::INFINITY
    end

    pbar = ProgressBar.new("relaxing edges", @graph.E.size-1)
    (1..@graph.E.size-1).each do |i|
      @graph.E.each do |v,edges|
        debugger
        a=@A[i-1][v]
        w,c_wv = *edges.sort_by{|u,w| w}.first
        b=@A[i-1][w] + c_wv
        @A[i][v] = (a < b) ? a : b
      end
      pbar.inc
    end
    pbar.finish
    @A
  end
end

sp = Bf.new('g1.txt').shortest_paths(1)
debugger
puts 'Done.'
