require 'sinatra'
require 'pstore'

get '/' do
	erb :index
end

get '/date' do
	@date = `date`
	erb :date
end

get '/smile' do
	@img_file = "annoyed-smiley.jpg"
	erb :smile
end

get '/blog' do
	posts = PStore.new('db/blogposts')
	@posts = []
  posts.transaction do
    posts.roots.each do |root|
      @posts << [root, posts[root]]
    end
  end
	erb :'blog/index'
end

get '/blog/new' do
	erb :'blog/new'
end

post '/blog/create' do
	uid = rand(Time.now)
  posts = PStore.new('db/blogposts')
  record = {:title => params[:blog][:title], :body => params[:blog][:body]}
  posts.transaction{ posts[uid] = record }
  redirect '/blog'
end

get '/blog/show/:id' do
  posts = PStore.new('db/blogposts')
  @post = posts.transaction{ posts[params[:id].to_i] }
  erb :'blog/show'
end
