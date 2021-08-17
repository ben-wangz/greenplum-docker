# greenplum-docker

1. docker image: [dockerhub](https://hub.docker.com/r/wangz2019/greenplum-docker)
2. source code: [github](https://github.com/ben-wangz/greenplum-docker)
3. docs: [greenplum-docker-docs](https://ben-wangz.github.io/greenplum-docker/)

## what's it

1. a playground for greenplum
2. single node with one master and one segment
3. completely with docker environment
4. NOT for production environments

## limitations

1. only support linux/amd64
    * because greenplum 6.8.1 only support x86_64
    * refer to [greenplum-db/gpdb/release](https://github.com/greenplum-db/gpdb/releases/tag/6.8.1)
2. cannot display chinese characters correctly(os level)
3. we change some codes of greenplum to support chinese characters
4. `sysctl -p` which will optimize the performance was removed

## todo list

1. remove step of `init greenplum service` to start service
2. display chinese characters correctly
3. test with jdbc interface of greenplum

## usage

1. requirements
    * system os and arch
        + linux & amd64 (tested with centos 7)
        + mac & amd64 (not tested, but it will be okay)
        + windows & x86_64 (not tested, but it will be okay)
        + mac & arm64 (not work)
    * jdk 8 or higher to run gradle scripts
    * docker to build/run greenplum
2. start service
    * build docker image
        + optional
        + ```shell
          ./gradlew :buildDockerImage
          ```
    * run docker container
        + ```shell
          ./gradlew :runDockerContainer
          ```
        + ssh service will be exposed with port 1022
        + greenplum master service will be exposed with port 5432, which will be working after `init greenplum service`
    * init greenplum service
        + ```shell
          ./gradlew :initGpService
          ```
        + idempotent operation
3. test service
    * ```shell
      ./gradlew :testWithGpload
      ```
    * what does test do?
        1. create a database named `mydatabase`
        2. create a table named `test_table` in `mydatabase`
        3. load some data into `mydatabase.test_table` with `gpload`
        4. select data from `mydatabase.test_table` before and after loading
        5. (TODO) check data
4. stop service
    * ```shell
      ./gradlew :stopDockerContainer
      ```
5. you can also jump into the container
    * ```shell
      docker exec --user gpadmin -it greenplum bash
      ```
