# Node UI Service

This is a simple HTTP server written in Python using Flask. It returns a list of Open Horizon services running on the local computer. The server responds on port 8000.

## Prerequisites

- Docker
- Open Horizon CLI (`hzn`)
- Python and Flask

## Setup

### Environment Variables

Edit the variables at the top of the Makefile as desired. If you plan to push it to a Docker registry, make sure you give your Docker ID. You may also want to create unique names for your service and pattern if you are sharing a tenancy with other users and you are all publishing this service.

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
make test
make stop
```

When you are ready to try it inside Open Horizon:

```
docker login
hzn key create **yourcompany** **youremail**
make build
make push
make publish-service
make publish-pattern
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

# SBoM Service Policy Generation 

A Software Bill of Materials (SBoM) is a detailed list of components and versions that comprise a piece of software. With software exploits on the rise and open source code being critical to nearly every significant software project today, SBoM education is becoming more and more important. The following steps will lead you through creating an SBoM for the node-ui-service:1.0.0 image, publishing the SBoM data as a service policy, and using the Open Horizon policy engine to control the deployment of the node-ui-service container to an edge node.

1. Create an SBoM for the `node-ui-service:1.0.0` docker image built in the previous section:
```
make check-syft
```

2. Generate a service policy from the SBoM data:
```
make sbom-policy-gen
```

3. Publish the service and service policy:
```
make publish-service
make publish-service-policy
```

4. Publish a deployment policy for the service:
```
make publish-deployment-policy
```
