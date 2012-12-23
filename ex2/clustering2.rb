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
  attr :edges, :node_index

  def initialize(file)
    @file = file
    #@nodes = []
    @size = 0
    @node_index = {}
    #@values = Set.new
    @edges = []
    init_nodes
    init_edges
  end

  def cluster
    pbar = ProgressBar.new("clustering", @edges.size)
    @edges.each do |e|
      n1 = @node_index[e.p1].first
      n2 = @node_index[e.p2].first
      unless n1.find == n2.find
        n1.union(n2)
      end
      pbar.inc
    end
    pbar.finish
  end

  def init_edges
    pbar = ProgressBar.new("initializing edges", @node_index.size)
    @node_index.keys.each do |n|
      dev = []
      n.size.times do |i|
        temp = String.new n
        temp[i] = (n[i] == '0') ? '1' : '0'
        dev << temp
        n.size.times do |j|
          next if j == i
          temp2 = String.new temp
          temp2[j] = (temp[j] == '0') ? '1' : '0'
          dev << temp2
        end
      end

      dev.each do |d|
        if @node_index.has_key?(d)
          @edges << Edge.new(n,d,1)
        end
      end
      pbar.inc
    end
    pbar.finish
  end

  def dist_less_two?(a,b)
    dist = 0
    24.times do |i|
      dist += 1 if a[i] != b[i]
      if dist > 2
        return false
      end
    end
    true
  end

  def str_distance(a,b)
   int_distance(a.to_i(2),b.to_i(2)) 
  end

  def int_distance(a,b)
    (a^b).to_s(2).count("1")
  end

  def init_nodes
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @size = csv.shift
    pbar = ProgressBar.new("reading file", @size[0])
    csv.each do |row|
      str = row.compact.join
      node = Node.new(str)
      if @node_index[str].nil?
        @node_index[str] = [node]
      else
        @node_index[str].first.union(node)
        @node_index[str] << node
      end
      #@nodes << Node.new(str)
      pbar.inc
    end
    pbar.finish
  end
end

c = Clustering.new('clustering2.txt')
c.cluster
p=Set.new
c.node_index.each {|k,v| v.each {|x| p.add(x.parent)}}
puts "#{p.size} clusters"
debugger
puts 'Done'
