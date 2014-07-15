class SongLikes < ActiveRecord::Migration
  def self.up
   create_table :song_likes do |t|
     t.integer :song_id
     t.integer :user_id
     t.timestamps
   end
   create_table :song_dislikes do |t|
     t.integer :song_id
     t.integer :user_id
     t.timestamps
   end
 end

 def self.down
   drop_table :song_likes
   drop_table :song_dislikes
 end
end
