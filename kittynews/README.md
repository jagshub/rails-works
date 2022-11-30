# Kittynews 😼

### Task 1

Add Vote/Unvote button to posts.

On the homepage, there is an inactive vote button.

* Click by an unlogged user should redirect to the login page
* Click by the user should create an upvote
* Click on an already upvoted post should remove the upvote

### Task 2

Show post information & comments on post page:

http://localhost:3000/posts/1

### Task 3

*Can't tell you yet* 😸 🙊

This will be the task during the pair-programming session.

## Criteria:

**Getting to a working solution is most important**.

After that we look for:

- Database design
- Performance
- Dealing with GraphQL N+1
- Tests
- Best practices for Ruby, React, GraphQL

---

## Requirements

- PostgreSQL 9.6
- Ruby 2.5
- bundler 1.16 (or higher if available)
- yarn 1.9 (or higher if available)
- Docker and docker-compose

## Setup

Install the app dependencies:

```
gem install bundler
brew install yarn

bin/setup
```

Start PostgreSQL via Docker *(and keep in background)*

```
docker-compose up -d
```

Setup the database:

```
bundle exec rails db:create db:migrate db:seed
```

Start the server:

```
bundle exec rails server
```

## Tests

To run all tests:

```
bundle exec rspec
```

## Running the app

Open the app:

```
http://localhost:3000
```

Sign in as:

* email: `bob@example.com`
* password: `password`

## GraphiQL

[GraphiQL](https://www.npmjs.com/package/graphiql) is installed and can be accessed via:

```
http://localhost:3000/graphiql
```
