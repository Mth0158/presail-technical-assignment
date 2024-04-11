This application is the monolythic application that is running the technical assignment made for Presail.<br>

## Rails / Ruby version

Current Rails version is 7.1.3 (check it at `Gemfile`)
Current Ruby version is 3.1.2 (check it at `.ruby_version`)

## Node version

Current Node version is 18.19.0 (check it at `.node_version`)

## System dependencies

There no dependencies outside of Rails, Ruby, Node and Yarn.

## Javascript dependencies

To install the Javascript dependencies, just run the corresponding yarn task:

```bash
$ yarn install
```

## Database creation

To create the database, just run the corresponding rake task:

```bash
$ bundle exec rails db:create
```

## Database initialization

You can either run the migration or, if you start anew, load the schema

```bash
$ bundle exec rails db:schema:load
```

## How to run the test suite

Run the test suite with Rspec:

You can either run the migration or, if you start anew, load the schema

```bash
$ bundle exec rspec spec
```

## Services (job queues, cache servers, search engines, etc.)

No services are required.

## Deployment instructions

There is no CD pipeline configured for our app for this technical assignment.
