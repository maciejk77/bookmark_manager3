require 'sinatra/base'
require 'data_mapper'
require 'tag'
require 'user'

env = ENV['RACK_ENV'] || 'development'

DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")
require './lib/link'

DataMapper.finalize
DataMapper.auto_upgrade!

class BookmarkManager < Sinatra::Base

  enable :sessions
  set :session_secret, 'super secret'
  
  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params['url']
    title = params['title']
    tags = params['tags'].split(' ').map do |tag|
      Tag.first_or_create(text: tag)
    end
    Link.create(url: url, title: title, tags: tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
  # note the view is in views/users/new.erb
  # we need the quotes because otherwise
  # ruby would divide the symbol :users by the
  # variable new (which makes no sense)
    erb :'users/new'
  end

  post '/users' do
  User.create(email: params[:email],
              password: params[:password])
  session[:user_id] = user.id
  redirect to('/')
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
