require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Edge
  attr :u, :v, :w
  def initialize(u,v,w)
    @u = u
    @v = v
    @w = w
  end
end

class BellmanFord
  attr :vertices, :edges, :source, :d
  def initialize(vertices, edges, source)
    @vertices = vertices
    @edges = edges
    @source = source
    @d = []
  end

  def shortest_paths
    # initialize base cases
    @vertices.each {|v| @d[v] = Float::INFINITY}
    @d[@source] = 0

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

class Dijkstra
  attr :graph, :vertices, :edges, :source
  def initialize(graph)
    @graph = graph
    @a={}
    @b={}
  end

  def shortest_path(s)
    @v = @graph.keys.to_set
    @x = Set.new([@v.first])
    @a[@v.first]=0
    @b[@v.first]=[]

    pbar = ProgressBar.new("crawling graph", @v.size)
    until (@v - @x).empty?
      min_len=1000000
      min_edge=[]
      @x.each do |v|
        debugger if @graph[v].nil?
        @graph[v].each do |n|
          next unless (@v-@x).include?(n[0])
          if (@a[v]+n[1]) < min_len
            min_len = @a[v]+n[1]
            min_edge = [v,n[0]]
          end
        end
      end

      @x << min_edge[1]
      pbar.inc
      @a[min_edge[1]]=min_len
      @b[min_edge[1]]=@b[min_edge[0]]|min_edge
    end
    pbar.finish
    @a
  end
end

class Johnson
  def initialize(file)
    @file = file
    @edges = []
    @vertices = Set.new
    @graph = {}
    @relaxed_graph = {}
    @c = [0]
    read_file
  end
  
  def add_or_append(u,v,w)
    if @graph.has_key?(u)
      @graph[u][v] = w
    else
      @graph[u] = {v => w}
    end
  end

  def read_file
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @num_vertices, @num_edges = csv.shift
    pbar = ProgressBar.new("reading file", @num_edges)
    csv.each do |row|
      @vertices << row[0]
      @vertices << row[1]
      @edges << Edge.new(*row)
      add_or_append(*row)
      pbar.inc
    end
    pbar.finish
  end

  def shortest_paths
    s = 0
    @gprime_vertices = @vertices.dup.add(s)
    @gprime_edges = @edges.dup
    @vertices.each do |v|
      @gprime_edges << Edge.new(s,v,0)
    end
    sp = BellmanFord.new(@gprime_vertices, @gprime_edges, s).shortest_paths
    #@edges.each do |e|
      #@c << e.w + sp[e.u] - sp[e.v]
    #end
    @graph.each do |u, edges|
      @relaxed_graph[u] = {}
      edges.each do |v,w|
        @relaxed_graph[u][v] = w + sp[u] - sp[v]
      end
    end
    d = Dijkstra.new(@relaxed_graph)
    @D = Array.new(@vertices.size+1) {[0]}
    @vertices.each do |u|
      sh = d.shortest_path(u)
      sh.each do |v,w|
        debugger unless @D[u]
        @D[u][v] = w - sp[u] + sp[v]
      end
    end
    @D
  end
end

j=Johnson.new('test2.txt').shortest_paths
debugger
puts 'Done.'
