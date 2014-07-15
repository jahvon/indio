require 'mail'

Mail.defaults do
  delivery_method :smtp, { :address   => 'smtp.sendgrid.net',
                           :port      => 587,
                           :domain    => 'indio-music.herokuapp.com',
                           :user_name => ENV['sendgrid_user'],
                           :password  => ENV['sendgrid_pass'],
                           :authentication => 'plain',
                           :enable_starttls_auto => true }
end

class Email
  def self.confirm(user, email, code)
    Mail.deliver do
      to email
      from 'Indio <indio@jahvon.me>'
      subject 'Welcome to Indio!'
      content_type 'text/html; charset=UTF-8'
      body "<h1>Welcome to Indio</h1><p>#{user.capitalize}, thank you for signing up! In order to take advantage of everything we offer, please confirm your email address! <a href=\"www.jahvon.me/confirm-#{user}-#{code}\">CLICK HERE TO CONFIRM</a>.</p>"
    end
  end
  def self.resetpw(user, code)
    Mail.deliver do
      to Database.check("users/" + user + "/email").body.to_s
      from 'Indio <indio@jahvon.me>'
      subject 'Reset Indio Password'
      content_type 'text/html; charset=UTF-8'
      body "<h1>Resetting your Password</h1><p>You have requested to reset your password. If this is not true, click here. Otherwise, <a href=\"jahvon.me/reset-#{user}-#{code}\">CLICK HERE</a>"
    end
  end
end

get '/confirm-:user-:code' do
	confirmuser = User.where(username: params[:user])[0]
  if confirmuser.confirm_email.to_s == params[:code]
    confirmuser.update(confirm_email: "Confirmed")
    @signinmodal = "show"
    @signinstatus = "Email confirmed! You can sign in now!"
    erb :"index.html",  :layout => false
  else
    "Email not confirmed"
  end
end

get '/reset-:user-:code' do
  if User.where(username: params[:user])[0].pwreset_code.to_s == params[:code].to_s
    @resetmodal = "show"
    @user = params[:user]
    erb :"index.html",  :layout => false
  else
    "Something went wrong"
  end
end
