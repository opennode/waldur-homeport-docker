FROM    registry.access.redhat.com/rhel7
MAINTAINER Andres Toomsalu <andres@opennodecloud.com>

LABEL   summary="Waldur Homeport Docker Image" \
        name="opennode/waldur-homeport" \
        vendor="OpenNode" \
        license="MIT" \
        version="2.8" \
        release="0" \
        maintainer="Andres Toomsalu <andres@opennodecloud.com>" \
        description="Self-Service Portal for Waldur Cloud Brokerage Platform" \
        url="https://waldur.com"	

# Add tini
ENV TINI_VERSION v0.16.1
RUN cd /tmp && \
  gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && \
  gpg --fingerprint 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 | grep -q "Key fingerprint = 6380 DC42 8747 F6C3 93FE  ACA5 9A84 159D 7001 A4E5" && \
  curl -sSL https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc -o tini.asc && \
  curl -sSL https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini -o /usr/local/bin/tini && \
  gpg --verify tini.asc /usr/local/bin/tini && \
  chmod +x /usr/local/bin/tini && \
  rm tini.asc

# Add gosu
ENV GOSU_VERSION=1.10 \
    GOSU_GPG_KEY=B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN cd /tmp && \
  gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys $GOSU_GPG_KEY && \
  gpg --fingerprint $GOSU_GPG_KEY | grep -q "Key fingerprint = B42F 6819 007F 00F8 8E36  4FD4 036A 9C25 BF35 7DD4" && \
  curl -sSL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc -o gosu.asc && \
  curl -sSL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64 -o /usr/local/bin/gosu && \
  gpg --verify gosu.asc /usr/local/bin/gosu && \
  chmod +x /usr/local/bin/gosu && \
  rm gosu.asc

# Adding files
COPY rootfs/etc/waldur-homeport /etc/waldur-homeport
COPY rootfs/app-entrypoint.sh /
COPY rootfs/tmp/help.md /tmp/
COPY rootfs/licenses /licenses

### Install Homeport
ENV container docker
RUN REPOLIST=rhel-7-server-rpms,rhel-7-server-optional-rpms,epel \
    INSTALL_PKGS="golang-github-cpuguy83-go-md2man" && \
    yum-config-manager --disable rhel-7-server-htb-rpms && \
    yum -y update-minimal --disablerepo "*" --enablerepo rhel-7-server-rpms --setopt=tsflags=nodocs \
      --security --sec-severity=Important --sec-severity=Critical && \
    curl -o epel-release-latest-7.noarch.rpm -SL https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
      --retry 5 --retry-max-time 0 -C - && \
    yum -y localinstall epel-release-latest-7.noarch.rpm && rm -f epel-release-latest-7.noarch.rpm && \
    yum -y install --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
    yum -y install http://opennodecloud.com/centos/7/waldur-release.rpm && \
    yum -y install waldur-homeport nginx jq && \
    go-md2man -in /tmp/help.md -out /help.1 && \
    yum clean all

RUN rm -f /etc/nginx/nginx.conf \
    && ln -sf /etc/waldur-homeport/nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ENTRYPOINT ["/app-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
