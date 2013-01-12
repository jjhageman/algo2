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
