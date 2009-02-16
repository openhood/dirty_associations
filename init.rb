require "dirty_associations"

ActiveRecord::Base.class_eval do
  include DirtyAssociations
end