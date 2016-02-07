# [Rack::App](http://rack-app.com/) [![Build Status][travis-image]][travis-link]

[travis-image]: https://travis-ci.org/rack-app/rack-app.svg?branch=master
[travis-link]: http://travis-ci.org/rack-app/rack-app
[travis-home]: http://travis-ci.org/

![Rack::App](http://rack-app-website.herokuapp.com/image/msruby_new.png)

Your next favourite rack based micro framework that is totally addition free! 
Have a cup of awesomeness with  your performance designed framework!

The idea behind is simple. 
Keep the dependencies and everything as little as possible,
while able to write pure rack apps,
that will do nothing more than what you defined.

If you want see fancy magic, you are in a bad place buddy!
This includes that it do not have such core extensions like activesupport that monkey patch the whole world.

Routing can handle large amount of endpoints so if you that crazy to use more than 10k endpoint,
you still dont have to worry about response speed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-app'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-app

## Usage

config.ru
```ruby

require 'rack/app'

class YourAwesomeApp < Rack::App

  get '/hello' do
    'Hello World!'
  end

  get '/users/:user_id' do
    params['user_id'] #=> restful parameter :user_id
    say #=> "hello world!" 
  end 
  
  def say
    'hello world!'
  end 
  
end

run YourAwesomeApp

```

you can access Rack::Request with the request method and 
Rack::Response as response method. 

By default if you dont write anything to the response 'body' the endpoint block logic return will be used

## Testing 

for testing use rack/test or the bundled testing module for writing unit test for your rack application

```ruby

require 'spec_helper'
require 'rack/app/test'

describe MyRackApp do

  include Rack::App::Test
  
  rack_app described_class
  
  describe '#something' do
  
    subject{ get(url: '/hello', params: {'dog' => 'meat'}, headers: {'X-Cat' => 'fur'}) }

    it { expect(subject.body).to eq ['world']}
    
    it { expect(subject.status).to eq 201 }
    
  end 
  
end 

```

## Example Apps To start with

* [Basic](https://github.com/adamluzsi/rack-app.rb-examples/tree/master/basic)
  * bare bone simple example app 
  
* [Escher Authorized Api](https://github.com/adamluzsi/rack-app.rb-examples/tree/master/escher_authorized)
  * complex authorization for corporal level api use

## [Benchmarking](https://github.com/adamluzsi/rack-app.rb-benchmark)


* Dump duration with zero business logic or routing: 2.4184169999892074e-06 s
  * no routing
  * return only a static array with static values
* Rack::App duration with routing lookup: 2.9978291999967683e-05 s
  * with routing 
  * with value parsing and reponse object building
* Grape::API duration with routing lookup: 0.0002996424499999746 s
  * with routing 
  * with value parsing and reponse object building

* Rack::App 9.995314276086763x faster (0.00026966415800000693 sec) that Grape::API
* returning a simple rack response array without any logic is 12.395832480544698x faster (2.7559874999978477e-05 sec) that Rack::App
* the same dumb empty proc call is 123.90024135676842x faster than Grape::API (0.0002972240329999854 sec)
  
This was measured with multiple endpoints like that would be in real life example.
I feared do this for Rails that is usually slower than Grape :S
To be honest, I measured with grape because that is one of my favorite micro framework

## Roadmap 

### Team [Backlog](https://docs.google.com/spreadsheets/d/19GGX51i6uCQQz8pQ-lvsIxu43huKCX-eC1526-RL3YA/edit?usp=sharing)

If you have anything to say, you can leave a comment. :)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adamluzsi/rack-app.rb This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

