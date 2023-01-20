# S1-S2 simulations for bidomain and EMI model comparisons
This repository contains all source codes and the environment required to generate the data points from the unipolar strength-interval curves in "A comparison of the bidomain and EMI models in refractory cardiac tissue".

## Contents
Bash script for setting parameters and running simulations:
    run_bidomainEMI.sh

FreeFEM codes:
    Bidomain_solver.edp
    EMI_solver.edp

EMI mesh file for the mesh used in the study:
    3d_625cells_EMImesh.mesh

Cell model files (Gray & Pathmanathan 2016 rabbit action potential model):
    gray_pathmanathan_2016.h
    ff-cellmodel.cpp

MUMPS solver parameters file:
    ffmumps_fileparam.txt

## Accessing the container
A singularity container has been built to provide all dependencies for the codes and ensure consistency across machines. The container is available on the cloud via Sylabs. A prerequisite to using the container is to install Apptainer: https://apptainer.org/docs/admin/main/installation.html .

The container can be downloaded from a browser at https://cloud.sylabs.io/library/joyce-reimer/emi-bidomain-container/freefem_ubuntu_18_bc . 

Alternatively, it can be pulled using the command line via the following commands:

    singularity remote add --no-login Sylabs cloud.sylabs.io
    singularity remote list    # check that Sylabs is listed as an endpoint
    singularity remote use Sylabs
    singularity pull --arch amd64 library://joyce-reimer/emi-bidomain-container/freefem_ubuntu_18_bc:latest

### Launching the container
To launch the container, run

    apptainer shell --bind ./:/mnt freefem_ubuntu_18_bc.sif
    cd /mnt

from a terminal, within the working directory.

## Setting parameters
All parameters needed to carry out the experiments reported in the paper can be controlled using the bash script run_bidomainEMI.sh . 

To choose between running the bidomain or EMI model, change line 113 of the script. 

If changing between the two models, note the different rheobases (in variable "S1Magnitude").

### Changing domain size
The tissue dimensions are set to those used in the study. However, if a different domain size is desired, the bidomain model dimensions can be adjusted simply by changing the number of cells or cell dimensions in the bash script.

The EMI model cell number & dimensions are based on the mesh file; therefore, they must remain fixed, unless a new mesh file is created and input. Then the number of cells and cell dimensions should be changed as well to match the new mesh file.

## Running simulations

To start the bash script, run

    sh run_bidomainEMI.sh

from within the container. This will call the appropriate .edp file as well as any other necessary header files.

## Running in parallel
The bidomain code can be run in parallel by adjusting the "ranks" parameter to the desired number of cores. (8 is recommended for the default problem size.)

To run in serial, set ranks = 1.

Although the EMI code will run in parallel, it is not optimized to run this way. It is recommended to set ranks = 1 for the EMI model. 

## Viewing Output
Both codes output .txt files with values of the potential in mV at certain sample points in the domain (coordinates printed at top of file). These points are chosen to be on the cell membrane for EMI, and their locations are matched in the bidomain code for a fair comparison. To check whether an action potential occurred, open the txt output files and check the values of the potential. These files can also be used to create plots with MATLAB, python, etc.

For visualizations of the domain, each code outputs .vtu files that can be viewed in Paraview. With parallel computations, only the .pvtu files are needed as these contain all processor's .vtu files.

## Checkpointing
The codes are checkpointed. This feature allows the computations to be stopped before they are done and then restarted later, minimizing the amount of lost data.

When starting a computation from the beginning, the variable "restart" in the bash script should be set to 0. Then, if for any reason your simulations are stopped and you wish to resume them, set "restart=1" and run the bash script again. This will read all necessary files to restart the simulation without the need of many other changes. 

The user can choose the number of steps between checkpoints. Please keep in mind that, for large computations, frequent checkpointing can be expensive. Therefore, it is recommended to checkpoint only as often as necessary. To adjust the frequency of checkpointing, adjust the parameter "checkpointsteps" in the bash script to set the number of time steps between checkpoints. This value is set to 1000 by defulat.
