#ciridiri.rb

__ciridiri.rb__ is a Ruby+Sinatra port of [ciridiri](http://vast.github.com/ciridiri/),
  dead simple wiki engine.

##Requirements

* [sinatra][]

##Installation

    git clone git://github.com/vast/ciridiri.rb.git
    cd ciridiri.rb
    rackup

And point your browser to `http://localhost:4567/`.

##Usage
Create new pages through accessing `http://localhost:4567/path/to/new/page.html`.
Edit existent page through accessing `http://localhost:4567/existent/page.html.e` or just press `ctrl-shift-e`.

[sinatra]: http://sinatrarb.com/
