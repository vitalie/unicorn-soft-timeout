# Unicorn::SoftTimeout

This gem adds support for soft timeout in Unicorn. By default
requests which are taking longer than configured **timeout** are
[SIGKILL-ed](http://unicorn.bogomips.org/Unicorn/Configurator.html#method-i-timeout).
In some cases we need to intercept those requests to display a
custom content instead of the error page.


## Installation

Add this line to your application's Gemfile:

    gem 'unicorn-soft-timeout'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unicorn-soft-timeout

## Usage

Edit your config.ru file and load the Unicorn::SoftTimeout middleware:

    # config.ru
    require 'unicorn/soft_timeout'

    # Specify your soft timeout, it should be a lower value
    # than **timeout** specified in your unicorn config.
    # This extension will raise Timeout::Error when reaching
    # the **soft timeout**
    use Unicorn::SoftTimeout, 12

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
