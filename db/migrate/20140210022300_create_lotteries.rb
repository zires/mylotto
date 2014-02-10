class CreateLotteries < ActiveRecord::Migration
  def change
    create_table :lotteries do |t|
      t.date :lucky_date
      t.string :lun
      t.string :full_number
      t.integer :number
      t.integer :units_of_number

      t.timestamps
    end
  end
end
