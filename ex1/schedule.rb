require 'csv'
require 'debugger'
class Job
  include Comparable

  attr :weight, :lenght, :diff, :ratio

  def diff_comparator(anOther)
    diff != anOther.diff ? anOther.diff <=> diff : anOther.weight <=> weight
  end 

  def ratio_comparator(anOther)
    ratio != anOther.ratio ? anOther.ratio <=> ratio : anOther.weight <=> weight
  end 

  def initialize(w,l)
    @weight = w
    @lenght = l
    @diff = w-l
    @ratio = w/l.to_f
  end
end

class Schedule
  def initialize(file)
    @file = file    
    @jobs=[]
    @run_time = 0
    @diff_sum = 0
    @ratio_sum = 0
    load_jobs
  end

  def load_jobs
    csv=CSV.open(@file, 'r', :col_sep => " ", converters: :integer)
    size=csv.shift
    csv.each do |row|
      w=row[0]
      l=row[1]
      @jobs << Job.new(w,l)
    end    
    csv.close
  end

  def run
    @jobs.sort!(&:diff_comparator)
    @jobs.each do |j|
      @run_time += j.lenght
      @diff_sum += @run_time*j.weight
    end
    puts "Sum of weighted completion times sorted by difference: #{@diff_sum}"

    @run_time = 0

    @jobs.sort!(&:ratio_comparator)
    @jobs.each do |j|
      @run_time += j.lenght
      @ratio_sum += @run_time*j.weight
    end
    puts "Sum of weighted completion times sorted by ratio: #{@ratio_sum}"
  end

end
Schedule.new('jobs.txt').run
