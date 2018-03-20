# geoserver_migrations

> Manage your geoserver configuration similar to ActiveRecord migrations

## Introduction

Maybe not your typical use-case, but I develop I geographic information systems using Ruby on Rails, and when I add a new geographic
feature, I add an `ActiveRecord` migration which is automatically deployed on my development/test/quality assurance/production servers.

However, keeping my geoserver configuration in sync is a different beast: I create and test the geoserver styles and layers on my development
machine and then I have to deploy those.

My first attempt to automate this was to check in relevant parts of the data-directory into a separate repository, which I could then easily deploy and
then use a script to copy those and replace the identifiers with local versions (e.g. workspace/datastore identifiers).

While this worked it proved so cumbersome I skipped it altogether and just manually copied and defined styles/images/layers.
However, you can imagine, this was making my deployment procedure very manually intensive and brittle (forgot to deploy a layer?).
Editing and creating layers in geoserver is not really the most user-friendly thing to do (at least not in the versions I am using right now).

So I imagined: wouldn't it be nice if I could have a similar system to my database migrations but for geoserver? Where if I finally deployed to
my production server (after having three intermediary deploys to my test/acceptance servers) it would _remember_ which layers still had to be created.

> This is a work in progress, not sure if it will be available/usable for the public straightaway.

## Usage

Add gem to your project

    gem 'geoserver_migrations'

when it will be deployed, for now you should link to github to use

    gem 'geoserver_migrations', git: 'nathanvda/geoserver_migrations'

Then run the generator to create the config-file and folder containing the migrations

    rails g geoserver_migrations:install

Inside the config-file you can edit the settings to connect to the geoserver API

      geoserver_base: "http://localhost:8080/geoserver"
      api:
        user: admin
        password: *******
      workspace: your-workspace
      datastore: your-datastore

and if needed you can add a different path for storing the migrations:

      migrations_path: 'geoserver/migrate'

Then you can add a new migration by doing

      rails g geoserver_migrations:add a_meaningfull_migration_name

To run the migrations

      rails g geoserver_migrations:migrate


### Defining a migration

In a migration we intend to create a new layer, linked to a database feature.
We assume that the workspaces and datastores are already setup in your geoserver.


    create_layer :welds do
      style_name :welds
      feature_name :welds
    end

    create_layer :settlement_gauges do
      settlement_gauges_sld = <<-SLD
        this is a test
      SLD
      sld settlement_gauges_sld
      feature_name :settlement_gauges
    end




## Roadmap

For the moment I am most interested in automated my personal use-case, which is

* defining layers/styles based on a single (postgis) datastore

So for now :

- generate layers/styles/feature-types using API
- store migration-numbers in table (e.g. similar to `schema-migrations` table)
- define simple DSL
- use hand-made migration files at first?
- add rake/rails tasks to generate geoserver migrations

Later we could add something like

- define workspace/datastore (to really allow deployment from scratch?)
- define print-styles? is this possible through API?
- maybe make it rails-independant? I can imagine people would want to manage geoserver migrations outside of rails?

Practical:

- I intend to use `HTTPClient` and my own (small) API library for now/for starting (because I use HTTPClient by preference)
- there is a gem to consume geoserver API called [rgeoserver](https://github.com/sul-dlss/rgeoserver) but it uses `RestClient` instead
  but it seems wise to use that instead? Maybe adapt it to use `Faraday` so people can use any underlying http-library they like?  


