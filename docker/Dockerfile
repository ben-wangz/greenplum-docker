ARG CENTOS_SYSTEMD_TAG=1.3.0-centos7.9.2009
FROM wangz2019/docker-systemd:${CENTOS_SYSTEMD_TAG}

COPY epel.repo /etc/yum.repos.d/epel.repo
COPY greenplum-db-6.8.1-rhel7-x86_64.rpm /tmp/greenplum-db-6.8.1-rhel7-x86_64.rpm
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
        /tmp/greenplum-db-6.8.1-rhel7-x86_64.rpm \
    && yum -y clean all \
    && rm -rf /var/cache \
    && rm /tmp/greenplum-db-6.8.1-rhel7-x86_64.rpm
COPY sysctl.conf /etc/sysctl.conf
COPY limits.conf /etc/security/limits.conf
RUN set -x \
    && cp /usr/local/greenplum-db/bin/gpload.py /usr/local/greenplum-db/bin/gpload.py.original \
    && sed -i 's#import sys#import sys\nreload(sys)\nsys.setdefaultencoding("utf8")#g' /usr/local/greenplum-db/bin/gpload.py \
    && sed -i 's#subprocess.Popen(cmd,#subprocess.Popen(cmd.encode("utf8"),#g' /usr/local/greenplum-db/bin/gpload.py \
    && groupadd gpadmin \
    && useradd  gpadmin -g gpadmin -d /home/gpadmin \
    && mkdir -p /opt/greenplum/data/master \
    && mkdir -p /opt/greenplum/data/primary \
    && chown -R gpadmin:gpadmin /usr/local/greenplum* \
    && chown -R gpadmin:gpadmin /opt/greenplum
COPY entry_point.sh /opt/greenplum/entry_point.sh
COPY init_gp_service.sh /opt/greenplum/init_gp_service.sh
RUN set -x \
    && chmod u+x /opt/greenplum/entry_point.sh \
    && chmod a+x /opt/greenplum/init_gp_service.sh

CMD ["/sbin/init"]
