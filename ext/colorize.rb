require_relative 'class_methods'
require_relative 'instance_methods'
#
# Colorize String class extension.
#
class String
  extend Colorize::ClassMethods
  include Colorize::InstanceMethods

  color_methods
  modes_methods
end
