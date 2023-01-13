#!/usr/bin/env bash

# Bash script for submitting unipolar simulations
# WARNING: run this script from a screen session

# Parameters
# The units of all paramters match the units listed in the FreeFem codes
# that this script
# Cell and gap dimensions
# Box length = CL+GL
# Box width = CD+GD/2
# Box height = CD+GD/2
CL=0.155
CD=0.02
GL=0.005
GD=0.01

# Number of cells
NCellsInX=25 #25 #50
NCellsInY=25 #25 #50
NCellsInZ=1
# domain size: (not passed to run simulations)
length=`echo "scale=4; ($CL+$GL)*$NCellsInX" | bc -l` # (in x) 
width=`echo "scale=4; ($CD+$GL)*$NCellsInY" | bc -l` # (in y) 
height=`echo "scale=4; ($CD+$GL)*$NCellsInZ" | bc -l` # (in z) 

# Number of extrusions from 2D to 3D mesh (EMI only)
zlayers=4

# electrode dimensions
E1length=0.5 #0.5 #`echo "scale=4; $length/3" | bc -l`
E1width=0.1 #0.1 #`echo "scale=4; $width/3" | bc -l`

# electrode location (bottom left corner)
E1xmin=`echo "scale=4; $length/3" | bc -l`
E1ymin=`echo "scale=4; $width/3" | bc -l`
# no need to define and pass E1xmax or E1ymax
# E1xmax = E1xmin+E1length
# E1ymax = E1ymin+E1width 

# bidomain conductivities (calibrated values)
sigmaix=0.2525
sigmaiy=0.0222
sigmaiz=0.0222
sigmaex=0.821
sigmaey=0.215
sigmaez=0.215

# EMI conductivities
sigmai=0.5
sigmae=2.0

# capacitance (for EMI and bidomain)
Cm=0.01

# resistance (for EMI only)
RGap=0.15

# chi value (bidomain only)
chi=150.0

# Applied stimulus values
S1Start=0.0
S1Duration=2.0
S1Period=1000.0
MinS1Magnitude=119.0
MaxS1Magnitude=120.0
S2Start=148.0
S2Duration=2.0
S2Period=1000.0
MinS2Magnitude=105.0
MaxS2Magnitude=105.4
MinS1S2Interval=148.0
MaxS1S2Interval=148.4
CycleNumber=1

# time parameters
tinitial=0.0
tfinal=70.0
timestepsize=0.1
timesubsteps=100
timeintegratorcellmodel="ForwardEuler" # choose ForwardEuler (default) or RushLarsen

# space parameters
meshsize=0.025 # (bidomain only)

# steps between plot and save data
steps=10000

# MPI ranks for each job
ranks=8

# checkpoint and restart calculations
restart=0 # 1 to restart from saved checkpointed state; 0 to start from initial state
checkpointsteps=2000

# run simulations
# before running simulations, make sure the cell model is up to date
ff-c++ ff-cellmodel.cpp

# list of cases to run (case sensitive)
Models="3d-bidomain" # 2d-bidomain 3d-bidomain 3d-emi
ElectrodeType="CellModel" # CellModel DirichletBC NeumannBC

#############
# run models and electrode types
for model in $Models
do 
  mkdir $model
  codefilename="$model-activecell-model-Nov1_S1Tests.edp"

  # submit simulations
  for electrodetype in $ElectrodeType;
  do
    mkdir "./$model/$electrodetype"
    ################
    # set paths
    pathtocode="./$codefilename"
    pathtooutputfile="./$model/$electrodetype/"
    pathtoterminaloutput="$pathtooutputfile/terminaloutput_$codefilename.txt"
    # specify the path to the EMI mesh (probably under the folder /Meshes/EMI)
    pathtomeshfile="./3d_8cells_EMImesh.mesh" # (for EMI only)  

    # run simulation in parallel (extra parameters are simply ignored by codes)
    DomainParameters="-celllength $CL -celldiameter $CD -gaplength $GL -gapdiameter $GD -ncellsx $NCellsInX -ncellsy $NCellsInY -ncellsz $NCellsInZ"

    ElectricParameters="-sigmai $sigmai -sigmae $sigmae -sigmaix $sigmaix -sigmaiy $sigmaiy -sigmaiz $sigmaiz -sigmaex $sigmaex -sigmaey $sigmaey -sigmaez $sigmaez -membranecapacitance $Cm -gapcapacitance $Cm -capacitance $Cm -gapresistance $RGap -chi $chi"
    
    DiscretizationParameters="-ti $tinitial -tf $tfinal -timestepsize $timestepsize -timesubsteps $timesubsteps -meshsize $meshsize -$timeintegratorcellmodel 1"
    
    SpecificParameters="-e1length $E1length -e1width $E1width -e1xmin $E1xmin -e1ymin $E1ymin -S1Start $S1Start -S1Duration $S1Duration -S1Period $S1Period -MinS1 $MinS1Magnitude -MaxS1 $MaxS1Magnitude -S2Start $S2Start -S2Duration $S2Duration -S2Period $S2Period -MinS2 $MinS2Magnitude -MaxS2 $MaxS2Magnitude -MinS1S2Interval $MinS1S2Interval -MaxS1S2Interval $MaxS1S2Interval -ncycles $CycleNumber -$electrodetype 1" 

    MiscParameters="-PlotSteps $steps -Restart $restart -CheckPointSteps $checkpointsteps -meshfile $pathtomeshfile -outputdir $pathtooutputfile"
    
    mpirun -np $ranks FreeFem++-mpi $pathtocode $DomainParameters $ElectricParameters $DiscretizationParameters $SpecificParameters $MiscParameters -v 0 | tee $pathtoterminaloutput #&
  done
done
