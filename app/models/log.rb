class Log < ActiveRecord::Base

  self.pluralize_table_names = false
  self.table_name_prefix = 'mdl_'

end