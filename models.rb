require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User<ActiveRecord::Base
    has_many :interests
    has_many :schedules
    has_many :histories
    has_secure_password
end

class Interests<ActiveRecord::Base
    belongs_to :movie
    belongs_to :user
end

class Schedules<ActiveRecord::Base
    belongs_to :movie
    belongs_to :user
end

class History<ActiveRecord::Base
   belongs_to :movie
   belongs_to :user
   has_many :reviews
end

class Reviews<ActiveRecord::Base
   belongs_to :history
   belongs_to :movie
end