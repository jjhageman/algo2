require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Node
  attr_accessor :parent, :rank, :value
 
  def initialize(value)
    @value = value
    @parent = self
    @rank = 0
  end
 
  def union(other)
    self_root = self.find
    other_root = other.find
    if self_root.rank > other_root.rank
      other_root.parent = self_root
    elsif self_root.rank < other_root.rank
      self_root.parent = other_root
    elsif self_root != other_root
      other_root.parent = self_root
      self_root.rank += 1
    end
  end
 
  def find
    if self.parent === self
      self
    else
      self.parent = self.parent.find
    end
  end
end

class Edge
  attr :p1, :p2, :distance
  def initialize(p1,p2,distance)
    @p1 = p1
    @p2 = p2
    @distance = distance
  end
end

class Clustering
  attr :edges, :sorted_edges, :node_index, :clusters, :size

  def initialize(file)
    @file = file
    @size = 0
    @node_index = {}
    @edges = []
    @clusters = []
    init_nodes
    init_edges
    @sorted_edges = @edges.sort_by{|e| e.distance}
  end

  def cluster
    pbar = ProgressBar.new("clustering", @sorted_edges.size)
    @sorted_edges.each do |e|
      unless e.p1.find == e.p2.find
        e.p1.union(e.p2)
        @size -= 1
      end
      pbar.inc
    end
    pbar.finish
  end

  def init_edges
    pbar = ProgressBar.new("initializing edges", @node_index.size)
    @node_index.each do |k,v|
      if v.size > 1
        puts v.size
        o = v.first
        v[1..-1].each do |j|
          @edges << Edge.new(o,j,0)
        end
      end
      n=k
      n.size.times do |i|
        temp = String.new n
        temp[i] = (n[i] == '0') ? '1' : '0'
        (@edges << Edge.new(v.first,@node_index[temp].first,1)) if @node_index.has_key?(temp)
        n.size.times do |j|
          next if j == i
          temp2 = String.new temp
          temp2[j] = (temp[j] == '0') ? '1' : '0'
          (@edges << Edge.new(v.first,@node_index[temp2].first,2)) if @node_index.has_key?(temp2)
        end
      end
      pbar.inc
    end
    pbar.finish
  end

  def init_nodes
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @size = csv.shift[0]
    pbar = ProgressBar.new("reading file", @size)
    csv.each do |row|
      str = row.compact.join
      node = Node.new(str)
      if @node_index[str].nil?
        @node_index[str] = [node]
      else
        @node_index[str] << node
      end
      pbar.inc
    end
    pbar.finish
  end
end

c = Clustering.new('clustering2.txt')
c.cluster
puts "#{c.size} clusters"
