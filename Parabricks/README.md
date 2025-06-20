# Parabricks

NVIDIA Parabricks is a GPU-acclerated software suite for secondary analysis of next-generation sequencing (NGS) data.
Also known as Clara, Parabricks matches the results of popular open-source tools such as GATK.

## Installation

Parabricks is provided as a Docker image. On Palmetto, the Docker image has already been downloaded and converted to be run with Apptainer.

You can access and use the Parabricks container with Palmetto's module system.

```bash
$ module spider parabricks

------------------------------------------------------------------------------------------------------------------------------------------------
  ngc/parabricks:
------------------------------------------------------------------------------------------------------------------------------------------------
     Versions:
        ngc/parabricks/4.1.1-1
        ngc/parabricks/4.5.0-1

------------------------------------------------------------------------------------------------------------------------------------------------
  For detailed information about a specific "ngc/parabricks" package (including how to load the modules) use the module's full name.
  Note that names that have a trailing (E) are extensions provided by other modules.
  For example:

     $ module spider ngc/parabricks/4.5.0-1
------------------------------------------------------------------------------------------------------------------------------------------------
```

## Running Parabricks

The [installation requirements](https://docs.nvidia.com/clara/parabricks/latest/gettingstarted/installationrequirements.html) list the supported GPUs. Parabricks can run on `Any NVIDIA GPU that supports CUDA architecture 75, 80, 86, 89, 90, 100 or 120 and has at least 16GB of GPU RAM`. Many tools have defaults settings that require more than 16GB of VRAM which are documented on the installation requirements page.

On Palmetto, we have the following supported GPUs:

| GPU  | VRAM |
| ---- | ---- |
| A40  | 48GB |
| A100 | 40GB |
| A100 | 80GB |
| L40S | 48GB |
| H100 | 80GB |
| H200 | 80GB |

> **NOTE**: There are varying number of GPUs of each type with a different number of GPUs per server. Consult the [Hardware Table](https://docs.rcd.clemson.edu/palmetto/compute/hardware/) for more information.
> If you'd like to purchase a GPU node for use with Parabricks, [send us a ticket!](https://docs.rcd.clemson.edu/support/ticket/purchasing/?subject=Custom+Node+Purchase&purchase_type=compute&message=I+would+like+to+purchase+a+custom+compute+node+for+Nvidia+Parabricks.)