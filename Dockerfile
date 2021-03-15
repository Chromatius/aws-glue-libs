FROM python:3.6-buster AS python

FROM openjdk:8 AS java
# Debian GNU/Linux 10 (buster)

COPY --from=python /usr/local /usr/local

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"
ENV PATH="${PATH}:/root/.local"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && \
    apt-get install zip git tar patch libkrb5-dev krb5-config -y

ENV SPARK_URL "https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz"
ENV MAVEN_URL "https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-3.6.0-bin.tar.gz"

ADD ${MAVEN_URL} /tmp/maven.tar.gz
ADD ${SPARK_URL} /tmp/spark.tar.gz

RUN tar zxvf /tmp/maven.tar.gz -C ~/ && tar zxvf /tmp/spark.tar.gz -C ~/ && rm -rf /tmp/*
RUN echo 'export SPARK_HOME="$(ls -d /root/*spark*)"; export MAVEN_HOME="$(ls -d /root/*maven*)"; export PATH="$PATH:$MAVEN_HOME/bin:$SPARK_HOME/bin:/glue/bin"' >> ~/.bashrc
ENV PYSPARK_PYTHON "${PYTHON_BIN}"


ENV COMMON_PATH=https://aws-glue-jes-prod-us-east-1-assets.s3.amazonaws.com/emr/libs

RUN echo "Installing Python libs" && \
    pip3 install $COMMON_PATH/pyparsing-2.2.0-py2.py3-none-any.whl && \
    pip3 install $COMMON_PATH/pyhocon-0.3.43.tar.gz && \
    pip3 install $COMMON_PATH/pydevd-1.3.0.tar.gz $COMMON_PATH/ptvsd-3.2.1-py2.py3-none-any.whl $COMMON_PATH/PyMySQL-0.8.1-py2.py3-none-any.whl && \
    pip3 install $COMMON_PATH/chardet-3.0.4-py2.py3-none-any.whl $COMMON_PATH/idna-2.7-py2.py3-none-any.whl $COMMON_PATH/urllib3-1.23-py2.py3-none-any.whl $COMMON_PATH/certifi-2018.4.16-py2.py3-none-any.whl $COMMON_PATH/python_dateutil-2.6.1-py2.py3-none-any.whl && \
    pip3 install $COMMON_PATH/requests-2.19.1-py2.py3-none-any.whl && \
    pip3 install $COMMON_PATH/botocore-1.11.9-py2.py3-none-any.whl $COMMON_PATH/s3transfer-0.1.13-py2.py3-none-any.whl && \
    pip3 install $COMMON_PATH/boto3-1.8.9-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/pyparsing-2.2.0-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/pyhocon-0.3.43.tar.gz && \
    python3 -m pip install $COMMON_PATH/pydevd-1.3.0.tar.gz $COMMON_PATH/ptvsd-3.2.1-py2.py3-none-any.whl $COMMON_PATH/PyMySQL-0.8.1-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/chardet-3.0.4-py2.py3-none-any.whl $COMMON_PATH/idna-2.7-py2.py3-none-any.whl $COMMON_PATH/urllib3-1.23-py2.py3-none-any.whl $COMMON_PATH/certifi-2018.4.16-py2.py3-none-any.whl $COMMON_PATH/python_dateutil-2.8.0-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/docutils-0.14-py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/botocore-1.11.9-py2.py3-none-any.whl $COMMON_PATH/s3transfer-0.1.13-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/boto3-1.8.9-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/pytz-2018.5-py2.py3-none-any.whl $COMMON_PATH/six-1.11.0-py2.py3-none-any.whl $COMMON_PATH/subprocess32-3.5.2.tar.gz $COMMON_PATH/cycler-0.10.0-py2.py3-none-any.whl $COMMON_PATH/backports.functools_lru_cache-1.5-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/requests-2.19.1-py2.py3-none-any.whl && \
    python3 -m pip install $COMMON_PATH/numpy-1.15.0-cp36-cp36m-manylinux1_x86_64.whl $COMMON_PATH/kiwisolver-1.0.1-cp36-cp36m-manylinux1_x86_64.whl && \
    python3 -m pip install $COMMON_PATH/matplotlib-3.1.2-cp36-cp36m-manylinux1_x86_64.whl $COMMON_PATH/scipy-1.2.0-cp36-cp36m-manylinux1_x86_64.whl && \
    python3 -m pip install $COMMON_PATH/pyarrow-0.13.0-cp36-cp36m-manylinux1_x86_64.whl && \
    python3 -m pip install $COMMON_PATH/pycryptodome-3.8.1-cp36-cp36m-linux_x86_64.whl && pip install lxml==4.3.0 beautifulsoup4==4.7.1 boto==2.49.0 jmespath==0.9.3 nltk==3.4 nose==1.3.4 py-dateutil==2.2 pyyaml==3.11 soupsieve==1.6.2 windmill==1.6 python-dateutil==2.5.0 pytest && \
    echo "Installing Python libs ends"

#RUN echo "Installing Glue (might take a few mins)" && \
#    cd /home && \
#    wget -q https://github.com/awslabs/aws-glue-libs/archive/glue-1.0.zip && \
#    unzip -q glue-1.0.zip && \
#    mv aws-glue-libs-glue-1.0 aws-glue-libs && \
#    rm -f glue-1.0.zip && \
#    sed -i 's|</dependencies>|<dependency><groupId>jdk.tools</groupId><artifactId>jdk.tools</artifactId><scope>system</scope><version>1.8</version><systemPath>${jdk.home}/lib/tools.jar</systemPath></dependency> </dependencies> <properties><jdk.home>/usr/lib/jvm/java-8-openjdk-amd64</jdk.home></properties>|g' aws-glue-libs/pom.xml && \
#    mvn -q -f aws-glue-libs/pom.xml -DoutputDirectory=jarsv1 dependency:copy-dependencies && \
#    cd /home/aws-glue-libs/jarsv1/ && \
#    rm -f scala-reflect-2.11.7.jar scala-library-2.11.1.jar scala-xml_2.11-1.0.6.jar antlr4-runtime-4.7.2.jar commons-beanutils-1.7.0.jar commons-collections4-4.2.jar commons-compress-1.4.1.jar commons-lang-2.5.jar commons-lang3-3.5.jar commons-math3-3.1.1.jar curator-client-2.7.1.jar curator-framework-2.7.1.jar curator-recipes-2.7.1.jar gson-2.6.2.jar guava-21.0.jar servlet-api-2.5.jar jackson-annotations-2.7.1.jar jackson-core-2.7.1.jar jackson-databind-2.6.7.jar jackson-module-paranamer-2.6.5.jar jackson-module-scala_2.11-2.6.5.jar jcip-annotations-1.0.jar jersey-client-1.9.1.jar jersey-server-1.9.jar jline-0.9.94.jar json4s-ast_2.11-3.5.5.jar json4s-core_2.11-3.5.5.jar json4s-jackson_2.11-3.5.5.jar json4s-scalap_2.11-3.5.5.jar slf4j-log4j12-1.7.10.jar snappy-0.3.jar snappy-java-1.1.2.4.jar && \
#    echo "Installing Glue ends" && \
#    echo "Installing Spark (might take a few mins)" && \
#    cd /home && \
#    wget -q https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-2.4.3-bin-hadoop2.8.tgz && \
#    tar -xf spark-2.4.3-bin-hadoop2.8.tgz && \
#    rm -f spark-2.4.3-bin-hadoop2.8.tgz && \
#    cp /home/aws-glue-libs/jarsv1/*.* spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/jars/ && \
#    cd /home/aws-glue-libs && \
#    zip -r awsglue.zip awsglue && \
#    wget -q -O /home/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/jars/aws-glue-datacatalog-spark-client-1.8.0-SNAPSHOT.jar $COMMON_PATH/aws-glue-datacatalog-spark-client-1.8.0-SNAPSHOT.jar && \
#    echo "Installing Spark ends"

RUN echo "Compiling for hive-exec (might take a few mins)" && \
    cd /home && \
    wget -q https://github.com/apache/hive/archive/branch-1.2.zip && \
    unzip -q branch-1.2.zip && \
    rm -f branch-1.2.zip && \
    mv hive-branch-1.2 hive && \
    cd hive && \
    wget -q https://issues.apache.org/jira/secure/attachment/12958417/HIVE-12679.branch-1.2.patch && \
    patch -p0 <HIVE-12679.branch-1.2.patch && \
    sed -i 's|<commons-lang3.version>3.1</commons-lang3.version>|<commons-lang3.version>3.5</commons-lang3.version>|g' pom.xml && \
    /root/apache-maven-3.6.0/bin/mvn -q clean install -DskipTests -Phadoop-2 -q && \
    cp /root/.m2/repository/org/apache/hive/hive-exec/1.2.3-SNAPSHOT/hive-exec-1.2.3-SNAPSHOT.jar /root/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/jars/ && \
    rm -f /root/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/jars/hive-exec-1.2.1.spark2.jar && \
    rm -f -r /home/hive && \
    echo "Compiling for hive-exec ends"

RUN echo "Adding spark conf" && \
    cd /root/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/conf/ && \
    echo "<configuration> <property><name>hive.metastore.connect.retries</name><value>15</value></property><property><name>hive.metastore.client.factory.class</name><value>com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory</value></property></configuration>" > hive-site.xml && \
    echo "export HADOOP_CONF_DIR=/home/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/conf" > spark-env.sh && \
    echo "<configuration><property><name>fs.s3.impl</name><value>org.apache.hadoop.fs.s3a.S3AFileSystem</value></property><property><name>fs.s3a.impl</name> <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value></property><property><name>fs.s3a.aws.credentials.provider</name> <value>com.amazonaws.auth.DefaultAWSCredentialsProviderChain</value></property><property><name>fs.s3.aws.credentials.provider</name><value>com.amazonaws.auth.DefaultAWSCredentialsProviderChain</value></property></configuration>" > core-site.xml && \
    echo "spark.sql.catalogImplementation hive" > /root/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/conf/spark-defaults.conf && \
    echo "Adding spark conf ends"

RUN echo "Setting up AWS CLI" && \
    cd /root && \
    wget -q https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && \
    unzip -q awscli-exe-linux-x86_64.zip && \
    /root/aws/install && \
    rm -f awscli-exe-linux-x86_64.zip && \
    echo "Setting up AWS CLI ends"

RUN echo "Installing Jupyter" && \
    pip3 install sparkmagic jupyterlab ipykernel && \
    python3 -m ipykernel install && \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
    cd /usr/local/lib/python3.6/site-packages && \
    jupyter-kernelspec install sparkmagic/kernels/pysparkkernel && \
    jupyter-kernelspec install sparkmagic/kernels/sparkkernel && \
    jupyter-kernelspec install sparkmagic/kernels/sparkrkernel && \
    jupyter serverextension enable --py sparkmagic && \
    echo "Installing Jupyter ends" && \
    echo "Installing Livy (might take a few mins)" && \
    cd /home && \
    wget -q https://github.com/apache/incubator-livy/archive/branch-0.6.zip && \
    unzip -q branch-0.6.zip && \
    rm -f branch-0.6.zip && \
    mv incubator-livy-branch-0.6 livy && \
    cd /home/livy && \
    mvn -q clean package -DskipTests && \
    mkdir /home/livy/logs && \
    cp /home/livy/conf/livy.conf.template /home/livy/conf/livy.conf && \
    sed -i 's|# livy.repl.enable-hive-context =|livy.repl.enable-hive-context = true|g' /home/livy/conf/livy.conf && \
    echo "Installing Livy ends" && \
    echo "Setting notebook config" && \
    mkdir /root/.sparkmagic && \
    cd /root/.sparkmagic && \
    echo '{  "kernel_python_credentials" : {    "username": "",    "password": "",    "url": "http://localhost:8998",    "auth": "None"  },  "kernel_scala_credentials" : {    "username": "",    "password": "",    "url": "http://localhost:8998",    "auth": "None"  },  "kernel_r_credentials": {    "username": "",    "password": "",    "url": "http://localhost:8998"  },  "logging_config": {    "version": 1,    "formatters": {      "magicsFormatter": {         "format": "%(asctime)s %(levelname)s %(message)s",        "datefmt": ""      }    },    "handlers": {      "magicsHandler": {         "class": "hdijupyterutils.filehandler.MagicsFileHandler",        "formatter": "magicsFormatter",        "home_path": "~/.sparkmagic"      }    },    "loggers": {      "magicsLogger": {         "handlers": ["magicsHandler"],        "level": "DEBUG",        "propagate": 0      }    }  },  "wait_for_idle_timeout_seconds": 15,  "livy_session_startup_timeout_seconds": 60,  "fatal_error_suggestion": "The code failed because of a fatal error. Some things to try: a) Make sure Spark has enough available resources for Jupyter to create a Spark context. b) Contact your Jupyter administrator to make sure the Spark magics library is configured correctly.   c) Restart the kernel.",  "ignore_ssl_errors": false,  "session_configs": {    "driverMemory": "1000M",    "executorCores": 2  },  "use_auto_viz": true,  "coerce_dataframe": true,  "max_results_sql": 2500,  "pyspark_dataframe_encoding": "utf-8",    "heartbeat_refresh_seconds": 30,  "livy_server_heartbeat_timeout_seconds": 0,  "heartbeat_retry_seconds": 10,  "server_extension_default_kernel_name": "pysparkkernel",  "custom_headers": {},    "retry_policy": "configurable",  "retry_seconds_to_sleep_list": [0.2, 0.5, 1, 3, 5],  "configurable_retry_policy_max_retries": 8}' > config.json && \
    mkdir -p /home/jupyter/jupyter_default_dir && \
    echo "c.NotebookApp.notebook_dir = '/home/jupyter/jupyter_default_dir'" > /root/.jupyter/jupyter_notebook_config.py && \
    echo '#!/bin/bash' >> /home/jupyter/jupyter_start.sh && \
    echo "nohup /home/livy/bin/livy-server &" >> /home/jupyter/jupyter_start.sh && \
    echo "/usr/local/bin/jupyter lab --allow-root --NotebookApp.token='' --NotebookApp.password='' --no-browser --ip=0.0.0.0" >> /home/jupyter/jupyter_start.sh && \
    chmod 777 /home/jupyter/jupyter_start.sh && \
    echo "Setting notebook config ends"

WORKDIR /glue
COPY . /glue
COPY log4j.properties /glue/conf/log4j.properties

RUN chmod 777 ~/.profile && \
    ~/.profile
RUN /glue/bin/glue-setup.sh

CMD [ "bash" ]