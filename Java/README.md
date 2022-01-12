## Java

The Java Runtime Environment (JRE) version 1.6.0_11 is currently available cluster-wide on Palmetto. 
If a user needs a different version of Java, or if the Java Development Kit (JDK, which includes the JRE) 
is needed, that user is encouraged to download and install Java (JRE or JDK) for herself. Below is a brief 
overview of installing the JDK in a user's /home directory.

### JRE vs. JDK

The JRE is basically the Java Virtual Machine (Java VM) that provides a platform for running your 
Java programs. The JDK is the fully featured Software Development Kit for Java, including the JRE, 
compilers, and tools like JavaDoc and Java Debugger used to create and compile programs.

Usually, when you only care about running Java programs, the JRE is all you'll need. If you are planning 
to do some Java programming, you will need the JDK.

### Downloading the JDK

The JDK cannot be downloaded directly using the wget utility because a user must agree to Oracle's 
Java license ageement when downloading.  So, download the JDK using a web browser and transfer the 
downloaded  `jdk-7uXX-linux-x64.tar.gz`  file to your `/home` directory on Palmetto using `scp`, `sftp`, 
or FileZilla:

    scp  jdk-7u45-linux-x64.tar.gz galen@login.palmetto.clemson.edu:/home/galen
    jdk-7u45-linux-x64.tar.gz                                                             100%  132MB  57.7KB/s   38:58

### Installing the JDK

The JDK is distributed in a Linux x86_64 compatible binary format, so once it has been unpacked, it 
is ready to use (no need to compile).  However, you will need to setup your environment for using this 
new package by adding lines similar to the following at the end of your `~/.bashrc` file:

    export JAVA_HOME=/home/galen/jdk1.7.0_45
    export PATH=$JAVA_HOME/bin:$PATH
    export MANPATH=$JAVA_HOME/man:$MANPATH

Once this is done, you can log-out and log-in again or simply source your `~/.bashrc` file and then 
you'll be ready to begin using your new Java installation.

