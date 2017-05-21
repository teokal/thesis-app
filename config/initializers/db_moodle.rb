require 'yaml'

# save moodle database settings in global var
DB_MOODLE = YAML::load(ERB.new(File.read(Rails.root.join('config', 'database_moodle.yml'))).result)[Rails.env]
