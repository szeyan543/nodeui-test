# Node UI Service

This is a simple HTTP server written in Python using Flask. It returns a list of Open Horizon services running on the local computer. The server responds on port 8000.

## Prerequisites

- Docker
- Open Horizon CLI (`hzn`)
- Python and Flask

## Setup

### Environment Variables

Edit the variables at the top of the Makefile as desired. 
- If you plan to push it to a Docker registry, make sure you give your Docker ID. 
- You may also want to create unique names for your service and pattern if you are sharing a tenancy with other users and you are all publishing this service.
- Modify the `arch`

### Files

Your project directory should contain the following files:

- `Makefile`
- `server.py`
- `Dockerfile`

To play with this outside of Open Horizon, you can use the following commands:

```
make build
make run
...
make stop
```

When you are ready to try it inside Open Horizon:

```
docker login
hzn key create **yourcompany** **youremail**
make build
make push
make publish
```

Once it is published, you can get the agent to deploy it:

```
make agent-run
```

Then you can watch the agreement form, see the container run, then test it:

```
watch hzn agreement list
... (runs forever, so press Ctrl-C when you want to stop)
docker ps
make test
```

Then when you are done you can get the agent to stop running it:

```
make agent-stop
```
