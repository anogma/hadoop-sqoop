FROM sequenceiq/hadoop-docker:2.7.1 

RUN yum -y --enablerepo=extras install epel-release && \
    yum -y clean all && \
    yum -y install python-pip wget nano vim && \
    yum -y clean all

RUN pip install google-api-python-client==1.6.4 && \
    pip install mrjob==0.5.11

COPY assets/.bashrc /root/

#sqoop
RUN wget "http://ftp.unicamp.br/pub/apache/sqoop/1.99.7/sqoop-1.99.7-bin-hadoop200.tar.gz" -O /usr/lib/sqoop.tar.gz \
    && cd /usr/lib/ \
    && tar xvf sqoop.tar.gz \
    && mv sqoop-1.99.7-bin-hadoop200 sqoop \
    && rm sqoop.tar.gz

RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.47.tar.gz -O /usr/lib/mysql.tar.gz -q \
    && cd /usr/lib/ \
    && tar xvf mysql.tar.gz \
    && mkdir /usr/lib/sqoop/extra \
    && cp mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar /usr/lib/sqoop/server/lib \
    && rm mysql.tar.gz

COPY assets/core-site.xml.template $HADOOP_PREFIX/etc/hadoop/core-site.xml.template

RUN echo "allowed.system.users=sqoop2" >> /usr/local/hadoop/etc/hadoop/container-executor.cfg \
    && sed -i '/^org.apache.sqoop.submission.engine.mapreduce.configuration.directory=/ s:.*:org.apache.sqoop.submission.engine.mapreduce.configuration.directory=/usr/local/hadoop/etc/hadoop/:' /usr/lib/sqoop/conf/sqoop.properties

ENV PATH=$PATH:/usr/lib/sqoop/bin \
    HADOOP_COMMON_HOME=/usr/local/hadoop/share/hadoop/common/ \
    HADOOP_HDFS_HOME=/usr/local/hadoop/share/hadoop/hdfs/ \
    HADOOP_MAPRED_HOME=/usr/local/hadoop/share/hadoop/mapreduce/ \
    HADOOP_YARN_HOME=/usr/local/hadoop/share/hadoop/yarn/ \
    HADOOP_HOME=/usr/local/hadoop

