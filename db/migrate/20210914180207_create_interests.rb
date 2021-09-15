class CreateInterests < ActiveRecord::Migration[6.1]
  def change
    create_table :interests do |t|
      t.integer :movie_id
      t.text :note
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
