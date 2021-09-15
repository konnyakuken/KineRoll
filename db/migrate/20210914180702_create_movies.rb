class CreateMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :jacket
      t.datetime :release
      t.string :title
      
      t.timestamps null: false
    end
  end
end
