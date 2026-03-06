FROM ubuntu:24.04

# Run apt udate and install jq
RUN apt update && apt install -y jq

# Mount and execute setup.sh
RUN --mount=type=bind,source=./setup.sh,target=/setup.sh ./setup.sh

ENTRYPOINT ["/bin/bash"]