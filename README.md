# ModelHistory

Model History is a simple gem that allows you to keep track of changes to specific fields in your Rails models using the ActiveRecord::Dirty module.

## Installation

Add this line to your application's Gemfile:

    gem 'model_history'

Install it using Bundler:

    $ bundle install

Generate the Model History migration and migrate your database

    $ rails generate model_history:migration
    $ rake db:migrate

## Usage

```Ruby
class Widget < ActiveRecord::Base
  has_model_history :name, :price, :creator => proc{ User.current_user }
  attr_accessible :name, :price
end

widget = Widget.last
widget.name # => "Box"
widget.name = "Heart Shaped Box"
widget.save
widget.model_history_records # => returns all changes to the widget
  
model_history = widget.model_history_records.last
model_history.old_value # => "Box"
model_history.new_value # => "Heart Shaped Box"

user   = User.find(123)
widget.model_history_records.created_by(user) 
  # => returns all changes to the widget performed by the specified user

class User < ActiveRecord::Base
  creates_model_history
end    

user = User.find(123)
user.model_history_records 
  # => returns changes made by the specified user
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
