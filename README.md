
## Usage


Clone the Simple Supply repository, then make sure that you have the `docker`
and `docker-compose` commands installed on your machine.

To run the application, 
Change the USERNAME and PASSWORD on line 32, 33
in `rest_api/simple_supply_rest_api/route_handler.py`
- Then - 
navigate to the project's root directory, then use
this command:

```bash
docker-compose up
```

This command starts all Simple Supply components in separate containers.

The available HTTP endpoints are:
- Client: **http://localhost:8040**
- Simple Supply REST API: **http://localhost:8000**
