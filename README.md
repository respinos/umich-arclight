# UMich ArcLight (Finding Aids)
Discovery & access application for archival material at University of Michigan Libraries.
A front-end for archival finding aids / collection guides, built on the [ArcLight](https://github.com/projectblacklight/arclight) engine.

The application currently runs at [https://findingaids.lib.umich.edu](https://findingaids.lib.umich.edu/).
## Development Quick Start (docker-compose.alt)
### Build application image
```shell
docker-compose build app
```
### Bring up development environment
```shell
docker-compose up -d
```
NOTES
* The ***resque*** and ***resque-web*** containers will exit because we have yet to *install bundler*.
### Install bundler
```shell
docker-compose exec -- app gem install 'bundler:~>2.2.21'
docker-compose exec -- app bundle config --local build.sassc --disable-march-tune-native
```
### Bundle install
```shell
docker-compose exec -- app bundle install
```
NOTES
* Environment variable **BUNDLE_PATH** is set to **/var/opt/app/gems** in the **Dockerfile**.
### Yarn Install
```shell
docker-compose exec -- app yarn install
```
NOTES
* Investigate using a volume for **node_modules** directory like we do for **gems**
### Setup databases (a.k.a rails db:setup)
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
* The environment variable **DATABASE_URL** take precedence over configured values.
* Environment variable **DATABASE_URL** is set to **postgresql://postgres:postgres@db/umich-arclight-development** in **docker-compose.yml** file.
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
* The environment variable **SOLR_URL** take precidence over configured values.
* Enviroment variable **SOLR_URL** is set to **http://solr:8983/solr/umich-arclight-development** in the **docker-compose.yml** file.
### Restart Resque and Resque-Web
```shell
docker-compose restart resque
docker-compose restart resque-web
```
NOTES
* The environment variable **REDIS_URL** take precidence over configured values.
* Environment variable **REDIS_URL** is set to **redis://redis:6379** in the **docker-compose.yml** file.
### Start development rails server
```shell
docker-compose exec -- app bundle exec rails s -b 0.0.0.0
```
Verify the application is running http://localhost:3000/
## Loading Example Data
Copy the [Encoded Archival Description (EAD)](https://www.loc.gov/ead/eadschema.html) sample files into the application data directory. 
```shell
docker-compose exec -- app cp -r /opt/app/sample-ead/ead /var/opt/app/data
```
NOTES
* Changes made to files locally in the **./sample-ead** directory will need to be copied over to **/var/opt/app/data** from **/opt/app/sample-ead** manually.
* **WARNING** the `docker-compose cp` command does **NOT** set the owner and group to the container app user which result in permission problems when the app user tries to read, write, and delete the files.
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
* Environment variable **FINDING_AID_DATA** is set to **/var/opt/app/data** in the **Dockerfile**.
## Continuous Integration
```shell
docker-compose exec \
 -e DATABASE_URL:"postgresql://postgres:postgres@db/umich-arclight-test" \
 -e SOLR_URL:"http://solr:8983/solr/umich-arclight-test" \
 -- app bundle exec rake
```
NOTES
* See below for aliases that will hopefully make Test Driven Development (TDD) a bit easier.
## Rake Tasks
```shell
docker-compose exec -- app bundle exec rake -T
```
## Handy Dandy Aliases
```shell
alias dc="docker-compose"
alias dce="docker-compose exec --"
alias dabe="docker-compose exec -e RAIL_ENV:development -e DATABASE_URL:'postgresql://postgres:postgres@db/umich-arclight-development' -e SOLR_URL:'http://solr:8983/solr/umich-arclight-development' -- app bundle exec"
alias tabe="docker-compose exec -e RAILS_ENV:test -e DATABASE_URL:'postgresql://postgres:postgres@db/umich-arclight-test' -e SOLR_URL:'http://solr:8983/solr/umich-arclight-test' -- app bundle exec"
```
```shell
dabe rake rubocop
```
```shell
tabe rake spec
```
## Environment Variables
| Name                         | Value                                                        | Comment                                            |
|------------------------------|--------------------------------------------------------------|----------------------------------------------------|
| RAILS_ENV                    | development                                                  | Rails enviroment: development, test, or production |
| BUNDLE_PATH                  | /var/opt/app/gems                                            | Path to application gems directory                 |
| FINDING_AID_DATA             | /var/opt/app/data                                            | Path to application data directory                 |
| GOOGLE_ANALYTICS_DEBUG       | false                                                        | Google Analytics debug flag                        |
| GOOGLE_ANALYTICS_TRACKING_ID | 0                                                            | Google Analytics tracking ID                       |
| DATABASE_URL                 | postgresql://postgres:postgres@db/umich-arclight-development | Database connection URL                            |
| SOLR_URL                     | http://solr:8983/solr/umich-arclight-development             | Solr core URL                                      |
| REDIS_URL                    | redis://redis:6379                                           | Redis endpoint URL                                 |
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
| umich-arclight_db-data    | db                      | /var/lib/postgresql/data                           |
| umich-arclight_solr-conf  | solr                    | /opt/solr/server/solr/configsets/umich-arclight:ro |
| umich-arclight_solr-data  | solr                    | /var/solr                                          |
| umich-arclight_redis-data | redis                   | /data                                              |
## Resources
* [ArcLight on GitHub](https://github.com/projectblacklight/arclight)
* [ArcLight project wiki](https://wiki.lyrasis.org/display/samvera/ArcLight)
* [Ruby](https://www.ruby-lang.org/)
* [Rails](http://rubyonrails.org/)
* [Docker](https://www.docker.com/)
