require 'csv'
require 'set'
require 'progressbar'
require 'debugger'
require './stackless'

class Scc
  def initialize(file)
    @file = file 
    @explored=Set.new
    @adj_nodes={}
    @rev_nodes={}
    @time=0
    @finish_times={}
    @leaders={}
    @source=0
  end

  def run
    csv = CSV.open(@file, 'r', col_sep: ' ', converters: :integer)
    @num_clauses = csv.shift.first.to_i
    pbar = ProgressBar.new("graph hash", @num_clauses)
    csv.each do |row|
      u=row[0]
      v=row[1]
      @adj_nodes.has_key?(-u) ? (@adj_nodes[-u] << v) : (@adj_nodes[-u]=[v])
      @adj_nodes.has_key?(-v) ? (@adj_nodes[-v] << u) : (@adj_nodes[-v]=[u])
      @rev_nodes.has_key?(v) ? (@rev_nodes[v] << -u) : (@rev_nodes[v]=[-u])
      @rev_nodes.has_key?(u) ? (@rev_nodes[u] << -v) : (@rev_nodes[u]=[-v])
      pbar.inc
    end
    #Ccsv.foreach(@file) do |row|
      #i=row[0].split(" ")
      #u=i[0].to_i
      #v=i[1].to_i
      #@adj_nodes.has_key?(u) ? (@adj_nodes[u] << v) : (@adj_nodes[u]=[v])
      #@rev_nodes.has_key?(v) ? (@rev_nodes[v] << u) : (@rev_nodes[v]=[u])
      #pbar.inc
    #end
    pbar.finish
    puts 'normal and reverse graph created'

    i=@num_clauses
    #puts "revg: #{@rev_nodes}"
    pbar = ProgressBar.new("reverse dfs", @num_clauses)
    while i > 0
      @source=i
      dfs(@rev_nodes, i)
      #puts @explored.size
      pbar.inc
      i -= 1
    end
    pbar.finish
    #puts "finishing times: #{@finish_times}"

    @leaders={}
    @explored=Set.new
    times = @finish_times.clone
    @time=0
    @finish_times={}
    puts 'variables initialized'

    pbar = ProgressBar.new("times dfs", @num_clauses)
    i=@num_clauses
    while i > 0
      @source = i
      dfs(@adj_nodes, times[i])
      pbar.inc
      i -= 1
    end
    pbar.finish
    puts "end"
    counts = @leaders.group_by{|a,b| b}
    counts.each do |k,v|
      if v.size > 1
        p=Set.new
        v.each do |x|
          if p.member?(x.first)
            abort("Unsatisfiable")
          else
            p.add(x.first.abs)
          end
        end
      end
    end
    puts "Satisfiable"
    #sizes = counts.values.map{|v| v.size}
    #puts "leaders: #{@leaders}"
    #puts "sizes: #{sizes.sort.reverse[0..5]}"
  end

  def dfs(g,s)
    ## Recursive Approach ##
    return if @explored.include?(s)

    @explored << s
    @leaders[s]=@source

    if g[s]
      g[s].each do |v|
        dfs(g,v) unless @explored.include?(v)
      end 
    end

    @time += 1
    @finish_times[@time]=s
  end
  stackless_method :dfs
end

Scc.new('2sat6.txt').run
