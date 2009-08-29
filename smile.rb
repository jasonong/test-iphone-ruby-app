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
  @post[:id] = params[:id]
  erb :'blog/show'
end

post '/blog/delete/:id' do
  posts = PStore.new('db/blogposts')
  posts.transaction { posts.delete(params[:id].to_i) }
  redirect '/blog'
end

get '/blog/sync' do
  sync = `cd db && git commit -am "#{Time.now}" && git push origin master && git pull origin master`
  redirect '/blog' if sync
end
