get '/song:id' do
    @title = "Song"
    if params[:id] == nil || Song.where(id: params[:id])[0] == nil
        "We cannot find" + params[:id]
    else
        @song_id = params[:id]
        erb :"song_page.html"
    end
end

get '/nextsong' do
    user_id = User.where(username: session[:user])[0].id
    
    uri = URI.parse "http://api.rcmmndr.com/api_key/#{ENV['rcmmndr_api_key']}/recommend/#{user_id}"
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    if response.body.to_s != "{}"
        song = JSON.parse(response.body).to_a.sample(1)[0][0]
        songId = song
        artist = User.where(id: Song.where(id: song)[0].user_id).username
        title = Song.where(id: song)[0].title
    else
		allSongs = Song.all
        song = allSongs.to_a.sample(1)[0]
        songId = song.id
        artist = User.where(id: song.user_id)[0].username
        title = song.title
        
    end

    song_to_play = {}
    song_to_play[:id] = songId
    song_to_play[:url] = "https://s3.amazonaws.com/indio/music/#{songId}"
    song_to_play[:artist] = artist.capitalize
    song_to_play[:title] = title
    song_to_play.to_json
end

get '/upload' do
    erb :"upload.html"
end

#Artist Upload Song Process
post '/upload' do
    s3 = AWS::S3.new(
        :access_key_id => ENV['aws_key_id'],
        :secret_access_key => ENV['aws_secret']
    )
    bucket = s3.buckets['indio']
    
    title = params['title']
    desc = params['desc']
    album = params['album']
    artist = session[:user]
    price = params['price']
    url = params['url']
    id = Random.rand(1000000000000)
    
    if params['song_file'].nil?
        @uploadstatus = "Upload failed"
        @uploaderror = "File to upload was not selected"
        puts "file in"
    else
        song_file = params['song_file'][:tempfile]
        song_type = params['song_file'][:type]
    end
    unless params['song_file'].nil? 
        if song_type != "audio/mp3" || File.size(song_file) > 10000000
            @uploadstatus = "Upload failed"
            @uploaderror = "Invalid file type or the file is too large. Only MP3 files 9MB or under are accepted"
            puts "file error"
        end
    end
    if title.length <= 0 || desc.length <= 0
        @uploadstatus = "Upload failed"
        @detailerror = "Something is missing!"
    end
    if @uploaderror == nil && @detailerror == nil
        @uploadstatus = "Your file has been uploaded"
        Song.create(id: id, title: title, description: desc, user_id: User.where(username: artist)[0].id, album: album, price: price, alt_url: url, approved: false)
        s3.buckets['indio'].objects["music/#{id}"].write(:file => song_file, :acl => :public_read)
        puts "uploaded"
    end
    @title, @desc = title, desc
    erb :"upload.html"
end

post '/likesong' do
	user = params[:user]
	user_id = User.where(username: user)[0].id
	song = params[:song]
	dothis = params[:dothis]

  if dothis == "like"
    uri = URI.parse "http://api.rcmmndr.com/api_key/#{ENV['rcmmndr_api_key']}/preference/#{user_id}/#{song}/10"
    http = Net::HTTP.new(uri.host, uri.port)
    response = Net::HTTP.post_form(uri, {})
	Song_like.create(song_id: song, user_id: user_id)
  elsif dothis == "dislike"
    uri = URI.parse "http://api.rcmmndr.com/api_key/#{ENV['rcmmndr_api_key']}/preference/#{user_id}/#{song}/-10"
    http = Net::HTTP.new(uri.host, uri.port)
    response = Net::HTTP.post_form(uri, {})
	Song_dislike.create(song_id: song, user_id: user_id)
  end

  redirect back

end
