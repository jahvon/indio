class Relationships < ActiveRecord::Migration
  def self.up
   create_table :relationships do |t|
     t.integer :value
     t.string :user_id
     t.string :linked_id
     t.timestamps
   end
 end

 def self.down
   drop_table :relationships
 end
end
