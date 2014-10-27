# Mr. Poole

A butler for Jekyll. Provides a command-line interface (called `poole`) for
creating and publishing posts and drafts for [Jekyll](http://jekyllrb.com)
blogs.

The literary Mr. Poole is Jekyll's butler, who "serves Jekyll faithfully, and
attempts to do a good job and be loyal to his master"
([Wikipedia](http://en.wikipedia.org/wiki/Jekyll_and_hyde#Mr._Poole)), and the
Mr. Poole gem looks to be the same thing.

[![Gem Version](https://badge.fury.io/rb/mr_poole.png)](http://badge.fury.io/rb/mr_poole)

[![Build Status](https://travis-ci.org/mmcclimon/mr_poole.png?branch=master)](https://travis-ci.org/mmcclimon/mr_poole)
[![Code Climate](https://codeclimate.com/github/mmcclimon/mr_poole.png)](https://codeclimate.com/github/mmcclimon/mr_poole)
[![Coverage Status](https://coveralls.io/repos/mmcclimon/mr_poole/badge.png)](https://coveralls.io/r/mmcclimon/mr_poole)

## Usage

Mr. Poole is primarily a command-line application: the gem installs an
executable called `poole` in your path. It has four subcommands: post, draft,
publish, and unpublish. All four of these commands echo a filename to STDOUT,
so you can do something like `poole post "Title" | vim` and start editing
immediately. Alternatively, you can also have Mr. Poole auto open new posts in your preferred `$EDITOR` (see [Configuration](#configuration)).

### Post

    poole post [OPTIONS] TITLE

Generates a timestamped post in your `_posts` directory, with the format
`YYYY-MM-DD-slug.md`. With no options, will generate a slug based on your title
by replacing spaces with underscores, downcasing, and removing any special
character (see configuration section if you don't like the underscores).

Options:

```
-s, --slug      Define a custom slug for post, used for generated file name

-t, --title     Define a title for post. This option may be omitted provided
                that TITLE is given as the last argument to poole

-l, --layout    Path to a custom layout file to use
```

By default, poole generates a simple file that looks like this (but see section
on configuration for more options).

```yaml
---
title: (your title automatically inserted here)
layout: post
date: (current date automatically inserted here)
---
```

### Draft

    poole draft [OPTIONS] TITLE

Just like `poole post`, except that it creates an untimestamped post in your
`_drafts` directory (creating it if it doesn't exist yet). Uses same options
as `post`. In the generated file, no date is inserted.

### Publish

    poole publish [OPTIONS] DRAFT_PATH

Publishes a draft from your _drafts folder to your _posts folder By default,
renames the file and updates the date in the header, but see options:

```
-d, --keep-draft        Do not delete the draft post'
-t, --keep-timestamp    Do not update the draft timestamp'
```

Given this file (called `_drafts/test_draft.md`):

```
---
title: My awesome blog post
layout: post
date:
---

The life, universe, and everything.
```

A call to `poole publish _drafts/test_draft.md` will generate a file named
`_posts/yyyy-mm-dd-test_draft.md` and delete the draft. Also updates the date
filed in the header with a date, and HH:MM, producing this file:

```
---
title: My awesome blog post
layout: post
date: 2010-01-02 16:00
---

The life, universe, and everything.
```

### Unpublish

    poole unpublish POST_PATH

The reverse of publish: moves a file from your _posts folder to the _drafts
folder, renaming the file and removing the date in the header. This will
rename a file called `_posts/yyyy-mm-dd-test_post.md` to
`_drafts/test_post.md`.

```
-p, --keep-post         Do not delete the existing post'
-t, --keep-timestamp    Do not update the existing timestamp'
```

### Script usage

The actual work is done in `MrPoole::Commands`: calls into that class return
the path name for newly created files, so you can do something useful with
them if you want to. This should get better in the future.

## Configuration

You may also include directives for `poole` in Jekyll's `_config.yml` file. You
should provide a `poole` key, which may take the following subkeys:

- `default_layout` - path to a default layout to use
- `default_extension` - file extension to use
- `word_separator` - character to use for slug generation
- `time_format` - a percent-formatted string suitable for passing to Ruby's [Time.strftime](http://www.ruby-doc.org/core-2.1.1/Time.html#method-i-strftime) method
- `auto_open` - set to `true`to automatically open new posts in your `$EDITOR`

Any options you provide in `_config.yml` will override poole's built-in
defaults. Mr. Poole defaults to using Markdown (with extension "md"), and the
default layout is given above in the "Post" section. The default layout is
actually just YAML front matter for Jekyll, so it can be used with any
extension.

Note that command-line options override anything set in your config file. For
example, if you have your default extension set to `textile`, but then pass the
`--layout` flag to post/draft with a Markdown template, the generated post will
use the Markdown extension.

*Important!* Certain characters have special meaning in YAML, which means
you'll need to be careful using certain options.

If you want to use hyphens for the `word_separator` option, you'll
need to escape it (because a single dash is the beginning a YAML bulleted
list). If you don't, the YAML parser will choke (I don't have any control over
this).

```
poole:
  word_separator: "-"   # correct
  word_separator: -     # WRONG...don't do this!
```

Likewise, Ruby's
[`strftime`](http://www.ruby-doc.org/core-2.1.1/Time.html#method-i-strftime)
uses percent-formatted strings. The percent sign is special in YAML, so you
have to put the time format in quotation marks.

```
poole:
  time_format: "%Y-%m-%d"   # correct
  time_format: %Y-%m-%d     # WRONG...poole will exit
```


## To do

- Configuration: hooking into jekyll's `_config.yml` (mostly done)
- Support for multiple output formats (done, but needs better tests)
- Better option handling (more flexible date substitution)
- Better documentation (this is an open source project, after all)

## Installation

Add this line to your application's Gemfile:

    gem 'mr_poole'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mr_poole

## Contact

Contact me on Github, at michael@mcclimon.org, or on twitter, @mmcclimon.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
