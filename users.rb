get '/signup' do
  redirect to "/#signup", layout: false
end
get '/signin' do
  redirect to "/#signin", layout: false
end
get '/resetpw' do
  redirect to "/#reset", layout: false
end

get '/artist' do
  erb :"finishartist.html", layout: false
end

get '/user-:user' do
    checkuser = Database.check("users/" + params['user'] + "/username")
    if params['user'] == nil || params['user'] != checkuser.body
        halt "User not found"
    else
        @userprofile = params['user']
        erb :"profile.html"
    end
end

#Log in form
post '/signin' do
    emailEntered = params['email']
    email = emailEntered.downcase
    pass = Digest::SHA256.hexdigest params['password']

    checkuser = User.where(email: email)
    if email.length <= 0
        redirect to('/?status=errorlogin&value=001')
        elsif params['password'].length <= 0
        redirect to('/?status=errorlogin&value=002')
    else
        if checkuser[0].email == "#{email}"
            if checkuser[0].password == "#{pass}"
                if checkuser[0].confirm_email == "Confirmed"
                    session[:user] = checkuser[0].username
                    session[:email] = checkuser[0].email
                    session[:level] = checkuser[0].userlevel
                    session[:id] = checkuser[0].id
                    redirect to('/')
                else
                    redirect to('/?status=errorlogin&value=003')
                end
            else
            redirect to('/?status=errorlogin&value=004')
            end
        else
        redirect to('/?status=errorlogin&value=005')
        end
    end
end

#Registration form
post '/signup' do
    user = params['username']
    email = params['email']
    pass = Digest::SHA256.hexdigest params['password']
    cpass = Digest::SHA256.hexdigest params['confirmed_password']
    artist = params['artist']
    code = rand(100000000000000)

    if artist == 'on'
        level = 2
    else
        level = 1
    end

    userexist = User.where(username: user)
    emailexist = User.where(email: email)

    User.create(username: user.downcase, email: email.downcase, password: pass, location: "Earth", name: user, finish: false, website: "www.yourindio.com", userlevel: level, bio: "I love Indio!", confirm_email: code, pwreset_code: nil)

    @uname, @email = user, email
    if level == 2
      redirect to("/artist")
    elsif
      Email.confirm(user, email, code)
      redirect to("/signup")
    end
end

post '/artist' do
  plan = params['plan']
  name = params['name']
  cardnum = params['cardnum']
  xMon = params['cardmon']
  xYr = params['cardyr']
  cvc = params['cardcvc']

  card = Hash.new("card")
  card = {number: cardnum, exp_month: xMon, exp_year: xYr, cvc: cvc, name: name}

  newRecipient(name, "individual", card)
  newSubcription(name, "test@test.com", plan, card)
end

post '/resetpw_email' do
    username = params[:username]
    resetuser = User.where(username: username)[0]
    if resetuser.username == username.downcase
        code = rand(100000000000000)
        resetuser.update(pwreset_code: code)
        Email.resetpw(username, code)
        resetstatus = "Email sent"
    else
      resetstatus = "Username not found"
    end
    redirect to("/?status=pwreset&value=#{resetstatus}")
end

post '/resetpw' do
    user = params[:user]
    pass = Digest::SHA256.hexdigest params['password']
    cpass = Digest::SHA256.hexdigest params['confirmed_password']
    if pass != cpass || pass == nil || cpass == nil
        resetstatus = "There was a problem"
    else
        resetstatus = "Your password was changed. You can now <a href=\"#signIn\" data-toggle=\"modal\" data-dismiss=\"modal\">sign in.</a>"
        updatepassword = User.where(username: user)[0]
        updatepassword.update(password: pass)
        updatepassword.update(pwreset_code: nil)
    end
    redirect to("/?status=pwreset&value=#{resetstatus}")
end

get '/finish' do
	erb :"finish.html"
end

post '/finishacc' do
    s3 = AWS::S3.new(:access_key_id => ENV['aws_key_id'], :secret_access_key => ENV['aws_secret'])
    bucket = s3.buckets['indio']

    name = params[:name]
    location = params[:location]
    website = params[:website]
    bio = params[:bio]

    if !params['img_file'].nil?
        img_name = session[:user]
        img_tempfile = params['img_file'][:tempfile]
        img_type = params['img_file'][:type]
    end
    unless params['img_file'].nil?
        if img_type != "image/jpg" || img_type != "image/jpeg" || img_type != "image/png" || File.size(img_file) > 10000000
            puts "Upload failed"
            puts "Invalid file type or the file is too large. Only JPG and PNG files 9MB or under are accepted"
        end
        if @finisherror == nil
            puts "Your profile has been updated"
            bucket.objects["profile_image/#{session[:user]}"].write(:file => img_tempfile, :acl => :public_read)
            User.update(session[:id], {name: name, location: location, website: website, bio: bio, finish: true})
        end
    end
    redirect back
end
