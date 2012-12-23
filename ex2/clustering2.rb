require 'debugger'
require 'csv'
require 'set'
require 'progressbar'

class Node
  attr_accessor :parent, :rank
 
  def initialize
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
  attr :nodes, :bit_counts, :values, :edges, :small_cluster

  def initialize(file)
    @file = file
    @nodes=[]
    @bit_counts = {}
    @size = 0
    @values = Set.new
    @small_cluster = Set.new
    @edges = []
    init_nodes
    init_edges
  end

  def init_edges
    pbar = ProgressBar.new("initializing edges", @nodes.size)
    @nodes.each do |n|
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
        if @values.member?(d)
          @small_cluster.add(n)
          @small_cluster.add(d)
          @edges << Edge.new(n,d,1)
        end
      end


      #bits = n.to_s(2).count('1')
      #for i in (bits-2)..(bits+2)
        ##pbar2 = ProgressBar.new("initializing edges", @bit_counts[i].size)
        #if @bit_counts[i]
          #@bit_counts[i].each do |b|
            #dist = int_distance(n,b)
            #if dist <= 2
              #@edges << Edge.new(n,b,dist)
            #end
            ##pbar2.inc
          #end
        #end
        ##pbar2.finish
      #end
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
      bits = str.count('1')
      @values.add(str)
      if @bit_counts[bits].nil?
        @bit_counts[bits] = [str.to_i(2)]
      else
        @bit_counts[bits] << str.to_i(2)
      end
      @nodes << str
      pbar.inc
    end
    pbar.finish
  end
end

c = Clustering.new('clustering2.txt')
debugger
puts 'Done'
