# UMich ArcLight (Finding Aids)
Discovery and access application for archival material at University of Michigan Libraries.

A front-end for archival finding aids / collection guides built on the [ArcLight Rails Engine](https://github.com/projectblacklight/arclight).

The application currently runs at [https://findingaids.lib.umich.edu](https://findingaids.lib.umich.edu/).
## Development Quick Start
#### Handy Dandy Aliases (Optional)
```shell
alias dc="docker-compose"
alias dce="docker-compose exec --"
alias abe="dce app bundle exec"
```
NOTES
* To revert back to the old way just copy **docker-compose.bak** over **docker-compose.yml** file. a.k.a. `cp docker-compose.bak docker-compose.yml`
### Build application image
The default is **amd64** architecture a.k.a. Intel
```shell
docker-compose build app
```
For Apple Silicon use **arm64** architecture 
```shell
docker-compose build --build-arg ARCH=arm64 app
```
### Bring up development environment
```shell
docker-compose up -d
```
NOTES
* The ***resque*** and ***resque-web*** containers will exit because we have yet to do a ***bundle install!***.
> ### Install bundler
> ```shell
> docker-compose exec -- app gem install 'bundler:~>2.2.21'
> docker-compose exec -- app bundle config --local build.sassc --disable-march-tune-native
> ```
> This was moved into the Dockerfile so it is no longer is necessary but is left here as a reminder so it will not be forgotten.  
> 
> Need to revisit why this is necessary in the first place!
### Bundle install
```shell
docker-compose exec -- app bundle install
```
NOTES
* Environment variable **BUNDLE_PATH** is set to **/var/opt/app/gems** in the **Dockerfile**.
### Yarn install
```shell
docker-compose exec -- app yarn install
```
NOTES
* Investigate using a volume for **node_modules** directory like we do for **gems**
### Setup databases
```shell
docker-compose exec -- app bundle exec rails db:setup
```
If you need to recreate the databases run db:drop and then db:setup.
```shell
docker-compose exec -- app bundle exec rails db:drop
docker-compose exec -- app bundle exec rails db:setup
```
NOTES
* Names of the databases are defined in **./config/database.yml**
* The environment variable **DATABASE_URL** takes precedence over configured values.
### Create solr cores
```shell
docker-compose exec -- solr solr create_core -d umich-arclight -c umich-arclight-development 
docker-compose exec -- solr solr create_core -d umich-arclight -c umich-arclight-test 
```
If you need to recreate a core run delete and create_core (e.g. umich-arclight-test)
```shell
docker-compose exec -- solr solr delete -c umich-arclight-test
docker-compose exec -- solr solr create_core -d umich-arclight -c umich-arclight-test 
```
NOTES
* Names of the solr cores are defined in **./config/blacklight.yml** file.
* The environment variable **SOLR_URL** takes precedence over configured values.
### Restart Resque and Resque-Web
```shell
docker-compose restart resque
docker-compose restart resque-web
```
NOTES
* **Resque.redis** is assigned in the **./config/initializers/resque.rb** file.
* The **REDIS_URL** is referenced in the **./config/cable.yml** file.
* The environment variable **REDIS_URL** takes precedence over configured values.
* Environment variable **REDIS_URL** is set to **redis://redis:6379** in the **docker-compose.yml** file.
### Start development rails server
```shell
docker-compose exec -- app bundle exec rails s -b 0.0.0.0
```
Verify the application is running http://localhost:3000/
## Bring it all down then back up again
```shell
docker-compose down
```
```shell
docker-compose up -d
```
```shell
docker-compose exec -- app bundle exec rails s -b 0.0.0.0
```
The gems, database, solr, and redis use volumes to persit between the ups and downs of development.
When things get flakey you have the option to simply delete any or all volumes after you bring it all down.
If you remove all volumes just repeat the [Development quick start](#development-quick-start), otherwise
you'll need to run the appropriate steps depending on which volumes you deleted:
* For gems run the [Bundle install](#bundle-install) and [Restart Resque and Resque-Web](#restart-resque-and-resque-web) steps.
* For database run the [Setup databases](#setup-databases) step.
* For solr run the [Create solr cores](#create-solr-cores) step.
* For redis there is nothing else to do.
## Indexing [Encoded Archival Description (EAD)](https://www.loc.gov/ead/eadschema.html) Files
### Index all the EAD files.
```shell
docker-compose exec -- app bundle exec rake dul_arclight:reindex_everything
```
Background processing jobs for indexing may be monitored via resque-web http://localhost:8080/overview
### Index a repository's EAD files (e.g. Bently Historical Library; repository ID bhl).
```shell
docker-compose exec -- app bundle exec rake dul_arclight:reindex_repository REPOSITORY_ID=bhl
```
### Index a single EAD file (e.g. Bently Historical Library; repository ID bhl).
```shell
docker-compose exec -- app bundle exec rake arclight:index REPOSITORY_ID=bhl FILE=/var/opt/app/data/ead/bhl/umich-bhl-032.xml
```
### Clear the Solr index.
```shell
docker-compose exec -- app bundle exec rake arclight:destroy_index_docs
```
NOTES
* Repositories are define in **./config/repositories.yml**
* The default application data directory is **/data** and is declared in **./lib/dul_arclight.rb**.
* The environment variable **FINDING_AID_DATA** takes precedence over the default value.
* Environment variable **FINDING_AID_DATA** is set to **/var/opt/app/data** in the **Dockerfile**.
* The **./sample-ead** directory is mapped to **/var/opt/app/data** in the **docker-compose.yml** file.
## Continuous Integration
Continuous integration is the default rake task and is defined in the **./lib/tasks/default.rake** file.
```shell
docker-compose exec -- app bundle exec rake
```
It actually does nothing but is dependent on these rake tasks:
### JavaScript Linting
```shell
docker-compose exec -- app bundle exec rake lint
```
### Ruby Linting
```shell
docker-compose exec -- app bundle exec rake rubocop
```
### Tests
```shell
docker-compose exec -- app bundle exec rake test
```
### Specs
```shell
docker-compose exec -- app bundle exec rake spec
```
### You may also call these commands directly
```shell
docker-compose exec -- app yarn lint
docker-compose exec -- app bundle exec rubocop
docker-compose exec -- app bundle exec test
docker-compose exec -- app bundle exec rspec
```
### List all rake tasks
```shell
docker-compose exec -- app bundle exec rake -T
```
## Environment Variables
| Name                         | Comment                                            |
|------------------------------|----------------------------------------------------|
| BUNDLE_PATH                  | Path to application bundle gems directory          |
| DATABASE_URL                 | Database connection URL                            |
| FINDING_AID_DATA             | Path to application data directory                 |
| GOOGLE_ANALYTICS_DEBUG       | Google Analytics debug flag                        |
| GOOGLE_ANALYTICS_TRACKING_ID | Google Analytics tracking ID                       |
| RAILS_ENV                    | Rails enviroment: development, test, or production |
| REDIS_URL                    | Redis endpoint URL                                 |
| SOLR_URL                     | Solr core URL                                      |
### List all environment variables
```shell
docker-compose exec -- app env
```
## Local Ports
| Port  | Container  | Comment           | Endpoint                       |
|-------|------------|-------------------|--------------------------------|
| 3000  | app        | Rails Application | http://localhost:3000/         |
| 1234  | app        | RubyMine IDE      |                                |
| 26162 | app        | RubyMine IDE      |                                |
| 5432  | db         | Postgres Server   |                                |
| 8983  | solr       | Solr Server       | http://localhost:8983/solr     |
| 6579  | redis      | Redis Server      |                                |
| 8282  | resque     | Resque Workers    |                                |
| 8080  | resque-web | Resque Web        | http://localhost:8080/overview |
## Volumes
| Volume                    | Container               | Mount                                              |
|---------------------------|-------------------------|----------------------------------------------------|
| umich-arclight_data       | app, resque             | /var/opt/app/data                                  |
| umich-arclight_gems       | app, resque, resque-web | /var/opt/app/gems                                  |
| umich-arclight_db-data    | db                      | /var/lib/postgresql/data/db                        |
| umich-arclight_solr-conf  | solr                    | /opt/solr/server/solr/configsets/umich-arclight:ro |
| umich-arclight_solr-data  | solr                    | /var/solr                                          |
| umich-arclight_redis-data | redis                   | /data                                              |
## Resources
* [ArcLight on GitHub](https://github.com/projectblacklight/arclight)
* [ArcLight project wiki](https://wiki.lyrasis.org/display/samvera/ArcLight)
* [Docker](https://www.docker.com/)
* [Rails](http://rubyonrails.org/)
* [Ruby](https://www.ruby-lang.org/)
