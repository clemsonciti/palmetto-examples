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
$ module add rclone/1.51.0-gcc/8.3.1
~~~

After `rclone` is loaded, you must set up a "remote". In this case,
we will configure a remote for Google Drive. You can create and manage a separate
remote for each cloud storage service you want to use.
Start by entering the following command:

~~~
$ rclone config

n) New remote
q) Quit config
n/q>
~~~

Hit **n** then Enter to create a new remote host

```
name>
```

Provide any name for this remote host. For example: **gmaildrive**

```
What type of source is it?
Choose a number from below
 1) amazon cloud drive
 2) drive
 3) dropbox
 4) google cloud storage
 5) local
 6) s3
 7) swift
type>
```

Provide any number for the remote source. For example choose number **2** for goolge drive.

```
Google Application Client Id - leave blank normally.
client_id> # Enter to leave blank
Google Application Client Secret - leave blank normally.
client_secret> # Enter to leave blank

Remote config
Use auto config?
 * Say Y if not sure
 * Say N if you are working on a remote or headless machine or Y didn't work
y) Yes
n) No
y/n>
```

Use **y** if you are not sure

```
If your browser doesn't open automatically go to the following link: http://127.0.0.1:53682/auth
Log in and authorize rclone for access
Waiting for code...
```

This will open the Firefox web browser, allowing you to log-in to your Google account.
Enter your username and password then accept to let **rclone** access your Goolge drive.
Once this is done, the browser will ask you to go back to rclone to continue.

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

After this, you can quit the config using **q**, kill the job and exit this `ssh` session:

~~~
$ exit
~~~

### Using rclone

Whenever transfering files (using `rclone` or otherwise), login to the transfer node `xfer01-ext.palmetto.clemson.edu`.

- In MobaXterm, create a new ssh session with **xfer01-ext.palmetto.clemson.edu** as the Remote host
- In MacOS, open new terminal and `ssh user@xfer01-ext.palmetto.clemson.edu`

Once logged-in, load the `rclone` module:

~~~
$ module add rclone/1.51.0-gcc/8.3.1
~~~

You can check the content of the remote host **gmaildrive**:

```
$ rclone ls gmaildrive:
$ rclone lsd gmaildrive:
```

You can use `rclone` to (for example) copy a file from Palmetto to any folder in your Google Drive:

~~~
$ rclone copy /path/to/file/on/palmetto gmaildrive:/path/to/folder/on/drive
~~~

Or if you want to copy to a specific destination on Google Drive back to Palmetto:

~~~
$ rclone copy gmaildrive:/path/to/folder/on/drive /path/to/file/on/palmetto
~~~

Additional `rclone` commands can be found [here](http://rclone.org/docs/).
