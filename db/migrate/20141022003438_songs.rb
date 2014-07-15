class Songs < ActiveRecord::Migration
  def self.up
   create_table :songs do |t|
     t.string :user_id
     t.string :title
     t.string :description
     t.timestamps
   end
 end

 def self.down
   drop_table :songs
 end
end
