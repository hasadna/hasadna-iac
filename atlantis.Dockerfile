FROM ghcr.io/runatlantis/atlantis:v0.34.0
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
USER root
RUN wget https://releases.hashicorp.com/vault/1.19.5/vault_1.19.5_linux_amd64.zip &&\
    unzip vault_1.19.5_linux_amd64.zip &&\
    mv vault /usr/local/bin/ &&\
    chmod +x /usr/local/bin/vault &&\
    rm vault_1.19.5_linux_amd64.zip
USER atlantis
RUN curl -LsSf https://astral.sh/uv/install.sh | sh &&\
    echo ". /home/atlantis/.local/bin/env" > /home/atlantis/.bash_env &&\
    echo ". /home/atlantis/.bash_env" >> /home/atlantis/.bashrc
ARG PYTHON_VERSION=3.12
RUN . /home/atlantis/.bash_env && uv python install ${PYTHON_VERSION}
COPY pyproject.toml uv.lock bin/get_backend_config.py bin/get_secret_envvars.py bin/save_outputs_to_vault.py /home/atlantis/
RUN cd /home/atlantis && . /home/atlantis/.bash_env && uv sync &&\
    echo ". /home/atlantis/.venv/bin/activate" >> /home/atlantis/.bash_env
RUN . /home/atlantis/.bash_env &&\
    cd /home/atlantis &&\
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz &&\
    tar -xf google-cloud-cli-linux-x86_64.tar.gz &&\
    ./google-cloud-sdk/install.sh &&\
    rm google-cloud-cli-linux-x86_64.tar.gz &&\
    echo ". /home/atlantis/google-cloud-sdk/path.bash.inc" >> /home/atlantis/.bash_env
RUN echo "#!/bin/bash" > /home/atlantis/entrypoint.sh &&\
    echo ". /home/atlantis/.bash_env" >> /home/atlantis/entrypoint.sh &&\
    echo 'exec atlantis "$@"' >> /home/atlantis/entrypoint.sh &&\
    chmod +x /home/atlantis/entrypoint.sh
ENTRYPOINT ["/home/atlantis/entrypoint.sh"]
