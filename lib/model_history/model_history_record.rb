require "active_record"

class ModelHistoryRecord < ActiveRecord::Base
  belongs_to :creator,  :polymorphic => true
  belongs_to :model,   :polymorphic => true

  validates_presence_of :model_type, :model_id, :column_name, :column_type, :new_value

  scope :created_by,            lambda { |creator| where(["#{table_name}.creator_id = ? AND #{table_name}.creator_type = ?", creator.id, creator.class.name]) }
  scope :not_created_by,        lambda { |non_creator| where(["#{table_name}.creator_id <> ? OR #{table_name}.creator_type <> ?", non_creator.id, non_creator.class.name]) }
  scope :for_model_type,        lambda { |model_type| where(model_type: model_type.to_s.classify) }
  scope :for_column,            lambda { |column| where(column_name: column.to_s) }
  scope :created_in_range,      lambda { |range| created_at_gte(range.first).created_at_lte(range.last) }
  scope :created_at_gte,        lambda { |date| created_at_lte_or_gte(date,"gte") }
  scope :created_at_lte,        lambda { |date| created_at_lte_or_gte(date,"lte") }
  scope :created_at_lte_or_gte, lambda { |date, lte_or_gte| 
    lte_or_gte = lte_or_gte.to_s == "lte" ? "<=" : ">="
    where("((#{table_name}.revised_created_at is NULL OR #{table_name}.revised_created_at = '') AND #{table_name}.created_at #{lte_or_gte} ?) " + 
          " OR #{table_name}.revised_created_at #{lte_or_gte} ?", date, date)
  }

  scope :order_asc, lambda { order_by_action_timestamp("ASC") }
  scope :order_desc, lambda { order_by_action_timestamp("DESC") }
  scope :order_by_action_timestamp, lambda { |asc_or_desc|
    order("CASE WHEN (#{table_name}.revised_created_at IS NULL OR #{table_name}.revised_created_at = '') then #{table_name}.created_at else #{table_name}.revised_created_at END #{asc_or_desc}")
  }


  attr_accessible :model, :model_id, :model_type,
                  :column_name, :column_type, :old_value, :new_value, 
                  :creator, :creator_id, :creator_type, :revised_created_at

  attr_accessor   :performing_manual_update


  [:new_value, :old_value].each do |attribute|
    define_method "#{attribute}" do 
      val_to_col_type(attribute)
    end
    define_method "#{attribute}=" do |val|
      self[attribute] = val.nil? ? nil : val.to_s
      instance_variable_set "@#{attribute}", val
    end
  end       
       
  def action_timestamp                           
    # use revised_created_at field to update the timestamp for
    # the dirty history action while retaining data integrity
    self[:revised_created_at] || self[:created_at]
  end            
  
  private
  
  def val_to_col_type attribute
    val_as_string = self[attribute]
    return nil if val_as_string.nil?
    case self[:column_type].to_sym
    when :integer, :boolean
      val_as_string.to_i
    when :decimal, :float
      val_as_string.to_f
    when :datetime
      Time.parse val_as_string
    when :date
      Date.parse val_as_string
    else # :string, :text
      val_as_string
    end
  end
  
end
