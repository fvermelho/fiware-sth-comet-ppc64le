FROM ppc64le/centos:7

ARG NODEJS_VERSION=4.8.4

COPY . /opt/sth/

WORKDIR /
RUN yum update -y && yum install -y wget git curl gcc gcc-c++ make yum-utils
RUN wget https://nodejs.org/download/release/latest-argon/node-v4.8.4-linux-ppc64le.tar.gz
RUN tar -zxf node-v4.8.4-linux-ppc64le.tar.gz
RUN export PATH="$PATH:/node-v4.8.4-linux-ppc64le/bin"
ENV PATH="$PATH:/node-v4.8.4-linux-ppc64le/bin"
WORKDIR /opt/sth
RUN cd /opt/sth \
  && npm install --production \
  && yum erase -y gcc-c++ gcc ppl cpp glibc-devel glibc-headers kernel-headers libgomp libstdc++-devel mpfr libss yum-utils libxml2-python \
  && rpm -qa groff redhat-logos | xargs -r rpm -e --nodeps \
  && yum clean all && rm -rf /var/lib/yum/yumdb && rm -rf /var/lib/yum/history \
  && rpm -vv --rebuilddb \
  && find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en_US' ! -name 'locale.alias' | xargs -r rm -r \
  && bash -c 'localedef --list-archive | grep -v -e "en_US" | xargs localedef --delete-from-archive' \
  && /bin/cp -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl \
  && build-locale-archive \
  && npm cache clean \
  && rm -rf /tmp/* /usr/local/lib/node_modules/npm/man /usr/local/lib/node_modules/npm/doc /usr/local/lib/node_modules/npm/html \
  && rm -rf /usr/share/cracklib \
  && rm -rf /usr/share/i18n /usr/{lib,lib64}/gconv \
  && rm -f /var/log/*log


ENTRYPOINT bin/sth

EXPOSE 8666

