ARG CENTOS_SYSTEMD_TAG=1.0.0-centos7.9.2009-linux-amd64
FROM wangz2019/centos-systemd:${CENTOS_SYSTEMD_TAG}
ARG GREEN_PLUM_PACKAGE_URL=https://github.com/greenplum-db/gpdb/releases/download/6.8.1/greenplum-db-6.8.1-rhel7-x86_64.rpm

COPY epel.repo /etc/yum.repos.d/epel.repo
RUN set -x \
    && yum -y install apr \
        apr-util \
        bash \
        bzip2 \
        curl \
        krb5-libs \
        libevent \
        libxml2 \
        libyaml \
        zlib \
        openldap \
        openssh \
        openssl \
        openssl-libs \
        perl \
        readline \
        rsync \
        sed \
        tar \
        zip \
        java-1.8.0-openjdk \
        R \
        openssh-clients \
        ${GREEN_PLUM_PACKAGE_URL} \
    && yum -y clean all \
    && rm -rf /var/cache
COPY sysctl.conf /etc/sysctl.conf
COPY limits.conf /etc/security/limits.conf
RUN set -x \
    && groupadd gpadmin \
    && useradd  gpadmin -g gpadmin -d /home/gpadmin \
    && echo "gpadmin" | passwd --stdin gpadmin \
    && mkdir -p /opt/greenplum/data/master \
    && mkdir -p /opt/greenplum/data/primary \
    && chown -R gpadmin:gpadmin /usr/local/greenplum* \
    && chown -R gpadmin:gpadmin /opt/greenplum
USER user gpadmin

COPY entry_point.sh /opt/greenplum/entry_point.sh
CMD ["etc/security/limits.conf"]
