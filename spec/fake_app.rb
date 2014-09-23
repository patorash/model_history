require 'active_record'
require 'model_history'

# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection :test

# models
class User < ActiveRecord::Base
  has_model_history :name, :age
  validates :name, :presence => true
end

# migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.timestamps
    end
  end
end
