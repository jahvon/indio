require 'sinatra'
require 'firebase'
require 'aws-sdk'
require 'net/http'
require 'digest'
require 'pry'
require 'json'
require 'oauth2'
require 'sinatra/activerecord'
require './config/environments'
require './mail.rb'
require './users.rb'
require './songs.rb'
require './stripe'
require './routes'

use Rack::Session::Cookie, :key => 'rack.session', :path => '/', :secret => 'your_secret'
set :server, %w[unicorn, webrick]

class User < ActiveRecord::Base
	self.primary_key = "id"
	has_many :followers
	has_many :songs
end
class Follower < ActiveRecord::Base
  belongs_to :users
end
class Song < ActiveRecord::Base
    self.primary_key = "id"
	belongs_to :users
	has_many :song_likes
	has_many :song_dislikes
end
class Song_like < ActiveRecord::Base
	belongs_to :songs
end
class Song_dislike < ActiveRecord::Base
	belongs_to :songs
end


#Firebase class
class Database
    def self.check(path)
        firebase = Firebase::Client.new(ENV['firebase_uri'])
        firebase.get(path)
        #Example: Database.check(ROOT + USER + KEY).body will get the value of https://rubyjd.firebaseio.com/ROOT/USER/KEY
    end
    def self.set(path, hash)
        firebase = Firebase::Client.new(ENV['firebase_uri'])
        firebase.set(path, hash)
        #Example: Database.set(ROOT + USER, HASH) will store the hash of info at https://rubyjd.firebaseio.com/ROOT/USER
    end
    def self.update(path, hash)
        firebase = Firebase::Client.new(ENV['firebase_uri'])
        firebase.update(path, hash)
    end
    def self.delete(path)
        firebase = Firebase::Client.new(ENV['firebase_uri'])
        firebase.delete(path)
    end
end

#Song Info
class Song
    def self.comments(id)
        comments = Database.check("songs/" + id + "/comments").body
        if comments != nil
            comment = comments.values
        else
            return nil
        end
    end
    def self.info(id)
        song_info = Database.check("songs/" + id).body
    end
end

class FormError
    def self.value(num)
        if num == "001" then return "No username was entered" elsif
           num == "002" then return "No password was entered" elsif
           num == "003" then return "You must confirm your email address before signing in" elsif
           num == "004" then return "The password does not match" elsif
           num == "005" then return "That username does not exist" elsif
           num == "006" then return "Username is too long" elsif
           num == "007" then return "Email input is invalid" elsif
           num == "010" then return "Password input is invalid" elsif
           num == "011" then return "Password inputs does not match" elsif
           num == "012" then return "Username needs to be between 3 and 15 characters" elsif
           num == "013" then return "Username already exist" elsif
           num == "014" then return "Email already in use" elsif
           num == "015" then return "Your account was created! Please confirm your email before trying to sign in." else
           return "Error code is unknown"
        end
    end
end


post '/likeartist' do
    user = session[:user]
    artist = params[:artist]
    follow = User.where(username: artist)[0]
    follower = User.where(username: user)[0]

    artistliked = Follower.where(user_id: follow.id, follower_id: follower.id)
    if artistliked != []
        Follower.where(user_id: follow.id, follower_id: follower.id)[0].destroy
    else
        Follower.create(user_id: follow.id, follower_id: follower.id)
    end
    redirect back
end

post '/artist_update' do
    text = params[:text]
    user = session[:user]
    timestamp = Time.now.to_i
    id = rand(10000000000).to_s
    Database.set("users/" + user + "/updates/" + id, {text: text, time: timestamp, id: id})
    redirect back
end

post '/post_comment' do
    id = params[:songid]
    comment = params[:comment]
    timestamp = Time.now.to_i
    comment_id = rand(100000).to_s
    
    Database.set("songs/" + id + "/comments/" + comment_id, {user: session[:user], comment: comment, timestamp: timestamp, id: comment_id})
    redirect back
end
