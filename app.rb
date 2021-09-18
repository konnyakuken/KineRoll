require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

require "sinatra/activerecord"#activerecordを使えるように

require 'open-uri'
require "json"
require "net/http"

enable :sessions


helpers do#erbファイル上で利用できるメソッド
    def current_user
       User.find_by(id: session[:user]) #ログイン中のユーザー情報取得
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
    
    erb :index
end

post "/signin"do
    user=User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
       session[:user]=user.id 
    end
    redirect "/"
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
        p session[:user]
        redirect "/"
    else
        session[:name_dup]=true
        p "aaaaa"
        redirect"/signup"
    end
    
end

get "/signout" do#ログアウト
   session[:user]=nil
   redirect"/"
end

get "/search"do
    #人気作品一覧取得
    pop_url="https://api.themoviedb.org/3/movie/popular?api_key=a8ba2cc864f08aa8915a569d0640347f&language=ja-JA&page=1"

    uri=URI(pop_url)
    res=Net::HTTP.get_response(uri)
    returned_JSON=JSON.parse(res.body)
    
    @movies=returned_JSON["results"]
    @url=pop_url
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