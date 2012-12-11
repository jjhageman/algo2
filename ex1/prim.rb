require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Vertex
  attr :node, :edges
  def initialize(node)
    @node = node
  end
end
class Edge
  attr :vertex
  def initialize(vertex)
    @vertex = vertex
  end
end

class Prim
  def initialize(file)
    @file = file    
    @graph = {}
    @size=0
    @t = 0 #overall span cost
    @v = Set.new #graph nodes
    @x = Set.new #MST nodes
    initialize_graph
  end

  def initialize_graph
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @size = csv.shift
    csv.each do |row|
      add_or_append(*row)
    end
    @x.add @v.to_a.sample
  end

  def add_or_append(base_node, auxiliary_node, edge_cost)
    @v.add base_node
    @v.add auxiliary_node
    if @graph.has_key?(base_node)
      @graph[base_node][auxiliary_node] = edge_cost
    else
      @graph[base_node] = {auxiliary_node => edge_cost}
    end

    if @graph.has_key?(auxiliary_node)
      @graph[auxiliary_node][base_node] = edge_cost
    else
      @graph[auxiliary_node] = {base_node => edge_cost}
    end
  end

  def cheapest_edge_node(auxiliary_nodes)
    unexplored_edges(auxiliary_nodes).min_by{|e| e[1]}
  end

  def unexplored_edges(auxiliary_nodes)
    frontier = unexplored_nodes(auxiliary_nodes)
    auxiliary_nodes.select{|k,v| frontier.include?(k)}
  end

  def unexplored_nodes(auxiliary_nodes)
    ((@v-@x) & auxiliary_nodes.keys.to_set)
  end

  def contains_unexplored_nodes?(auxiliary_nodes)
    !!auxiliary_nodes && !unexplored_nodes(auxiliary_nodes).empty?
  end

  def run
    pbar = ProgressBar.new("spanning graph", @size[0])
    until @v == @x
      cheapest_node = {}
      @x.each do |x|
        node = @graph[x]
        next unless contains_unexplored_nodes? node
        e = cheapest_edge_node node
        debugger unless e
        cheapest_node = e if cheapest_node.empty? || e[1] < cheapest_node[1]
      end
        pbar.inc
        @t += cheapest_node[1]
        #puts "discovered: #{cheapest_node[0]}"
        #puts "explored size: #{@x.size}"
        @x.add cheapest_node[0]
    end
    pbar.finish
    puts "overall minimum span cost: #{@t}"
  end
end
Prim.new('prim_test.txt').run
