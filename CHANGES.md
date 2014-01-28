# Changelog

### v0.4.3 (2014-01-28)

- Make echoed paths reflect custom source directory. Now you can `poole post
  "post title" | vim` even if you are using a custom source directory in your
  `_config.yml`.

### v0.4.2 (2013-12-25)

- Change gemspec development dependencies (wouldn't release a new version
  except that the gemspec changed).

### v0.4.1 (2013-12-25)

- Add custom source dir detection from _config.yml (Merry Christmas!)

### v0.4.0 (2013-09-28)

- Add options for unpublish

### v0.3.2 (2013-09-24)

- Add '--version/-v' option
- Minor bugfixes, tests

### v0.3.1 (2013-09-22)

- Bugfixes to work properly on ruby 1.8.7.

### v0.3.0 (2013-09-22)

- Added --keep-draft and --keep-timestamp flags to publish command (thanks,
  Steven Karas!)

### v0.2.2 (2013-09-22)

- Bugfix so that poole works on ruby 1.9.3

### v0.2.1 (2013-09-22)

- Command-line methods now echo a filename (useful for piping into editor)

### v0.2.0 (2013-09-21)

- Hooked into Jekyll's `_config.yml` for customizations
- Added support for custom layouts
- Added support for custom file extensions
- Improvements to tests

### v0.1.0 (2013-09-21)

- Initial release
