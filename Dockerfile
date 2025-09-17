FROM debian:bookworm

# Set default environment variables
ENV PRODUCT=workbench_eng \
    BOARD=x64 \
    BUNDLE="//bundles:tools" \
    FUCHSIA_ROOT="/fuchsia" \
    DEBUG=false \
    PREBUILD=true \
    USER="fuchsia"

# Install the required packages
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        curl \
        git \
        ca-certificates \
        unzip \
        ccache \
        binutils \
        openssh-client \
        eject \
        python3 \
        sudo \
        uuid-runtime && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup --system --gid 1001 fuchsia && \
    adduser --system --home /fuchsia --no-create-home --uid 1001 --gid 1001 --disabled-password --disabled-login fuchsia && \
    usermod -aG sudo fuchsia && \
    bash -o pipefail -c "curl -s 'https://fuchsia.googlesource.com/jiri/+/HEAD/scripts/bootstrap_jiri?format=TEXT' | base64 --decode | bash -s /tmp" && \
    mv /tmp/.jiri_root/bin/* /usr/local/bin && \
    rm -fr /tmp/*

# Copy the entrypoint script
COPY entrypoint /usr/local/bin/entrypoint

# Default command line: interactive shell
WORKDIR /fuchsia
USER fuchsia
ENTRYPOINT ["entrypoint"]
CMD ["shell"]
