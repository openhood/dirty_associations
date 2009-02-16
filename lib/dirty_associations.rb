module DirtyAssociations

  def self.included(base)
    base.extend Macro
  end
  
  module Macro # class methods

    # initial setup of dirty associations
    def dirty_associations(*associations)
      write_inheritable_attribute :dirty_associations, associations || []
      inheritable_attributes[:dirty_associations].each do |association|
        add_association_callbacks(association, {:before_add => "add_or_remove_#{association}".to_sym, :before_remove => "add_or_remove_#{association}".to_sym})
        self.class_eval <<-eos # instance methods
          def add_or_remove_#{association}(child) # called when an associated object is added or removed
            unless #{association}_changed?
              @#{association}_changed = true
              @#{association}_was = Array.new(#{association})
            end
          end
          
          def #{association}_changed?
            !@#{association}_changed.blank?
          end
          
          def #{association}_was
            @#{association}_was ||= Array.new(#{association})
          end
        eos
      end

      # clear dirty associations after each save
      after_save :clear_dirty_associations
      self.class_eval do # instance methods
        def clear_dirty_associations
          inheritable_attributes[:dirty_associations].each do |association|
            self.instance_eval <<-eos
              @#{association}_changed = nil
              @#{association}_was = nil
            eos
          end
        end
      end
    end

  private


  end

end