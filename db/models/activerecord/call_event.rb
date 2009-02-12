class CallEvent < ActiveRecord::Base
  establish_connection(YAML::load(File.open(File.expand_path(File.dirname(__FILE__) + "/../../../database.yml"))))
end