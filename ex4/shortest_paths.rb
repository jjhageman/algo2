require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Vertice
  attr :predecessor, :d, :name
  def initialize(n)
    @name = n
  end
end
 
class Edge
  attr :u, :v, :w
  def initialize(u,v,w)
    @u = u
    @v = v
    @w = w
  end
  
end

class Graph
  attr :E, :E_by_tail, :V, :num_vertices, :num_edges

  def initialize(file)
    @file = file
    @E = {}
    @E_by_tail = {}
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

    if @E_by_tail.has_key?(v)
      @E_by_tail[v][u] = weight
    else
      @E_by_tail[v] = {u => weight}
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

class BellmanFord
  attr :edges, :A
  def initialize(file)
    @file = file
    @edges = []
    @vertices = Set.new
    @d = []
    read_data
  end

  def read_data
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @num_vertices, @num_edges = csv.shift
    pbar = ProgressBar.new("reading file", @num_edges)
    csv.each do |row|
      @vertices << row[0]
      @vertices << row[1]
      @edges << Edge.new(*row)
      pbar.inc
    end
    pbar.finish
  end

  def shortest_paths(source)
    # initialize base cases
    @vertices.each {|v| @d[v] = Float::INFINITY}
    @d[source] = 0

    pbar = ProgressBar.new("relaxing edges", @vertices.size-1)
    (1..@vertices.size-1).each do |i|
      @edges.each do |e|
        @d[e.v] = @d[e.u] + e.w if (@d[e.v] > (@d[e.u] + e.w))
      end
      pbar.inc
    end
    pbar.finish
    negative_cycles? ? false : @d
  end

  def negative_cycles?
    response = false
    @edges.each do |e|
      if @d[e.v] > (@d[e.u] + e.w)
        response = true
        break
      end
    end
    response
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

class Johnson
  def initialize(file)
    @file = file
    @edges = []
    @vertices = Set.new
    read_file
  end

  def read_file
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @num_vertices, @num_edges = csv.shift
    pbar = ProgressBar.new("reading file", @num_edges)
    csv.each do |row|
      @vertices << row[0]
      @vertices << row[1]
      @edges << Edge.new(*row)
      pbar.inc
    end
    pbar.finish
  end

  def shortest_paths
    @gprime_vertices = @vertices.dup.add(9999)
    @gprime_edges = @edges.dup
    @vertices.each do |v|
      @gprime_edges = Edge.new(v,9999,0)
    end
  end
end
#fw = FloydWarshall.new('test2.txt').shortest_paths
#bf = BellmanFord.new('g3.txt').shortest_paths(1)
Johnson.new('test1.txt').shortest_path
puts 'Done.'
