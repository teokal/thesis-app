class MoodleController < ActiveRecord::Base
    establish_connection(DB_MOODLE)
end
