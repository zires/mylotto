class Lottery < ActiveRecord::Base
  validates_uniqueness_of :number, scope: :lun
  validates_presence_of   :number, :lucky_date, :lun, :full_number

  before_save :extract_units

  protected

    def extract_units
      self.units_of_number = number.to_s.split('').last.to_i
    end

end
