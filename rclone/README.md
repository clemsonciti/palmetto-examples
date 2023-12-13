# `rclone`

`rclone` is a tool that can be used to copy local files to many cloud storage
providers.

## Getting Started

To get started, you will need to configure and authorize `rclone` with your
storage provider. We provide examples for the following providers:

1. [Google Drive](./gdrive/README.md)
1. [Microsoft OneDrive](./onedrive/README.md)
1. [Box](./box/README.md)

### Using rclone

Data transfer (including `rclone`) should be done on a data transfer node (DTN). `ssh` into one of the 
DTN nodes listed on
the [Official RCD Instructions](https://docs.rcd.clemson.edu/palmetto/transfer/#sftp).

Load the `rclone` module:

```
module load rclone/1.62.2-gcc/9.5.0
```

You can list the available storage providers that you have configured:

```
rclone listremotes
```

You can check the content of the remote host **gmaildrive**:

```
rclone ls gmaildrive:/
rclone lsd gmaildrive:/
```

As a note, `rclone ls` will show files and `rclone lsd` will show directories,
which differs from the usual `ls` workflow.

You can use `rclone` to (for example) copy a file from Palmetto to any folder in
your Google Drive:

```
rclone copy /path/to/file/on/palmetto gmaildrive:/path/to/folder/on/drive
```

Or if you want to copy to a specific destination on Google Drive back to
Palmetto:

```
rclone copy gmaildrive:/path/to/folder/on/drive /path/to/file/on/palmetto
```

Additional `rclone` commands can be found [here](http://rclone.org/docs/).

## Using tmux

If you need to transfer a lot of data between Palmetto and cloud storage, it
might take hours or days. The transfer will stop if you quit your `ssh` session
(and if you log into the data ransfer node again and resume `rclone copy`, it
will pick up from where it stopped). If you want the data transfer to run on the
background, you can use the tool called `tmux` which is installed on Palmetto.

First, connect to `xfer02`:

```
ssh xfer02
```

Then, load the `tmux` module:

```
module load tmux/3.3
```

Then, you can start a new tmux session. Let's give it a name, for example,
"data_transfer":

```
tmux new -s data_transfer
```

Your screen will slightly change: you will see the usual prompt, and name of
your tmux session on the bottom of the screen. This session will run on the
background even if you disconnect from Palmetto.

Inside the session, you can load the rclone module, and do `rclone copy` as
described in the previous step.

If you want to leave the session (but keep it running), type `Ctrl+b d`. If you
want to re-attach to the session, you can type

```
tmux attach-session -t data_transfer
```

To see the names of all running sessions, type `tmux ls`. To kill a session,
attach to it, and then type `Crtl+b x`.

`tmux` is a very powerful tool which can be used for many other purposes; you
can find a quick guide to `tmux`
[here](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/).
