#!/usr/bin/env bash

# Bash script for submitting bidomain or EMI unipolar S1-S2 simulations
# To select model, change line 113

# WARNING: Run this script from within the provided container (see Readme for instructions)

# Parameters
#  The units of all parameters match those used in the FreeFem codes

# Cell and gap dimensions (mm)
#   For EMI, these must match dimensions used to generate mesh file. 
#   For bidomain, the cell dimensions are only used to generate a comparable domain size to EMI.

CL=0.155 #Cell length
CD=0.02 #Cell diameter
GL=0.005 #Gap length
GD=0.01 #Gap diameter
# Box length = CL+GL
# Box width = CD+GD/2
# Box height = CD+GD/2

# Number of cells
#   For EMI, must match number of cells used to generate mesh file.
NCellsInX=25
NCellsInY=25
NCellsInZ=1

# Domain size (not passed to run simulations)
length=`echo "scale=4; ($CL+$GL)*$NCellsInX" | bc -l` # (in x) 
width=`echo "scale=4; ($CD+$GL)*$NCellsInY" | bc -l` # (in y) 
height=`echo "scale=4; ($CD+$GL)*$NCellsInZ" | bc -l` # (in z) 

# Number of extrusions from 2D to 3D mesh (EMI only)
zlayers=4

# Electrode dimensions (mm)
E1length=0.5 
E1width=0.1
E1height=`echo "scale=4; $height" | bc -l` #Electrode thickness set equal to height of domain

# Electrode position
E1xmin=`echo "scale=4; $length/3" | bc -l`
E1ymin=`echo "scale=4; $width/3" | bc -l`
E1zmin=0.0

# Bidomain conductivities. Default is calibrated values. (µA mV^-1 mm^-1)
sigmaix=0.2525
sigmaiy=0.0222
sigmaiz=0.0222
sigmaex=0.821
sigmaey=0.215
sigmaez=0.215

# EMI conductivities (µA mV^-1 mm^-1)
sigmai=0.5
sigmae=2.0

# Capacitance (for EMI and bidomain)
Cm=0.01 # µF mm^-2

# Resistance (for EMI only)
RGap=0.15 # mV·mm^2 µA^-1

# Chi value (bidomain only)
chi=150.0 # mm^-1

# S1 stimulus timing (ms)
S1Start=0.0
S1Duration=2.0
S1Period=1000.0

#S1Magnitude (µA/µF)
S1Magnitude=120.0 #120 is bidomain rheobase; 115 is EMI rheobase

#S2 stimulus timing (ms)
S2Duration=2.0
S2Period=1000.0

#S2 Strength (µA/µF). Set a min, max, and increment to try out a range of values. 
MinS2Magnitude=120.0
MaxS2Magnitude=126.0
S2Increment=1.0

#S1-S2 Time Interval (ms)
S1S2Interval=150.0
CycleNumber=1

# Time parameters (ms)
tinitial=0.0
tfinal=180.0
timestepsize=0.1
timesubsteps=100
timeintegratorcellmodel="ForwardEuler" # choose "ForwardEuler" (default) or "RushLarsen" for higher stimulus magnitudes

# Space step (bidomain only)
meshsize=0.025 # mm

# Steps between plot and save data
steps=10

# MPI ranks for each job (bidomain only; for EMI, best to choose 1)
ranks=1

# Checkpointing and restart calculations
restart=0 # Set to 1 to restart from saved checkpointed state; 0 to start from initial state
checkpointsteps=1000 

# Before running simulations, we make sure the cell model is up to date
ff-c++ ff-cellmodel.cpp

# List of models to run  
Models="Bidomain" # Choose "Bidomain" and/or "EMI" to specify model

############################################################
# Run simulations 
############################################################

for model in $Models
do 
  # set paths
  codefilename="${model}_solver.edp"
  pathtocode="./$codefilename"
  pathtooutputfile="./$model/"
  pathtocheckpointfiles="${pathtooutputfile}checkpoints/"
  pathtovtufiles="${pathtooutputfile}VTU_Files/"
  pathtoterminaloutput="$pathtooutputfile/terminaloutput_$codefilename.txt"
  
  #make directories
  mkdir "./$model/" "$pathtocheckpointfiles" "$pathtovtufiles"
  
  # specify the path to the EMI mesh (for EMI only)
  pathtomeshfile="./3d_625cells_EMImesh.mesh"   

  # run simulation in parallel (extra parameters are simply ignored by codes)
  DomainParameters="-celllength $CL -celldiameter $CD -gaplength $GL -gapdiameter $GD -ncellsx $NCellsInX -ncellsy $NCellsInY -ncellsz $NCellsInZ"

  ElectricParameters="-sigmai $sigmai -sigmae $sigmae -sigmaix $sigmaix -sigmaiy $sigmaiy -sigmaiz $sigmaiz -sigmaex $sigmaex -sigmaey $sigmaey -sigmaez $sigmaez -membranecapacitance $Cm -gapcapacitance $Cm -capacitance $Cm -gapresistance $RGap -chi $chi"
  
  DiscretizationParameters="-ti $tinitial -tf $tfinal -timestepsize $timestepsize -timesubsteps $timesubsteps -meshsize $meshsize -$timeintegratorcellmodel 1"
  
  SpecificParameters="-e1length $E1length -e1width $E1width -e1height $E1height -e1xmin $E1xmin -e1ymin $E1ymin -e1zmin $E1zmin -S1Start $S1Start -S1Duration $S1Duration -S1Period $S1Period -S1Magnitude $S1Magnitude -S2Start $S1S2Interval -S2Duration $S2Duration -S2Period $S2Period -MinS2 $MinS2Magnitude -MaxS2 $MaxS2Magnitude -S2Increment $S2Increment -S1S2Interval $S1S2Interval -ncycles $CycleNumber" 

  MiscParameters="-PlotSteps $steps -Restart $restart -CheckPointSteps $checkpointsteps -meshfile $pathtomeshfile -outputdir $pathtooutputfile -checkpointsdir $pathtocheckpointfiles -vtudir $pathtovtufiles"
  
  ff-mpirun -np $ranks $pathtocode $DomainParameters $ElectricParameters $DiscretizationParameters $SpecificParameters $MiscParameters -v 0 | tee $pathtoterminaloutput
done
