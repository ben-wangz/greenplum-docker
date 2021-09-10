# greenplum-docker

1. docker image: [dockerhub](https://hub.docker.com/r/wangz2019/greenplum-docker)
2. source code: [github](https://github.com/ben-wangz/greenplum-docker)
3. docs: [greenplum-docker-docs](https://ben-wangz.github.io/greenplum-docker/)

## what's it

1. a playground for greenplum
2. completely with docker environment
3. NOT for production environments

## limitations

1. only support linux/amd64
    * because greenplum 6.8.1 only support x86_64
    * refer to [greenplum-db/gpdb/release](https://github.com/greenplum-db/gpdb/releases/tag/6.8.1)
2. we change some codes of greenplum to support chinese characters
3. `sysctl -p` which will optimize the performance was removed
4. cannot start with k8s cluster created by kind

## todo list

1. remove step of `init greenplum service` to start service
2. test with jdbc interface of greenplum

## usage

### requirements

* system os and arch
    + linux & amd64 (tested with centos 7)
    + mac & amd64 (not tested, but it will be okay)
    + windows & x86_64 (not tested, but it will be okay)
    + mac & arm64 (not work)
* jdk 8 or higher to run gradle scripts
* docker to build/run greenplum

### prepare
* build docker image
    + optional(you can also download it from docker hub)
    + you need a buildx environment: [develop with docker](https://blog.geekcity.tech/#/docs/develop.with.docker)
        1. make sure your buildx environment is ready: `docker buildx ls`
        2. make sure docker registry is ready if not pushing images to docker hub: `docker ps -a`
* without docker hub 
    + ```shell
      export IMAGE_REPOSITORY=localhost:5000/greenplum-docker && ./gradlew :buildDockerImage
      ```
* with docker hub
    + ```shell
      export IMAGE_REPOSITORY=wangz2019/greenplum-docker && ./gradlew :buildDockerImage
      ```

### single node
1. start service
    * ```shell
      export IMAGE_REPOSITORY=localhost:5000/greenplum-docker && ./gradlew :runSingleton
      ```
    * change IMAGE_REPOSITORY, whose default value is 'wangz2019/greenplum-docker', to use your own image
    * ssh service will be exposed with port 1022
    * greenplum master service will be exposed with port 5432, which will be working after `init greenplum service`
2. test service
    * ```shell
      export IMAGE_REPOSITORY=localhost:5000/greenplum-docker && ./gradlew :testSingletonGreenPlumService
      ```
    * what does test do?
        1. create a database named `mydatabase`
        2. create a table named `test_table` in `mydatabase`
        3. load some data into `mydatabase.test_table` with `gpload`
        4. select data from `mydatabase.test_table` before and after loading
        5. (TODO) check data
3. stop service
    * ```shell
      ./gradlew :stopSingleton
      ```
---

### cluster
1. create network
    + optional
    + ```shell
      ./gradlew :createNetwork
      ```

2. start service
    * run master with slave docker container
        + ```shell
          ./gradlew :runMasterWithSlaveDockerContainer
          ```
        + ssh service will be exposed with port 1022
        + greenplum master service will be exposed with port 5432, which will be working after `init greenplum service`
    * init master with cluster service
        + ```shell
          ./gradlew :initMasterWithSlaveGpService
          ```
        + idempotent operation
    * run cluster docker container (stop master with slave docker first)
        + ```shell
          ./gradlew :runClusterDockerContainer
          ```
        + ssh service will be exposed with port 1022
        + greenplum master service will be exposed with port 5432, which will be working after `init greenplum service`
    * init cluster service
        + ```shell
          ./gradlew :initClusterGpService
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
      ./gradlew :stopMasterWithSlaveDockerContainer
      ```
    * ```shell
      ./gradlew :stopClusterDockerContainer
      ```

5. you can also jump into the container
    * ```shell
      docker exec --user gpadmin -it greenplum bash
      ```
