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

Ruby```
class Widget < ActiveRecord::Base
  has_model_history :name, :price, :creator => proc{ User.current_user }
  attr_accessible :name, :price
end
```

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
