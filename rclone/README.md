## rclone


`rclone` is a command-line program that can be used
to sync files and folders to and from cloud services
such as Google Drive, Amazon S3, Dropbox, and [many others](http://rclone.org/).

In this example,
we will show how to use `rclone` to sync files to a Google Drive account,
but the official documentation has specific instructions for other services.

### Setting up rclone for use with Google Drive on Palmetto

To use `rclone` with any of the above cloud storage services,
you must perform a one-time configuration.
You can configure `rclone` to work with as many services as you like.

For the one-time configuration, you will need to
[log-in with X11 tunneling enabled](https://www.palmetto.clemson.edu/palmetto/basic/x11_tunneling/).
After you get on a compute node, load the `rclone` module:

~~~
module add rclone/1.51.0-gcc/8.3.1
~~~

After `rclone` is loaded, you must set up a "remote". In this case,
we will configure a remote for Google Drive. You can create and manage a separate
remote for each cloud storage service you want to use.
Start by entering the following command:

~~~
rclone config
~~~

This will bring the lost of options:
~~~
e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> 
~~~

Hit **n** then Enter to create a new remote host.

```
name>
```

Provide any name for this remote host. For example: **gmaildrive**

```
Choose a number from below, or type in your own value
 1 / 1Fichier
   \ "fichier"
 2 / Alias for an existing remote
   \ "alias"
 3 / Amazon Drive
   \ "amazon cloud drive"
 4 / Amazon S3 Compliant Storage Provider (AWS, Alibaba, Ceph, Digital Ocean, Dreamhost, IBM COS, Minio, etc)
   \ "s3"
 5 / Backblaze B2
   \ "b2"
 6 / Box
   \ "box"
 7 / Cache a remote
   \ "cache"
 8 / Citrix Sharefile
   \ "sharefile"
 9 / Dropbox
   \ "dropbox"
10 / Encrypt/Decrypt a remote
   \ "crypt"
11 / FTP Connection
   \ "ftp"
12 / Google Cloud Storage (this is not Google Drive)
   \ "google cloud storage"
13 / Google Drive
   \ "drive"
14 / Google Photos
   \ "google photos"
15 / Hubic
   \ "hubic"
16 / In memory object storage system.
   \ "memory"
17 / JottaCloud
   \ "jottacloud"
18 / Koofr
   \ "koofr"
19 / Local Disk
   \ "local"
20 / Mail.ru Cloud
   \ "mailru"
21 / Mega
   \ "mega"
22 / Microsoft Azure Blob Storage
   \ "azureblob"
23 / Microsoft OneDrive
   \ "onedrive"
24 / OpenDrive
   \ "opendrive"
25 / Openstack Swift (Rackspace Cloud Files, Memset Memstore, OVH)
   \ "swift"
26 / Pcloud
   \ "pcloud"
27 / Put.io
   \ "putio"
28 / QingCloud Object Storage
   \ "qingstor"
29 / SSH/SFTP Connection
   \ "sftp"
30 / Sugarsync
   \ "sugarsync"
31 / Transparently chunk/split large files
   \ "chunker"
32 / Union merges the contents of several remotes
   \ "union"
33 / Webdav
   \ "webdav"
34 / Yandex Disk
   \ "yandex"
35 / http Connection
   \ "http"
36 / premiumize.me
   \ "premiumizeme"
Storage>
```

Provide any number for the remote source. For example choose number **13** for Google drive. In the following questions, always accept the default value:

```
Google Application Client Id - leave blank normally.
client_id> # Enter to leave blank
Google Application Client Secret - leave blank normally.
client_secret> # Enter to leave blank
Scope that rclone should use when requesting access from drive.
Enter a string value. Press Enter for the default ("").
```

Then, it will ask you for access type. You will most likely want full access, so type **drive**:

```
Choose a number from below, or type in your own value
 1 / Full access all files, excluding Application Data Folder.
   \ "drive"
 2 / Read-only access to file metadata and file contents.
   \ "drive.readonly"
   / Access to files created by rclone only.
 3 | These are visible in the drive website.
   | File authorization is revoked when the user deauthorizes the app.
   \ "drive.file"
   / Allows read and write access to the Application Data folder.
 4 | This is not visible in the drive website.
   \ "drive.appfolder"
   / Allows read-only access to file metadata but
 5 | does not allow any access to read or download file content.
   \ "drive.metadata.readonly"
scope> 
```

For the next few questions, accept defaults. At some point, it will ask you for "remote config":

```
Remote config
Use auto config?
 * Say Y if not sure
 * Say N if you are working on a remote or headless machine or Y didn't work
y) Yes
n) No
y/n>
```

Type **y** for "Yes". This should open up a web browser -- you might have to wait several minutes. In the browser, log into your storage account. Then, accept to let **rclone** access your Goolge drive. Once this is done, the browser will ask you to go back to rclone to continue.

```
Got code
--------------------
[gmaildrive]
client_id =
client_secret =
token = {"access_token":"xyz","token_type":"Bearer","refresh_token":"xyz","expiry":"yyyy-mm-ddThh:mm:ss"}
--------------------
y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d>
```

Select **y** to finish configure this remote host.
The **gmaildrive** host will then be created.

```
Current remotes:

Name                 Type
====                 ====
gmaildrive           drive

e) Edit existing remote
n) New remote
d) Delete remote
q) Quit config
e/n/d/q>
```

After this, you can quit the config using **q**, and exit the compute node:

~~~
exit
~~~

### Using rclone

Data transfer (including `rclone`) should be done on the data transfer node (`xfer01` or `xfer02`). Log into Palmetto as usual, and then connect to the data transfer node:

~~~
ssh xfer01
~~~

Log with your Palmetto password and DUO; once logged-in, load the `rclone` module:

~~~
module add rclone/1.51.0-gcc/8.3.1
~~~

You can check the content of the remote host **gmaildrive**:

```
rclone ls gmaildrive:
rclone lsd gmaildrive:
```

You can use `rclone` to (for example) copy a file from Palmetto to any folder in your Google Drive:

~~~
rclone copy /path/to/file/on/palmetto gmaildrive:/path/to/folder/on/drive
~~~

Or if you want to copy to a specific destination on Google Drive back to Palmetto:

~~~
rclone copy gmaildrive:/path/to/folder/on/drive /path/to/file/on/palmetto
~~~

Additional `rclone` commands can be found [here](http://rclone.org/docs/).


### Using tmux

If you need to transfer a lot of data between Palmetto and cloud storage, it might take hours or days. The transfer will stop if you quit your `ssh` session (and if you log into the data ransfer node again and resume `rclone copy`, it will pick up from where it stopped). If you want the data transfer to run on the background, you can use the tool called `tmux` which is installed on Palmetto. 

First, connect to `xfer01` (or `xfer02`):

~~~
ssh xfer01
~~~

Then, load the `tmux` module:

~~~
module load tmux/3.3
~~~

Then, you can start a new tmux session. Let's give it a name, for example, "data_transfer":

~~~
tmux new -s data_transfer
~~~

Your screen will slightly change: you will see the usual prompt, and name of your tmux session on the bottom of the screen. This session will run on the background even if you disconnect from Palmetto.

Inside the session, you can load the rclone module, and do `rclone copy` as described in the previous step.

If you want to leave the session (but keep it running), type `Ctrl+b d`. If you want to re-attach to the session, you can type

~~~
tmux attach-session -t data_transfer
~~~

To see the names of all running sessions, type `tmux ls`. To kill a session, attach to it, and then type `Crtl+b x`. 

`tmux` is a very powerful tool which can be used for many other purposes; you can find a quick guide to `tmux` (here)[https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/].
