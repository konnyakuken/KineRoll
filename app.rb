require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

require "sinatra/activerecord"#activerecordを使えるように

require 'open-uri'
require "json"
require "net/http"

require 'date'
require 'time'

require 'sinatra'
require 'sinatra/reloader'
require 'json'

require 'set'
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
        @date=Time.now
        @date=@date.timezone('Asia/Tokyo') 
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

class Time 
  def timezone(timezone = 'UTC')
    old = ENV['TZ']
    utc = self.dup.utc
    ENV['TZ'] = timezone
    output = utc.localtime
    ENV['TZ'] = old
    output
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
    
    if params[:keyword]!=""
        base_url="https://api.themoviedb.org/3/search/movie?api_key=a8ba2cc864f08aa8915a569d0640347f&language=ja-JA&query="
        keyword=URI.encode_www_form_component(params[:keyword])
        
        
        uri=URI(base_url + keyword)
        #uri=URI.encode_www_form_component(uri, enc=nil)
        res=Net::HTTP.get_response(uri)
        returned_JSON=JSON.parse(res.body)
        
        @movies=returned_JSON["results"]
        @url=base_url
    else
        pop_movie
    end
    

    erb :search 
end

get "/home/edit/:id" do
    erb:user_edit
end

post "/home/edit/:id" do
     user=User.find(params[:id])
     
     if params[:password]==params[:password_confirmation]
         user.name=params[:name]
         user.password=params[:password]
         user.password_confirmation=params[:password_confirmation]
        #p user.authenticate_password(params[:password_confirmation])
        #p params[:password_confirmation]
        
         img_url=""
        # p params[:file]
        if params[:file]!=""
            img=params[:file]
            tempfile=img[:tempfile]
            upload=Cloudinary::Uploader.upload(tempfile.path)
            img_url=upload["url"]
            user.icon=img_url
        end
         user.save
        redirect"/home"
    else
        p "aaaa"
        @password=true
        erb:user_edit
    end
end



post "/new/:type" do
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

    if History.find_by(user_id: session[:user],movie_id: @movie.id)==nil
        History.create(
            user_id: session[:user],
            movie_id: @movie.id
            )
    end
    
    if params[:type]=="post"
        erb:select
    end
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
    if !@movies.empty?
        @array = [] #日付をsortする
        @movies.each do |movie|
            @array.push([movie.date,movie.id])
        end
        @array=@array.sort_by {|x| x[0]}
        #観る時間を過ぎた作品があるのかをチェックして観た作品に追加
        while Time.parse(@array[0][0].strftime("%Y/%m/%d %H:%M"))<=Time.parse(Time.now.timezone('Asia/Tokyo').strftime("%Y/%m/%d %H:%M")) do
            schedule=Schedule.find(@array[0][1])
            history=History.find_by(movie_id: schedule.movie_id)
            Review.create(
                user_id: session[:user],
                cinema: schedule.cinema,
                date: schedule.date,
                comment: schedule.note,
                history_id: history.id
            )
            #@array[0].delete_at(0)
            date=@array[0][0]
            id=@array[0][1]
            @array.delete([date,id])
            schedule.destroy
        end
    end

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

get "/new/post/history"do
    @movie=Movie.find_by(id: session[:movie])
    erb:finish_movie
end

post "/new/post/history"do
    history=History.find_by(movie_id: Movie.find_by(id: session[:movie]))
    finish=Review.create(
        user_id: session[:user],
        cinema: params[:cinema],
        date: params[:date],
        comment: params[:comment],
        star: params[:review],
        history_id: history.id
    )
    redirect"/finish"
end

get "/finish"do
   @movies=Review.where(user_id: session[:user])
    set= Set.new
    @movies.each do |movie|
        set.add(movie.history_id)
    end
    @array=set.to_a
    p @array
   erb:finish
end

get"/finish/duplicate"do
     @movies=Review.where(user_id: session[:user])
   erb:finish_duplicate
end

get"/finish/delete/:id/:type"do
    review=Review.find(params[:id])
    review.destroy
    if params[:type]=="detail"
        redirect "/finish"
    else
        redirect "/finish/duplicate"
    end
end

get"/finish/edit/:id/:type"do
    @review=Review.find(params[:id])
    @movie=Movie.find(History.find(@review.history_id).movie_id)
    @type=params[:type]
    erb:finish_edit
end

post"/finish/edit/:id/:type"do
    finish=Review.find(params[:id])
    finish.cinema=params[:cinema]
    finish.date=params[:date]
    finish.comment=params[:comment]
    finish.star=params[:review]
    finish.save
    
    if params[:type]=="detail"
        redirect "/finish"
    else
        redirect "/finish/duplicate"
    end
end

get"/finish/detail/:id"do
    @reviews=Review.where(user_id: session[:user]).where(history_id: params[:id])
    @movie=Movie.find(History.find(params[:id]).movie_id )
    erb:finish_detail
end


get "/favorite"do
   @movies=Interest.where(user_id: session[:user])
   erb:favorite
end

get "/favorite/post"do
    favorite=Interest.find_by(user_id: session[:user],movie_id: session[:movie])
    if Interest.find_by(user_id: session[:user],movie_id: session[:movie])==nil
        Interest.create(
            user_id: session[:user],
            movie_id: session[:movie]
            )
        content_type :json
        @num={num: 1}.to_json
    else
        favorite.destroy
        content_type :json
        @num={num: 0}.to_json
    end
end

get "/update/schedule"do
    @movies=Schedule.where(user_id: session[:user])
    now_date
    if !@movies.empty?
        @array = [] #日付をsortする
        @movies.each do |movie|
            @array.push([movie.date,movie.id])
        end
        @array=@array.sort_by {|x| x[0]}
        #観る時間を過ぎた作品があるのかをチェックして観た作品に追加
        while Time.parse(@array[0][0].strftime("%Y/%m/%d %H:%M"))<=Time.parse(Time.now.timezone('Asia/Tokyo').strftime("%Y/%m/%d %H:%M")) do
            schedule=Schedule.find(@array[0][1])
            history=History.find_by(movie_id: schedule.movie_id)
            Review.create(
                user_id: session[:user],
                cinema: schedule.cinema,
                date: schedule.date,
                comment: schedule.note,
                history_id: history.id
            )
            #@array[0].delete_at(0)
            date=@array[0][0]
            id=@array[0][1]
            @array.delete([date,id])
            schedule.destroy
        end
    end
    @update=true
    erb :update_schedule
end
