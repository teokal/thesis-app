class MoodleDatabase < ActiveRecord::Base
  establish_connection DB_MOODLE
  self.abstract_class = true
end