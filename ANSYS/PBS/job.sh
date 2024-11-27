#!/bin/bash
#PBS -N ANSYSdis
#PBS -l select=2:ncpus=4:mpiprocs=4:mem=11gb:interconnect=fdr
#PBS -l walltime=1:00:00
#PBS -j oe

set -e

# Uncomment the next line for bash trace mode (debugging).
#set -x

module purge
module add ansys/22.2

# This pbsdsh command will make sure that $TMPDIR is setup on each other node
pbsdsh sleep 5

cd "$PBS_O_WORKDIR"

machines=$(uniq -c "$PBS_NODEFILE" | awk '{print $2":"$1}' | tr '\n' :)
machines=${machines::-1}

SCRATCH=$TMPDIR/ansys-run

echo "Setting up scratch dirs..."
for node in $(uniq "$PBS_NODEFILE")
do
    ssh $node "rm -rf '$SCRATCH'"
    ssh $node "mkdir -p '$SCRATCH'"
    ssh $node "cp $PBS_O_WORKDIR/input.txt $SCRATCH"
done

cd "$SCRATCH"

# Create an SSH stub that unsets LD_LIBRARY_PATH. This is needed because Ansys
# adds a bunch of garbage to LD_LIBRARY_PATH that conflicts with the host ssh.
mkdir -p "$SCRATCH/bin"
cat << EOF > "$SCRATCH/bin/ssh"
#!/bin/bash
unset LD_LIBRARY_PATH
/bin/ssh "\$@"
EOF
chmod +x "$SCRATCH/bin/ssh"
OLD_PATH=$PATH
export PATH="$SCRATCH/bin:$PATH"


echo "Running Ansys, machines= $machines ..."
set +e
ansys222 \
    -mpi openmpi \
    -dir "$SCRATCH" \
    -j EXAMPLE \
    -s read -l en-us -b \
    -i input.txt -o output.txt \
    -dis -machines "$machines"
set -e

# Restore PATH (we're about to delete that ssh stub).
export PATH="$OLD_PATH"

echo "Ansys done, coping files"
for node in $(uniq "$PBS_NODEFILE")
do
    ssh $node "cp -r $SCRATCH/* $PBS_O_WORKDIR"
    ssh $node "rm -rf $SCRATCH"
done
echo "Done!"
