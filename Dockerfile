FROM apache/airflow:3.2.2

# Debian 12/bookworm ships krb5 1.20.1 with security fixes backported.
# Use Debian 13/trixie packages only when an upstream-version gate requires
# krb5 1.21.3 or newer. This cross-grades core libraries such as libc/openssl,
# so keep this block scoped and re-test Airflow after changing it.
USER root

RUN set -eux; \
    printf '%s\n' \
      'deb http://deb.debian.org/debian trixie main' \
      > /etc/apt/sources.list.d/trixie.list; \
    printf '%s\n' \
      'deb http://deb.debian.org/debian-security trixie-security main' \
      > /etc/apt/sources.list.d/trixie-security.list; \
    printf '%s\n' \
      'Package: *' \
      'Pin: release n=trixie' \
      'Pin-Priority: 100' \
      'Package: *' \
      'Pin: release n=trixie-security' \
      'Pin-Priority: 100' \
      > /etc/apt/preferences.d/limit-trixie; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades --no-install-recommends -t trixie \
      curl=8.14.1-2+deb13u3 \
      git=1:2.47.3-0+deb13u1 \
      git-man=1:2.47.3-0+deb13u1 \
      krb5-user=1.21.3-5 \
      libcurl3t64-gnutls=8.14.1-2+deb13u3 \
      libcurl4t64=8.14.1-2+deb13u3 \
      libexpat1=2.7.1-2 \
      libgnutls30t64=3.8.9-3+deb13u4 \
      libgssapi-krb5-2=1.21.3-5 \
      libk5crypto3=1.21.3-5 \
      libkrb5-3=1.21.3-5 \
      libkrb5support0=1.21.3-5 \
      liblzma5=5.8.1-1 \
      libmariadb3=1:11.8.6-0+deb13u1 \
      libpcre2-8-0=10.46-1~deb13u1 \
      libsqlite3-0=3.46.1-7+deb13u1 \
      libxml2=2.12.7+dfsg+really2.9.14-2.1+deb13u2 \
      libssl3t64=3.5.6-1~deb13u2 \
      mariadb-client=1:11.8.6-0+deb13u1 \
      mariadb-client-core=1:11.8.6-0+deb13u1 \
      mariadb-common=1:11.8.6-0+deb13u1 \
      mysql-common=5.8+1.1.1 \
      openssl=3.5.6-1~deb13u2 \
      openssl-provider-legacy=3.5.6-1~deb13u2 \
      rsync=3.4.1+ds1-5+deb13u2 \
      sqlite3=3.46.1-7+deb13u1 \
      wget=1.25.0-2 \
      zlib1g=1:1.3.dfsg+really1.3.1-1+b1; \
    apt-get purge -y --auto-remove libkdb5-10 libmariadb3-compat usr-is-merged; \
    dpkg-query -W curl git git-man krb5-user libcurl3t64-gnutls libcurl4t64 libexpat1 libgnutls30t64 libgssapi-krb5-2 libk5crypto3 libkrb5-3 libkrb5support0 liblzma5 libmariadb3 libpcre2-8-0 libsqlite3-0 libssl3t64 libxml2 mariadb-client mariadb-client-core mariadb-common mysql-common openssl openssl-provider-legacy rsync sqlite3 wget zlib1g; \
    rm -rf /var/lib/apt/lists/*

USER airflow

RUN python -m pip install --no-cache-dir --upgrade 'litellm==1.83.7'
