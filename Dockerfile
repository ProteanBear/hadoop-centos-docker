# Image Source
FROM centos7-systemd

MAINTAINER proteanbear <moru_1982@hotmail.com>

WORKDIR /root

# install jdk,openssh
RUN yum update -y && \
    yum install -y java-1.7.0-openjdk \
 		   openssh-server \
		   openssh-clients \
		   which

# copy hadoop source
ENV HADOOP_VERSION=2.7.3
COPY hadoop-$HADOOP_VERSION.tar.gz /root/hadoop-$HADOOP_VERSION.tar.gz
# install hadoop
RUN tar -xzvf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/local/hadoop && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/jre-1.7.0-openjdk
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV HADOOP_LIBEXEC_DIR=$HADOOP_HOME/libexec 

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# copy file an config
COPY config/* /tmp/
RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh
RUN chmod 600 ~/.ssh/config && \
    chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs
RUN $HADOOP_HOME/bin/hdfs namenode -format

CMD [ "sh", "-c", "systemctl start sshd; bash"]
