class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      
      t.string :name
      t.string :mail
      t.string :password_digest
      t.string :icon
      t.timestamps null: false
    end
  end
end
