class CreateReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.string :cinema
      t.datetime :date
      t.text :comment
      t.integer :star
      t.integer :user_id
      t.integer :history_id
      
      t.timestamps null: false
    end
  end
end
