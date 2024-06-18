# Node UI Service

![License](https://img.shields.io/github/license/open-horizon-services/web-helloworld-python)
![Architecture](https://img.shields.io/badge/architecture-x86,arm64-green)
![Contributors](https://img.shields.io/github/contributors/open-horizon-services/web-helloworld-python.svg)

This Open Horizon service demonstrates a simple HTTP server written in Python using Flask. The server returns a list of Open Horizon services running on the local computer and responds on port 8000.

## Prerequisites

To ensure the successful installation and operation of the Open Horizon service, the following prerequisites must be met:


**Open Horizon Management Hub:** To publish this service and register your edge node, you must either [install the Open Horizon Management Hub](https://open-horizon.github.io/quick-start) or have access to an existing hub. You may also choose a downstream commercial distribution like IBM's Edge Application Manager. If you'd like to use the Open Horizon community hub, you may [apply for a temporary account](https://wiki.lfedge.org/display/LE/Open+Horizon+Management+Hub+Developer+Instance) at the Open Horizon community hub, where credentials will be provided.

**Edge Node:**You will need an x86 computer running Linux or macOS, or an ARM64 device such as a Raspberry Pi running Raspberry Pi OS or Ubuntu. The `anax` agent software must be installed on your edge node. This software facilitates communication with the Management Hub and manages the deployment of services.

**Optional Utilities:** Depending on your operating system, you may use:
  - `brew` on macOS
  - `apt-get` on Ubuntu or Raspberry Pi OS
  - `yum` on Fedora
  
  These commands can install `gcc`, `make`, `git`, `jq`, `curl`, and `net-tools`. These utilities are not strictly required but are highly recommended for successful deployment and troubleshooting.


## Installation

1. **Clone the repository:**
    Clone the `nodeUI` GitHub repo from a terminal prompt on the edge node and enter the folder where the artifacts were copied.

   ```shell
   git clone https://github.com/open-horizon-services/nodeUI.git
   cd web-helloworld-python
    ```

2. **Edit Makefile:**
    Adjust the variables at the top of the Makefile as needed, including your Docker ID and unique names for your service and pattern.

    Run `make clean` to confirm that the "make" utility is installed and workin

    Confirm that you have the Open Horizon agent installed by using the CLI to check the version:

    ``` shell
     hzn version
     ```

    It should return values for both the CLI and the Agent (actual version numbers may vary from those shown):

    ``` text
    Horizon CLI version: 2.31.0-1540
    Horizon Agent version: 2.31.0-1540
    ```

    If it returns "Command not found", then the Open Horizon agent is not installed.

    If it returns a version for the CLI but not the agent, then the agent is installed but not running.  You may run it with `systemctl horizon start` on Linux or `horizon-container start` on macOS.

    Check that the agent is in an unconfigured state, and that it can communicate with a hub.  If you have the `jq` utility installed, run `hzn node list | jq '.configstate.state'` and check that the value returned is "unconfigured".  If not, running `make agent-stop` or `hzn unregister -f` will put the agent in an unconfigured state.  Run `hzn node list | jq '.configuration'` and check that the JSON returned shows values for the "exchange_version" property, as well as the "exchange_api" and "mms_api" properties showing URLs.  If those do not, then the agent is not configured to communicate with a hub.  If you do not have `jq` installed, run `hzn node list` and eyeball the sections mentioned above.

    NOTE: If "exchange_version" is showing an empty value, you will not be able to publish and run the service.  The only fix found to this condition thus far is to re-install the agent using these instructions:

    ```shell
    hzn unregister -f # to ensure that the node is unregistered
    systemctl horizon stop # for Linux, or "horizon-container stop" on macOS
    export HZN_ORG_ID=myorg   # or whatever you customized it to
    export HZN_EXCHANGE_USER_AUTH=admin:<admin-pw>   # use the pw deploy-mgmt-hub.sh displayed
    export HZN_FSS_CSSURL=http://<mgmt-hub-ip>:9443/
    curl -sSL https://github.com/open-horizon/anax/releases/latest/download/agent-install.sh | bash -s -- -i anax: -k css: -c css: -p IBM/pattern-ibm.helloworld -w '*' -T 120
    ```


## Installation

### Using the Service Outside of Open Horizon

If you wish to use this service locally for development or testing purposes without integrating with the Open Horizon ecosystem, follow these commands:

```shell
make build
# This command builds the Docker container from your Dockerfile, preparing it for local execution.

make run
# This runs the container locally. It will start the service on the designated port, making it accessible on your machine.

# Test the service
make test
# This command is used to run any predefined tests that check the functionality of the service. It ensures that the service responds correctly.

make stop
# Stops the running Docker container. Use this command when you are done with testing or running the service locally.
```

### Using the Service Inside of Open Horizon

```
docker login
# Log in to your Docker registry where the container image will be pushed.

hzn key create <yourcompany> <youremail>
# This command generates cryptographic keys used to sign and verify the services and patterns you publish to the Open Horizon Management Hub.

make build
# Builds the Docker container from your Dockerfile, similar to the local build process.

make push
# Pushes the built Docker image to your Docker registry, making it available for deployment through Open Horizon.

make publish
# Publishes the service to the Open Horizon Management Hub.

make agent-run
# Commands the local Open Horizon agent to run the service according to the published pattern.

# Watch agreements and service logs
watch hzn agreement list
# Monitors and displays the agreements between your edge node and the management hub, indicating which services are deployed.

docker ps
# Lists all running Docker containers on your machine, allowing you to see the service container in action.

make test
# Runs tests to ensure the service is operating correctly within the Open Horizon environment.

make agent-stop
# Stops the Open Horizon agent, effectively undeploying the service from your node.
```
