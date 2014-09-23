$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
require File.join(File.dirname(__FILE__), 'fake_app')

require 'generators/model_history/migration/templates/active_record/migration'

RSpec.configure do |config|
  config.before :all do
    CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'users'
    CreateModelHistoryRecords.up unless ActiveRecord::Base.connection.table_exists? 'model_history_records'
  end
end
