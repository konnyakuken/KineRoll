class CreateHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :histories do |t|
      t.integer :movie_id
      t.integer :user_id
      t.string :tag
    end
  end
end
