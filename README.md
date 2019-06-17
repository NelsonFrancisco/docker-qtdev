# docker-qtdev
Dockerfile to create Qt images with a compilation environment
**Notice: This is experimental yet**
*******************************************************************
*******************************************************************

## Usage

### Start the container
```
$ docker-compose up
```
Will create a container with compiled Qt4 with an example on user `user` home folder.

### SSH into the container
The image is ready to receive ssh connections so you can browse and copy source files so you can compile your programs

```
$ ssh -p 2222 user@localhost
``` 
password is `user`

### Compile example

```shell
$ cd example
$ qmake
$ make
```
