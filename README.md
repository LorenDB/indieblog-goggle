This repo contains a script to generate a Brave Search goggle that boosts results from the blog list at indieweb.page.
It also upranks any site hosted on github.io, micro.blog, or bearblog.dev as those are likely to be good indieweb-style blogs.
Results from medium.com are downranked.

To run the script, you'll need to install a D development toolchain. Then clone this repo and run `dub run` in it. The results
will be saved in the `indieblog.goggle` file.

Feel free to send changes to the generator script or to simply update the goggle if it hasn't been refreshed in a while.
