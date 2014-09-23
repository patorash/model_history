module ModelHistory
  module Mixin
    class CreatorProcError < StandardError ; end
    
    def self.included base
      base.class_eval do 
        extend ClassMethods
      end 
    end       

    module ClassMethods  
      
      # call the model_history class method on models with fields that you want to track changes on.
      # example usage:
      # class User < ActiveRecord::Base
      #   has_model_history :email, :first_name, :last_name
      # end

      # pass an optional proc to assign a creator to the model_history object
      # example usage:
      # class User < ActiveRecord::Base
      #   has_model_history :email, :first_name, :last_name, :creator => proc { User.current_user }
      # end
  
      def has_model_history *args 
        # Mix in the module, but ensure to do so just once.
        metaclass = (class << self; self; end)
        return if metaclass.included_modules.include?(ModelHistory::Mixin::ObjectInstanceMethods)

        has_many        :model_history_records, :as => :model, :dependent => :destroy
        attr_accessor   :model_history_changes, :initialize_model_history
        cattr_accessor  :model_history_columns  


        self.model_history_columns ||= []
    
        if args.present?
          
          before_save     :set_model_history_changes
          after_save      :save_model_history

          args.each do |arg| 
            if [String,Symbol].include?(arg.class)     
              arg = arg.to_sym
              self.model_history_columns << arg unless self.model_history_columns.include?(arg)
              define_method "creator_for_model_history" do end
            elsif arg.is_a?(Hash)
              creator_proc = arg.delete(:creator)
              send :define_method, "creator_for_model_history" do
                begin
                  creator_proc.is_a?(Proc) ? creator_proc.call : nil
                rescue
                  raise ModelHistory::Mixin::CreatorProcError
                end
              end
            end
          end
          include ModelHistory::Mixin::ObjectInstanceMethods
        end
      end # has_model_history
  
      def creates_model_history 
        # Mix in the module, but ensure to do so just once.
        metaclass = (class << self; self; end)
        return if metaclass.included_modules.include?(ModelHistory::Mixin::CreatorInstanceMethods)
      
        has_many :model_history_records, :as => :creator
        
        include ModelHistory::Mixin::CreatorInstanceMethods
      end # creates_model_history
    end # ClassMethods

    module ObjectInstanceMethods
      
      def set_model_history_changes                    
        return true unless self.new_record? || self.changed? 
        
        self.model_history_changes    = self.class.model_history_columns.inject({}) do |changes_hash, column_name| 
          changes_hash[column_name]   = self.send("#{column_name}_change") if self.send("#{column_name}_changed?")  
          changes_hash[column_name] ||= [nil, self.send(column_name)] if self.new_record? && self.send(column_name).present?
          changes_hash
        end  

        self.initialize_model_history = self.new_record?
        true
      end    
      
      def save_model_history     
        return true unless self.model_history_changes.present?
        self.model_history_changes.each do |column_name,vals|
          add_model_history_record column_name, vals[0], vals[1], :creator => self.creator_for_model_history
        end 
        self.model_history_changes = nil
        true
      end
      
      def add_model_history_record column_name, old_value, new_value, options={}    
        creator = options[:creator] || self.creator_for_model_history
        
        mhr_attributes = {
          :model        => self,
          :column_name  => column_name,
          :column_type  => self.class.columns_hash[column_name.to_s].type,
          :old_value    => old_value,
          :new_value    => new_value,
          :creator      => creator
        }  

        dhr = ModelHistoryRecord.new(mhr_attributes)
        
        # attributes for manual updates
        [:revised_created_at, :performing_manual_update].each do |attribute|
          dhr.send("#{attribute}=", options[attribute]) if options[attribute]
        end
        
        self.model_history_records << dhr
      end

      def history_for_column column, options={}
        options[:sort] = true if options[:sort].blank?
        
        records = model_history_records.for_column(column)
        records = records.send(*options[:scope]) if options[:scope]
        records = records.order_asc if options[:sort]

        options[:return_objects] ? records : records.map { |s| s.new_value }
      end

    end # ObjectInstanceMethods

    module CreatorInstanceMethods
  
    end # CreatorInstanceMethods

  end # Mixin
  
end # ModelHistory


ActiveRecord::Base.send :include, ModelHistory::Mixin