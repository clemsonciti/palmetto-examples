## Gephi



Gephi is an interactive visualization and exploration platform for all kinds of networks and 
complex systems, dynamic and hierarchical graphs.  At this time, we don't have Gephi setup as a 
software module on Palmetto, but downloading and installing it in your own `/home` or `/newscratch` 
directory (and running it from that location) is easy to do.  Below are the procedures I used to do this:

### Download and Setup the Gephi Binary

    wget https://launchpad.net/gephi/0.8/0.8.2beta/+download/gephi-0.8.2-beta.tar.gz
    tar -zxf gephi-0.8.2-beta.tar.gz

Now, the gephi binary is installed in `~/gephi/bin`.

### Running Gephi

Connect to Palmetto with X11 tunneling enabled so you can "tunnel" the GUI running on Palmetto 
through your SSH connection to your desktop:

    ssh -X galen@login.palmetto.clemson.edu

Once you're logged-in to Palmetto, you'll need to launch an interactive job with X11 tunneling 
enabled.  Be sure to request an allocation with enough memory for Gephi to handle your input data 
properly (here, I'm requesing 31 GB RAM):

    qsub -I -X -l select=1:ncpus=4:mem=31gb,walltime=6:00:00

If you are using a Windows system, you'll need to launch a local Xserver (like Xming) so your 
system can display the tunneled GUI information.

Once your local Xserver is ready, launch the Gephi GUI in your interactive session on Palmetto:

    /home/galen/gephi/bin/gephi

Now, I can browse for data I have stored in my directories on Palmetto.  If your data is stored on 
your local workstation, you must move that data to Palmetto so you can open it with Gephi.

You may experience a short delay as the GUI is generated and tunneled to your desktop.  Responsiveness 
between your local workstation and the tunneled GUI may be a bit slow/laggy, but the compute operations 
taking place on that Palmetto compute node are not delayed.

![Gephi]({{site.baseurl}}/images/gephi.1.png)

