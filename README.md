
## Usage


Clone the Simple Supply repository, then make sure that you have the `docker`
and `docker-compose` commands installed on your machine.

To run the application, 
Change the USERNAME and PASSWORD on line 32, 33
in `rest_api/simple_supply_rest_api/route_handler.py`
- Then - 
navigate to the project's root directory, then use
this command:

```
./start.sh
```

This command starts all Simple Supply components in separate containers.

The available HTTP endpoints are:
- Client: **http://localhost:8040**
- Simple Supply REST API: **http://localhost:8000**

To reset the network:

```
./reset.sh
```

Change Consensus:

```
./change.sh devmode

./change.sh poet

./change.sh raft
```

Check consensus

```
docker exec sawtooth-validator-default-0 bash -c 'sawtooth settings list --url http://rest-api-0:8008'
```