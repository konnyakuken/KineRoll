class CreateSchedule < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      
      t.integer :movie_id
      t.string :cinema
      t.datetime :date
      t.text :note
      t.integer :user_id
      
      t.timestamps null: false
    end
  end
end
