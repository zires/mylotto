class Lottery < ActiveRecord::Base
  validates_uniqueness_of :number, scope: :lun
  validates_presence_of   :number, :lucky_date, :lun, :full_number

  before_save :extract_units

  @@_probability   = nil
  @@_lastest_units = nil

  class << self

    def units(number)
      number.to_s.split('').last.to_i
    end

    def build_outline(units)
      h = {}
      units.each do |u|
        [u, u+10, u+20, u+30].each do |n|
          next if n > 35 || n <= 0
          h[n] = 0
        end
      end
      h
    end

    def analysis(interception = 10)
      outline = build_outline(analysis_units)
      # TODO: 挑战这里的max_diff
      sum_period.each { |n| outline[n.to_i] += max_diff if outline[n.to_i] }
      outline.each do |k,v|
        outline[k] += probability[k]
      end
      outline.sort { |a1, a2| a2[1] <=> a1[1] }[0,interception].map { |n| n.first }.sort
    end

    # 概率最小和最大的差值
    def max_diff
      values = probability.values
      min, max = [ values.min, values.max ]
      max - min
    end

    # 所有数字出现的总概率
    def probability
      return @@_probability if @@_probability
      total          = self.group(:lun).to_a.count
      @@_probability = (1..35).to_a.inject({}) { |h,i| h[i] = 0; h }
      @@_probability.each do |k,v|
        @@_probability[k] = ( where(number: k).count / total.to_f ) * 100
      end
      @@_probability
    end

    def analysis_units(period = 10)
      if lastest_units.size <= 4
        cupid = 2
      else
        cupid = 3
      end
      period_units = self.group(:lun).order('lucky_date desc').limit(period).map(&:units)
      # 删除连续出现超过三次的数字
      left_units = (0..9).to_a - lastest_units
      lastest_units.reject! { |n| continuous(n, period_units) >= 3 }
      # TODO: 看情况挑战这里的period_units
      tmp = lastest_units.sort_by { |n| appear_probality(n, period_units) }.reverse[0,cupid]
      left_units.reject! { |n| continuous(n, period_units) >= 3 }
      (tmp + left_units.sort_by { |n| appear_probality(n, period_units) }.reverse[0,6-cupid]).sort
    end

    # 某一个数字出现的概率
    def appear_probality(number, units)
      init  = 0
      total = units.size
      units.each do |u|
        init += 1 if u.include?(number)
      end
      init.to_f / total
    end

    # +3
    def sum_period(period = 3)
      arr = []
      group(:lun).order('lucky_date desc').limit(period).each do |lottery|
        arr += lottery.numbers
      end
      arr.uniq.sort
    end

    def lastest_units
      @@_lastest_units ||= group(:lun).order('lucky_date desc').first.units
    end

    # 连续出现的次数
    def continuous(number, units, count = 0)
      if units[count].include?(number)
        count += 1
        continuous(number, units, count)
      else
        count
      end
    end

  end

  def numbers
    full_number.split
  end

  def units
    numbers.map { |number| self.class.units(number) }.uniq.sort
  end

  protected

    def extract_units
      self.units_of_number = number.to_s.split('').last.to_i
    end

end
