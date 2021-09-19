require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User<ActiveRecord::Base
    has_many :interests
    has_many :schedules
    has_many :histories
    has_secure_password
end

class Interest<ActiveRecord::Base
    belongs_to :movie
    belongs_to :user
end

class Schedule<ActiveRecord::Base
    belongs_to :movie
    belongs_to :user
end

class History<ActiveRecord::Base
   belongs_to :movie
   belongs_to :user
   has_many :reviews
end

class Review<ActiveRecord::Base
   belongs_to :history
   belongs_to :movie
end

class Movie<ActiveRecord::Base
    has_many :interests
    has_many :schedules
    has_many :histories
    has_many :reviews
end