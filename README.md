[![Gem Version](https://img.shields.io/gem/v/restful_error)](https://rubygems.org/gems/restful_error)

# RestfulError

Define your error with status code. Raise it and you will get formatted response with i18nized message.

## Installation

Add this line to your application's Gemfile:

    gem 'restful_error'

And then execute:

    $ bundle

## Usage

### Pure ruby (without Rails)
#### Predefined errors
```ruby
ex = RestfulError[404].new

StandardError === ex # => true # because inherit from StandardError
RestfulError::BaseError === ex # => true

RestfulError[404] == RestfulError::NotFound # => true # same class

ex.status_data # returns Data about status code
# => #<data RestfulError::Status
#      code=404,
#      reason_phrase="Not Found",
#      symbol=:not_found,
#      const_name="NotFound">
ex.status_data.code # => 404
```

#### Custom error by subclassing
```ruby
class ::NoSession < RestfulError[404]; end
# or
class ::NoSession < RestfulError::NotFound; end
```

#### Custom error with http_status
```ruby
# define http_status and include RestfulError::Helper
class User::PermissionError < StandardError
  include RestfulError::Helper
  def http_status = :unauthorized # or 401
end
User::PermissionError.new.status_data.reason_phrase # => "Unauthorized"
```

### With I18n
`#response_message` returns i18nized message.
```yaml
ja:
  restful_error:
    unauthorized: ログインが必要です
    not_found: ページが存在しません
    user/permission_error: 権限がありません
```
```ruby
# lookup class name first, then status symbol
User::PermissionError.new.response_message # => "権限がありません"
AnotherPermissionError.new.response_message # => "ログインが必要です"
```

### With Rails
`config.exceptions_app` [[guide]](https://guides.rubyonrails.org/configuring.html#config-exceptions-app) will automatically set to RestfulError::ExceptionsApp.

If you want to disable it, you have two options.
- `config.restful_error.exceptions_app.enable = false` (will not set exceptions_app)
- `config.exceptions_app = ActionDispatch::PublicExceptions.new(Rails.public_path)` (set Rails default explicitly, or set your own)

#### Raise me in request handling
```ruby
class PostsController < ApplicationController
  before_action do
    raise RestfulError[401] unless current_user
    # or
    raise RestfulError::Unauthorized unless current_user
  end
end
```
If you want to check the output on development env, you need to set `config.consider_all_requests_local = false` and ensure `show_detailed_exceptions? == false` [[guide]](https://guides.rubyonrails.org/configuring.html#config-consider-all-requests-local)

#### Render response
Default view files are in [app/views/restful_error](app/views/restful_error)

`html`, `json` and `xml` are supported.

You can override them by creating view file `show.{format}.{handler}` under your `app/views/restful_error/` directory.

`@status` `@status_code` `@reason_phrase` `@response_message` are available in the view.

If you have `layouts/restful_error.*.*`, or `layouts/application.*.*`, it will be used as layout. This is done by inheriting `::ApplicationController`.

To change superclass,
set `config.restful_error.exceptions_app.inherit_from = 'AnotherBaseController'`

#### Library defined error
You can assign status code to error classes which are not yours. (This is Rails standard)

```ruby
config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :unauthorized # or 401
```

RestfulError will use these configurations to lookup status code and
`@response_message` will be set on `exceptions_app`.

```yaml
ja:
  restful_error:
    pundit/not_authorized_error: アクセス権限がありません
    active_record/record_not_found: 要求されたリソースが存在しません
```

## Why `response_message`, not `message`?
`StandardError#message` is used for debugging purpose, not intended to be shown to users.
Rails default behavior does not show `message` in production environment. So I decided to use `response_message` instead.

You can `def response_message` or set `@resposne_message` in your error class to build dynamic message.


## Contributing

1. Fork it ( https://github.com/kuboon/restful_error/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
