# 设备划分

We have use two physics device make environments.

  - Dell PowerEdge 640:  used for application setup. (include dpe,dcp,....)
  - Dell PowerEdge 740:  used for database setup.

## Device info 

| Device | CPU | Memory| disk | IP|
| ------ | ------ | -----| ----| ----|
| Dell PowerEdge 740 | 80vcpu | 256G | 2048GB|
| Dell PowerEdge 640 | 48vcpu | 128G | 1028GB|

## Visual Device info

- dell 740 (include 2 visual machine)

| Type | Name | CPU | Memory | Disk| IP|
| ----|----| -----| -----| ----|-----|
| Database | db_res1 | 40vCpu | 126GB| 900GB|
| Database | db_res2 | 40vCpu | 126GB| 900GB|

- dell 640 (include * visual machine)

| Type | Name | CPU | Memory | Disk| IP|
| ----|----| -----| -----| ----| -|
| Docker Manager|dps-docker-manager01|2vcpu|4GB|50GB|10.1.10.190
| Docker Manager|dps-docker-manager02|2vcpu|4GB|50GB|10.1.10.192
| Docker Manager|dps-docker-manager03|2vcpu|4GB|50GB|10.1.10.194
| Docker Worker|dps-docker01|10vcpu|32GB|200GB|10.1.10.191
| Docker Worker|dps-docker02|10vcpu|32GB|200GB|10.1.10.193
| Docker Worker|dps-docker03|10vcpu|32GB|200GB|10.1.10.195
| MDS Server|dps-mds|4vcpu|8GB|70GB|10.1.10.196
| HA Server|dps-haproxy|4vcpu|4GB|40GB|10.1.10.199

## Setup
Install docker, ssl cert, and stop firewall service.

### Disable SELinux
check SeLinux status use the command `sestatus`,if the selinux status is `enforcing`, you can use follow step disabled it.
___
open the file `/etc/sysconfig/selinux` as follow:
```
$ vi /etc/sysconfig/selinx
```
Then change the directive `SELinux=enforcing` to `SELinux=disabled` as follew:
```
SELinux=disabled
```
reboot machine and use `sestatus` check selinux status.

### Disable firewall
```
$ sudo systemctl stop firewalld   # stop firewalld service
$ sudo systemctl disable firewalld # disable firewalld auto start
```

### Install DockerCE
Install docker ce on all visual device with which type is docker.
1. install required packages.
```
$sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```
2. use the follow command setup the stable repository.
```
$sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```
3. Install docker ce 17.12.0, show available packages use `yum list docker-ce --showduplicates` command.
```
$sudo yum install -y docker-ce-17.12.0.ce
```

>>> Note: you can find full install guite in [docker](https://docs.docker.com/install/linux/docker-ce/centos/#install-docker-ce-1).

4. Start up docker service
```
$ sudo systemctl start docker
```

5. install bash-completion
```
$ yum install -y bash-completion
```
After installed bash-completion, logout current session and re-login.

### SSL certificate setting
Our docker registry domain is  `asc.registry.com:5043`, we must put the CA key into all work hosts.The ca key location on `/etc/docker` dir.

1. create ssl dir
```
$ sudo mkdir -p /etc/docker/certs.d/asc.registry.com:5043
```
2. download ca key
```
$ sudo cd /etc/docker/certs.d/asc.registry.com:5043
$ sudo curl -L https://raw.githubusercontent.com/dolica/documents/master/DPS-env-script/ca.crt --output ca.crt --silent
```
3. login private docker registry, (admin/admin123 is username/passwd).
```
$ docker login asc.registry.com:5043 --username admin --password admin123
```

### docker swarm cluster 
When all host installed docker-ce, you can set up docker swarm cluster in swarm mode.
1. init docker swarm
```
$ docker swarm init --availability drain   #init docker swarm cluster
```
2. add worker node and other manager
On other docker nodes, use follow command join the new cluster.
```
$   docker swarm join --token [token]
```
You can use `docker swarm join-token [manager|worker]` command on the manager node to get the join token.

3. Change manager node availability
```
$ docker node update [node] --availability [drain|active|pause]
```

4. create a new overlay network
```
$ docker network create dps-res-net \           #network name is dps-res-net
--driver=overlay    \           #set driver type is overlay for multinode
--subnet=172.10.0.0/16 \        #set subnet
--ip-range=172.10.5.0/24 \
--gateway=172.10.5.254
```

# Install Docker compose
```
 sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

 sudo chmod +x /usr/local/bin/docker-compose
```


You can also:
  - Import and save files from GitHub, Dropbox, Google Drive and One Drive
  - Drag and drop markdown and HTML files into Dillinger
  - Export documents as Markdown, HTML and PDF

Markdown is a lightweight markup language based on the formatting conventions that people naturally use in email.  As [John Gruber] writes on the [Markdown site][df1]

> The overriding design goal for Markdown's
> formatting syntax is to make it as readable
> as possible. The idea is that a
> Markdown-formatted document should be
> publishable as-is, as plain text, without
> looking like it's been marked up with tags
> or formatting instructions.

This text you see here is *actually* written in Markdown! To get a feel for Markdown's syntax, type some text into the left window and watch the results in the right.

### Tech

Dillinger uses a number of open source projects to work properly:

* [AngularJS] - HTML enhanced for web apps!
* [Ace Editor] - awesome web-based text editor
* [markdown-it] - Markdown parser done right. Fast and easy to extend.
* [Twitter Bootstrap] - great UI boilerplate for modern web apps
* [node.js] - evented I/O for the backend
* [Express] - fast node.js network app framework [@tjholowaychuk]
* [Gulp] - the streaming build system
* [Breakdance](http://breakdance.io) - HTML to Markdown converter
* [jQuery] - duh

And of course Dillinger itself is open source with a [public repository][dill]
 on GitHub.

### Installation

Dillinger requires [Node.js](https://nodejs.org/) v4+ to run.

Install the dependencies and devDependencies and start the server.

```sh
$ cd dillinger
$ npm install -d
$ node app
```

For production environments...

```sh
$ npm install --production
$ NODE_ENV=production node app
```

### Plugins

Dillinger is currently extended with the following plugins. Instructions on how to use them in your own application are linked below.

| Plugin | README |
| ------ | ------ |
| Dropbox | [plugins/dropbox/README.md] [PlDb] |
| Github | [plugins/github/README.md] [PlGh] |
| Google Drive | [plugins/googledrive/README.md] [PlGd] |
| OneDrive | [plugins/onedrive/README.md] [PlOd] |
| Medium | [plugins/medium/README.md] [PlMe] |
| Google Analytics | [plugins/googleanalytics/README.md] [PlGa] |


### Development

Want to contribute? Great!

Dillinger uses Gulp + Webpack for fast developing.
Make a change in your file and instantanously see your updates!

Open your favorite Terminal and run these commands.

First Tab:
```sh
$ node app
```

Second Tab:
```sh
$ gulp watch
```

(optional) Third:
```sh
$ karma test
```
#### Building for source
For production release:
```sh
$ gulp build --prod
```
Generating pre-built zip archives for distribution:
```sh
$ gulp build dist --prod
```
### Docker
Dillinger is very easy to install and deploy in a Docker container.

By default, the Docker will expose port 8080, so change this within the Dockerfile if necessary. When ready, simply use the Dockerfile to build the image.

```sh
cd dillinger
docker build -t joemccann/dillinger:${package.json.version}
```
This will create the dillinger image and pull in the necessary dependencies. Be sure to swap out `${package.json.version}` with the actual version of Dillinger.

Once done, run the Docker image and map the port to whatever you wish on your host. In this example, we simply map port 8000 of the host to port 8080 of the Docker (or whatever port was exposed in the Dockerfile):

```sh
docker run -d -p 8000:8080 --restart="always" <youruser>/dillinger:${package.json.version}
```

Verify the deployment by navigating to your server address in your preferred browser.

```sh
127.0.0.1:8000
```

#### Kubernetes + Google Cloud

See [KUBERNETES.md](https://github.com/joemccann/dillinger/blob/master/KUBERNETES.md)


### Todos

 - Write MORE Tests
 - Add Night Mode

License
----

MIT


**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>
