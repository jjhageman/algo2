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

class FloydWarshall
  def initialize(file)
    @graph = Graph.new(file)
    @A = Array.new(@graph.num_vertices+1) {Array.new(@graph.num_vertices+1){[0]}}
  end

  def shortest_paths
    # initialize base cases
    pbar = ProgressBar.new("initializing base cases", @graph.num_vertices)
    (1..@graph.num_vertices).each do |i|
      (1..@graph.num_vertices).each do |j|
        @A[i][j][0] = if i == j
          0
        elsif @graph.E[i] && @graph.E[i].has_key?(j)
          @graph.E[i][j]
        else
          Float::INFINITY
        end
      end
      pbar.inc
    end
    pbar.finish

    pbar2 = ProgressBar.new("paths", @graph.num_vertices)
    (1..@graph.num_vertices).each do |k|
      (1..@graph.num_vertices).each do |i|
        (1..@graph.num_vertices).each do |j|
          a = @A[i][j][k-1]
          b = @A[i][k][k-1] + @A[k][j][k-1]
          @A[i][j][k] = (a<b) ? a : b
        end
      end
      pbar2.inc
    end
    pbar2.finish
    @A
  end
end

fw = FloydWarshall.new('test2.txt').shortest_paths
debugger
puts 'Done'
