class CreateUsers < ActiveRecord::Migration
  def self.up
   create_table :users do |t|
     t.string :username
     t.string :email
     t.string :password
     t.string :location
     t.string :name
     t.boolean :finish
     t.string :picture
     t.string :website
     t.integer :userlevel
     t.text :bio
     t.timestamps
   end
 end

 def self.down
   drop_table :users
 end
end
