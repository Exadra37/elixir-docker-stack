FROM debian:stretch

ENV OTP_VERSION="21.3.4"

# We'll install the build dependencies, and purge them on the last step to make
# sure our final image contains only what we've just built:
RUN set -xe \
  && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
  && OTP_DOWNLOAD_SHA256="1af7c01e80d04423c14449fcb7c5f3b11e0375fe42d01b088ccef4cbcb733c3a" \
  && fetchDeps=' \
    curl \
    ca-certificates' \
  && apt-get update \
  && apt-get install -y --no-install-recommends $fetchDeps \
  && curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
  && echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
  && runtimeDeps=' \
    libodbc1 \
    libssl1.1 \
    libsctp1 \
  ' \
  && buildDeps=' \
    autoconf \
    dpkg-dev \
    gcc \
    g++ \
    make \
    libncurses-dev \
    unixodbc-dev \
    libssl-dev \
    libsctp-dev \
  ' \
  && apt-get install -y --no-install-recommends $runtimeDeps \
  && apt-get install -y --no-install-recommends $buildDeps \
  && export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
  && mkdir -vp $ERL_TOP \
  && tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
  && rm otp-src.tar.gz \
  && ( cd $ERL_TOP \
    && ./otp_build autoconf \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" \
    && make -j$(nproc) \
    && make install ) \
  && find /usr/local -name examples | xargs rm -rf \
  && apt-get purge -y --auto-remove $buildDeps $fetchDeps \
  && rm -rf $ERL_TOP /var/lib/apt/lists/*

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.8.1" \
  LANG=C.UTF-8

RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
  && ELIXIR_DOWNLOAD_SHA256="de8c636ea999392496ccd9a204ccccbc8cb7f417d948fd12692cda2bd02d9822" \
  && buildDeps=' \
    ca-certificates \
    curl \
    make \
  ' \
  && apt-get update \
  && apt-get install -y --no-install-recommends $buildDeps \
  && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
  && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
  && mkdir -p /usr/local/src/elixir \
  && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
  && rm elixir-src.tar.gz \
  && cd /usr/local/src/elixir \
  && make install clean \
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf /var/lib/apt/lists/*

CMD ["iex"]
