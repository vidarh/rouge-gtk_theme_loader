# Rouge::GtkThemeLoader

This will attempt to load your GtkSourceView themes into Rouge.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rouge-gtk_theme_loader

## Usage

Require Rouge first. Then require 'rouge/gtk_theme_loader' and it will attempt to load any installed
GtkSourceView themes into Rouge. If you want to install your own custom GtkSourceView
themes, you can install them in ~/.config/rouge/themes/

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vidarh/rouge-gtk_theme_loader.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
