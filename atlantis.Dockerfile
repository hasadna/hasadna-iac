FROM ghcr.io/runatlantis/atlantis:v0.34.0
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
USER root
RUN wget https://releases.hashicorp.com/vault/1.19.5/vault_1.19.5_linux_amd64.zip &&\
    unzip vault_1.19.5_linux_amd64.zip &&\
    mv vault /usr/local/bin/ &&\
    chmod +x /usr/local/bin/vault &&\
    rm vault_1.19.5_linux_amd64.zip
RUN apk update && apk add build-base libffi-dev
USER atlantis
RUN curl -LsSf https://astral.sh/uv/install.sh | sh &&\
    echo ". /home/atlantis/.local/bin/env" > /home/atlantis/.bash_env &&\
    echo ". /home/atlantis/.bash_env" >> /home/atlantis/.bashrc
ARG PYTHON_VERSION=3.12
RUN . /home/atlantis/.bash_env && uv python install ${PYTHON_VERSION}
ARG KUBECTL_VERSION=v1.33.1
ADD https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
ARG PINNIPED_VERSION=v0.39.0
ADD https://get.pinniped.dev/v0.39.0/pinniped-cli-linux-amd64 /usr/local/bin/pinniped
USER root
RUN chmod +x /usr/local/bin/kubectl /usr/local/bin/pinniped
RUN apk update && apk add bash-completion jq
USER atlantis
COPY pyproject.toml uv.lock /home/atlantis/
RUN cd /home/atlantis && . /home/atlantis/.bash_env && uv sync &&\
    uv pip install --force-reinstall --no-binary cffi pynacl &&\
    echo ". /home/atlantis/.venv/bin/activate" >> /home/atlantis/.bash_env
RUN . /home/atlantis/.bash_env &&\
    cd /home/atlantis &&\
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz &&\
    tar -xf google-cloud-cli-linux-x86_64.tar.gz &&\
    ./google-cloud-sdk/install.sh &&\
    rm google-cloud-cli-linux-x86_64.tar.gz &&\
    echo ". /home/atlantis/google-cloud-sdk/path.bash.inc" >> /home/atlantis/.bash_env
COPY --chown=100:1000 modules/ /home/atlantis/hasadna-iac/modules/
COPY --chown=100:1000 *.tf /home/atlantis/hasadna-iac/
ENV TF_PLUGIN_CACHE_DIR=/home/atlantis/.terraform/plugin-cache
RUN mkdir -p /home/atlantis/.terraform/plugin-cache &&\
    cd /home/atlantis/hasadna-iac &&\
    terraform init -backend=false && rm -rf .terraform
COPY --chown=100:1000 bin/ /home/atlantis/hasadna-iac/bin/
ENV TF_INPUT=0
ENV TF_IN_AUTOMATION=1
ENTRYPOINT ["/home/atlantis/hasadna-iac/bin/docker_entrypoint.sh"]
