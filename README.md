# Mr. Poole

A butler for Jekyll. Provides a command-line interface (called `poole`) for
creating and publishing posts and drafts for [Jekyll](http://jekyllrb.com)
blogs.

The literary Mr. Poole is Jekyll's butler, who "serves Jekyll faithfully, and
attempts to do a good job and be loyal to his master"
[Wikipedia](http://en.wikipedia.org/wiki/Jekyll_and_hyde#Mr._Poole), and the
Mr. Poole gem looks to be the same thing.

## Usage

Mr. Poole is primarily a command-line application: the gem installs an
executable called `poole` in your path. It has four subcommands: post, draft,
publish, and unpublish.

### Post

    poole post [OPTIONS] TITLE

Generates a timestamped post in your `_posts` directory, with the format
`YYYY-MM-DD-slug.md` (other formats to be suppored in the future). With no
options, will generate a slug based on your title by replacing spaces with
underscores, downcasing, and removing any special character.

Options:

```
--slug (-s)     Define a custom slug for post, used for generated file name

--title (-t)    Define a title for post. This option may be omitted provided
                that TITLE is given as the last argument to poole

--layout (-l)   Path to a custom layout file to use
```

Poole generates a simple file (in the future, this will be customizable) that
looks like this:

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

    poole publish DRAFT_PATH

Publishes a draft from your _drafts folder to your _posts folder, renaming the
file and updating the date in the header.

Given this file (called `_drafts/test_draft.md`):

```
---
title: My awesome blog post
layout: post
date:
---

The life, universe, and everything.
```

A call to `poole publish` will generate a file named
`_posts/yyyy-mm-dd-test_draft.md` and delete the draft. (TODO: add flags for
no-delete drafts, and no-update timstamp.) Also updates the date filed in the
header with a date, and HH:MM, producing this file:

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
`_drafts/test_post.md`. (TODO: add flags for no-delete post, no-update
timestamp, and custom slug for unpublished draft (?))


### Script usage

The actual work is done in `MrPoole::Commands`: calls into that class return
the path name for newly created files, so you can do something useful with
them if you want to. This should get better in the future.


## To do

- Configuration: hooking into jekyll's `_config.yml`
- Support for multiple output formats (right now, only markdown is supported)
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
