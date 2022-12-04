# Random
Generates random numbers for the users and returns maximum of two users with points greater than the number set in an internal state. The user points gets periodically updated every minute.

It also return timestamps of the last query, it will be nil if this is the first query.

### Specification
```
Request:
curl --header "Accept: application/json" http://localhost:4000

Response:
{
  "timestamp":"2022-12-04T19:09:10.374540Z",
  "users":[
    {"id":476,"points":97},
    {"id":471,"points":89}
  ]
}
```

### Setup

#### With Docker
To start the server, run `docker-compose up`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

##### Tests
To run tests, run `docker-compose run app test`

##### Console
To start a console into the application, run `docker-compose run app console`


#### Without Docker
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Postgres credentials:
  Please check config/dev.exs or config/test.exs corresponding to the environment.

### Implementation Details
The user points update is handled in batches, which takes a few milliseconds to finish. 

In an edge case if a request to fetch users arrives during this update, it takes a bit of more time to respond back. To handle this situation, genserver timeout is increased to 10 seconds rather than the default 5 seconds. 

I have taken Keeping It Simple approach to solve this problem. I started with update all query but it took too long and blocked the database to handle any read requests. 
Next idea was to update user points in batches, it had an edge case but worked for all other cases. As described above, after handling the edge case, this was the solution I went for. 

I have not created index on points column although we are searching on it because our writes/updates are more fequent than our reads. Index would have made it slower to update the data.  

### Looking into future
If data drastically increases in future and this approach slows the system. First thing would be to check if we can make system unavailable for a bit and handle the migration. If we cannot make it unavailable, we can use copy all the user ids into another table(may be a temporary table or ets table), truncate this table and reimport ids back with new data since insertion costs less than updating a record.

### SEEDS!!
This application seeds 1,000,000 users, which takes quite some time. 
