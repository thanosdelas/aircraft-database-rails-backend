## Aircraft Database Rails App

### How to setup

Run the following to install the required gems and set up an empty database.
```
bundle install
bundle exec rake db:setup
```

To import a list of aircraft models inside `airctaft` table, use one of the following:
```
bundle exec rake aircraft:import_test_data
bundle exec rake aircraft:import
```

To fetch and save Wikipedia data for each imported aircraft, use:
```
bundle exec rake aircraft:wikipedia_details_import
```
This may take a while, according to the length of the list you imported earlier (~5-10 min for ~300 entries).


In the meantime, you can fire up a rails server with:
```
bundle exec rails server
```
and visit or make a GET request at `http://localhost:3000/api/aircraft`, to incrementally see all the aircraft whose details have been collected from Wikipedia.

An aircraft without details yet is not visible on the public API.


After the import has finished, you can aggregate and insert aircraft types with:
```
bundle exec rake aircraft:extract_and_save_types_from_saved_infobox
```

Then you can attach aircraft to aircraft types with:
```
bundle exec rake aircraft:attach_aircraft_to_aircraft_types
```

### Authentication

To access the admin API, you have to obtain an access token by issuing a POST request at:
```
http://localhost:3000/api/authentication/login
```

with the following body:
```
{
  "email": "test@example.com",
  "password": "test"
}
```

You are going to get a response like the following, which contains the access token:
```
{
  "status": "success",
  "message": "Authentication was successful",
  "data": {
      "access_token": "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOjF9.ndW4tIujgQaM1FBXfrZQzssHti1gxBEzx0YBxWII4-5tLVmxAMe4cEpBdqpxiuXFoLEiHNmk8gMFc0fdzBSyUA"
  }
}
```

You can issue subsequent requests from now on, by providing the token in the request headers with `Authorization: Bearer <token>`.

### Frontend

To set up and run a simple demo Vue application leveraging the API click here:
https://github.com/thanosdelas/aircraft-database-frontend
