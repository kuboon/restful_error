# RestfulError

Define your error with status code. Raise it and you will get formatted response with i18nized message.

## Installation

Add this line to your application's Gemfile:

    gem 'restful_error'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restful_error

## Usage

### Simple
#### raise me
```ruby
class PostsController < ApplicationController
  before_action do
    raise RestfulError[401] unless current_user
    # or
    raise RestfulError::Unauthorized unless current_user
  end
end
```
#### Multi format response

```ruby
get '/posts/new'
#=> render 'restful_error/show.html' with @status_code and @message

post '/posts.json'
#=> { status: 401, message: "Sign in required"} or write your json at 'restful_error/show.json'

get '/session.xml'
#=> "<error><status type="integer">401</status><message>Sign in required</message></error>" or write your xml at 'restful_error/show.xml'
```

#### I18n

```yaml
ja:
  restful_error:
    unauthorized: ログインしてください #401
    not_found: ページが存在しません #404
```

### Advanced
#### your custom error
```ruby
class ::NoSession < RestfulError[404]; end
# or
class ::NoSession < RestfulError::NotFound; end
```
#### duck typing
```ruby
class OAuthController < ApplicationController

  # all you need is status_code
  class RequireTwitterLogin < StandardError
    def status_code; 401; end
  end
  # or
  class RequireTwitterLogin < StandardError
    def status_code; :unauthorized; end
  end
end
```

#### library defined error
``` ruby
config.action_dispatch.rescue_responses["CanCan::Unauthorized"] = 401
# or
config.action_dispatch.rescue_responses["CanCan::Unauthorized"] = :unauthorized
```
#### I18n
```yaml
ja:
  restful_error:
    no_session: セッションがありません
    oauth_controller/require_twitter_login: Twitterログインが必要です
    can_can/unauthorized: 権限がありません
    active_record/record_not_found: 要求されたリソースが存在しません
```
#### custom message
```ruby
class RequireLogin < StandardError
  def initialize(provider = 'Unknown')
    @provider = provider
  end
  def status_code
    :unauthorized
  end
  def message
    I18n.t('restful_error.require_login', provider: provider)
  end
end
```


## Contributing

1. Fork it ( https://github.com/kuboon/restful_error/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
