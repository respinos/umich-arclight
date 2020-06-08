# DUL ArcLight (Duke University Libraries)

Discovery & access application for archival material at Duke University Libraries. A front-end for archival finding aids / collection guides, built on the [ArcLight](https://github.com/projectblacklight/arclight) engine.

## Requirements

* [Ruby](https://www.ruby-lang.org/en/) 2.6 or later
* [Rails](http://rubyonrails.org) 5.0 or later

## Getting Started


### Indexing

You can index a set of sample Duke EAD files into Solr (takes a couple minutes):

`$ .docker/dev.sh exec app bundle exec rake dul_arclight:reindex_everything`

Background processing jobs for indexing may be monitored using resque-web at:
http://localhost:8080/overview

To index a single finding aid:
`$ .docker/dev.sh exec app bundle exec rake arclight:index FILE=./sample-ead/ead/rubenstein/rushbenjaminandjulia.xml REPOSITORY_ID=rubenstein`

Clear the current index:
`$ .docker/dev.sh exec app bundle exec rake arclight:destroy_index_docs`

## Resources

* [ArcLight on GitHub](https://github.com/projectblacklight/arclight)
* [ArcLight project wiki](https://wiki.lyrasis.org/display/samvera/ArcLight)
