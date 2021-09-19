require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

require "sinatra/activerecord"#activerecordを使えるように

require 'open-uri'
require "json"
require "net/http"

require 'date'

enable :sessions


helpers do#erbファイル上で利用できるメソッド
    def current_user
       User.find_by(id: session[:user]) #ログイン中のユーザー情報取得
    end
    
    def pop_movie
        pop_url="https://api.themoviedb.org/3/movie/popular?api_key=a8ba2cc864f08aa8915a569d0640347f&language=ja-JA&page=1"
        uri=URI(pop_url)
        res=Net::HTTP.get_response(uri)
        returned_JSON=JSON.parse(res.body)
        @movies=returned_JSON["results"]
        @url=pop_url
    end
    
    def now_date
        @date=Date.today
        weeks=["日","月","火","水","木","金","土"]
        @week=weeks[@date.wday]
    end
    
    def now_time
        @time=Date.now
       sleep(1)
    end
    
end

before do
   Dotenv.load
   Cloudinary.config do |config|
       config.cloud_name = ENV["CLOUD_NAME"]
       config.api_key = ENV["CLOUDINARY_API_KEY"]
       config.api_secret = ENV["CLOUDINARY_API_SECRET"]
    end
end

get "/"do
    session[:name_dup]=nil
    
    pop_movie
    if session[:user]==nil#ログイン済みの場合ホーム画面に遷移するように
        erb :index
    else
        erb :home
    end
end

get "/home"do
    pop_movie
   erb :home 
end

post "/signin"do
    user=User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
       session[:user]=user.id 
    end
    redirect "/home"
end

get "/signup"do
    erb :signup
end


post "/signup"do
    img_url=""
    if params[:file]
        img=params[:file]
        tempfile=img[:tempfile]
        upload=Cloudinary::Uploader.upload(tempfile.path)
        img_url=upload["url"]
    end
    
    if User.find_by(name:params[:name])==nil#名前の重複がないかの確認
        user=User.create(
            name: params[:name],
            password: params[:password],
            password_confirmation: params[:password_confirmation],
            icon: img_url   
        )
        
        if user.persisted? #Active Record object がDB に保存済みかどうかを判定
        session[:user] = user.id
        end
        redirect "/home"
    else
        session[:name_dup]=true
        redirect"/signup"
    end
    
end

get "/signout" do#ログアウト
   session[:user]=nil
   redirect"/"
end

get "/search"do
    #人気作品一覧取得
    pop_movie
    erb :search 
end

post "/search" do
    
    Tmdb::Api.key("a8ba2cc864f08aa8915a569d0640347f")
    Tmdb::Api.language("ja")
    
    base_url="https://api.themoviedb.org/3/search/movie?api_key=a8ba2cc864f08aa8915a569d0640347f&language=ja-JA&query="
    keyword=URI.encode_www_form_component(params[:keyword])

    uri=URI(base_url + keyword)
    #uri=URI.encode_www_form_component(uri, enc=nil)
    res=Net::HTTP.get_response(uri)
    returned_JSON=JSON.parse(res.body)
    
    @movies=returned_JSON["results"]
    @url=base_url

    erb :search 
end

get "/home/edit/:id" do
    erb:user_edit
end

post "/home/edit/:id" do
     user=User.find(params[:id])
     user.name=params[:name]
     user.password=params[:password]
     user.password_confirmation=params[:password_confirmation]
     img_url=""
    if params[:file]
        img=params[:file]
        tempfile=img[:tempfile]
        upload=Cloudinary::Uploader.upload(tempfile.path)
        img_url=upload["url"]
        user.icon=img_url
    end
     user.save
    redirect"/home"
end



post "/new" do
    if Movie.find_by(title: params[:title])==nil
       @movie=Movie.create(
           jacket: params[:jacket],
           release: params[:release],
           title: params[:title]
           )
    else
        @movie=Movie.find_by(title: params[:title])
    end
    session[:movie]=@movie.id
   erb:select 
end

get "/new/post/task"do
    @movie=Movie.find_by(id: session[:movie])
    erb:post_movie
end

post "/new/post/task"do
    schedule=Schedule.create(
        movie_id: params[:movie_id],
        cinema: params[:cinema],
        date: params[:date],
        note: params[:note],
        user_id: session[:user]
    )
    redirect"/task"
end

get "/task"do
    @movies=Schedule.where(user_id: session[:user])
    now_date
    erb :schedule 
end

get"/task/delete/:id"do
    movie=Schedule.find(params[:id])
    movie.destroy
    redirect "/task"
end

get"/task/edit/:id"do
    @task=Schedule.find(params[:id])
    @movie=Movie.find(@task.movie_id)
    erb:schedule_edit
end

post"/task/edit/:id"do
    task=Schedule.find(params[:id])
    task.cinema=params[:cinema]
    task.date=params[:date]
    task.note=params[:note]
    task.save
    redirect"/task"
end