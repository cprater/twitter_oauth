get '/' do
  erb :index
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url

end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # our request token is only valid until we use it to get an access token, so let's delete it from our session

  @user = User.find_or_create_by_username( @access_token.params[:screen_name],
    oauth_token: @access_token.token,
    oauth_secret: @access_token.secret)

  session.delete(:request_token)

  # @client = Twitter::REST::Client.new do |config|
  #   config.consumer_key = ENV['TWITTER_KEY']
  #   config.consumer_secret = ENV['TWITTER_SECRET']
  #   config.access_token = @user.oauth_token
  #   config.access_token_secret = @user.oauth_secret
  # end

  session[:user_id] = @user.id

  # # at this point in the code is where you'll need to create your user account and store the access token

  erb :index
  # erb @access_token.inspect
end

get '/tweet' do
  @user = User.find(session[:user_id])

  client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_KEY']
    config.consumer_secret = ENV['TWITTER_SECRET']
    config.access_token = @user.oauth_token
    config.access_token_secret = @user.oauth_secret
  end

  client.update(params[:tweet])
  redirect '/'
end
