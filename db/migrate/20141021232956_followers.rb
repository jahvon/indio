class Followers < ActiveRecord::Migration
  def self.up
   create_table :followers do |t|
     t.string :user_id
     t.string :follower_id
     t.timestamps
   end
 end

 def self.down
   drop_table :followers
 end
end
