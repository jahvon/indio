require 'stripe'

set :publishable_key, ENV['stripe_pkey']
set :secret_key, ENV['stripe_skey']

configure do
    set :api_key, ENV['stripe_apikey']
    set :client_id, ENV['stripe_id']

    options = {
      :site => 'https://connect.stripe.com',
      :authorize_url => '/oauth/authorize',
      :token_url => '/oauth/token'
    }

    set :client, OAuth2::Client.new(settings.client_id, settings.api_key, options)
end

Stripe.api_key = settings.secret_key

def newRecipient(name, type, card)
  cre = Stripe::Recipient.create(
  name: name,
  type: type,
  card: card
  )
end

def newSubcription(name, email, plan, card)
  customer = Stripe::Customer.create(
  description: "#{name} - Subscribing Artist",
  email: email,
  card: card
  )
  subr = customer.subscriptions.create(:plan => plan)
  puts subr
end

post '/charge' do
  # Amount in cents
  @amount = 500
  ACCESS_TOKEN = Database.check("users/"+session[:user]+"/stripe_token").body

  customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :card  => params[:stripeToken]
  )

  charge = Stripe::Charge.create({
    :amount      => @amount,
    :description => 'Sinatra Charge',
    :currency    => 'usd',
    :customer    => customer.id,
    :application_fee => @amount / 15
  },
  ACCESS_TOKEN
  )


  "Done"
end

get '/stripe_connected' do
    code = params[:code]

    @resp = settings.client.auth_code.get_token(code, :params => {:scope => 'read_write'})
    @access_token = @resp.token
    Database.set("users/"+session[:user]+"/stripe_token", @access_token)

 puts @access_token
end

get '/sell' do
    erb :"sell.html"
end

post "/stripe/webhook" do
  # Retrieve the request's body and parse it as JSON
  event_json = JSON.parse(request.body.read)
  # Do something with event_json

  status 200
end
