#Routes
get '/' do
    erb :"index.html", :layout => false
end

get '/devin' do
    erb :"devform.html", :layout => false
end

get '/signin' do
    erb :"signin.html", :layout => false
end

get '/signup' do
    erb :"index.html", :layout => false
end

get '/home' do
    @home = "Home"
    if session[:user] == nil
        "Log in please"
    else
        erb :"home.html"
    end
end

get '/settings' do
    erb :"settings.html"
end

get '/logout' do
    session.clear
    erb :"index.html", :layout => false
end

get '/sendgrid' do
    updates = Database.check("users/" + "jahvon" + "/updates").body.values
    updates.each do |x|
        return x['text']
    end

end

post '/betalist' do
    email = params[:email]
    base_uri = 'https://rubyjd.firebaseio.com/'

    firebase = Firebase::Client.new(base_uri)
    firebase.push("beta_list", { :email => email, :date => Time.now.getutc })
    redirect back
end
