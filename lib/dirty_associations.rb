module DirtyAssociations

  def self.included(base)
    base.extend Macro
  end
  
  module Macro # class methods
    
    # initial setup of dirty associations
    def dirty_associations(*associations)
      associations ||= []
      associations.collect!(&:to_s)
      write_inheritable_attribute :dirty_associations, associations
      class_inheritable_reader :dirty_associations
      inheritable_attributes[:dirty_associations].each do |association|
        add_association_callbacks(association, {:before_add => "add_or_remove_#{association}".to_sym, :before_remove => "add_or_remove_#{association}".to_sym})
        self.class_eval <<-eos # instance methods
        
        public

          def #{association}_changed?
            !@#{association}_changed.blank?
          end
          
          def #{association}_was
            @#{association}_was ||= Array.new(#{association})
          end

        private

          def add_or_remove_#{association}(child) # called when an associated object is added or removed
            unless #{association}_changed?
              @#{association}_changed = true
              @#{association}_was = Array.new(#{association})
            end
          end
          
        eos
      end

      self.class_eval do # instance methods

        def save_with_dirty_association(*args)
          if status = save_without_dirty_association(*args)
            clear_dirty_associations
          end
          status
        end
        
        def save_with_dirty_association!(*args)
          status = save_without_dirty_association!(*args)
          clear_dirty_associations.clear
          status
        end
        
        def reload_with_dirty_association(*args)
          record = reload_without_dirty_association(*args)
          clear_dirty_associations
          record
        end
        
        alias_method_chain :save,             :dirty_association
        alias_method_chain :save!,            :dirty_association
        alias_method_chain :reload,           :dirty_association

      public

        # overload dirty methods to take dirty associations in account
        def changed?
          !changed.blank?
        end
        def changed
          super + changed_associations
        end
        def changes
          super.merge changed_associations.inject({}){|h, association|
            h[association] = [send(association + "_was"), Array.new(send(association))]
            h
          }
        end
        def reload_with_dirty(*args)
          clear_dirty_associations
          super
        end
        
        # Attempts to +save+ the record and clears changed attributes if successful.
        def save_with_dirty(*args) #:nodoc:
          if status = save_without_dirty(*args)
            changed_attributes.clear
            clear_dirty_associations
          end
          status
        end

      private

        def changed_associations
          self.class.dirty_associations.select{|association| send(association + "_changed?")}
        end

        def clear_dirty_associations
          self.class.dirty_associations.each do |association|
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