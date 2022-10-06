#!/bin/bash 
#./A04_RSA_Smooth5.sh SUB03 19980219SNFS glmRN50 super_RN50
#./A04_RSA_Smooth5.sh SUB03 19980219SNFS glmlevelsRN50 levels_vgg
#./A04_RSA_Smooth5.sh SUB03 19980219SNFS MDS_glmRN50 mds

SUBJECT_CODE=$1_$2
TRAGET=$3
TYPE=$4

echo "------${SUBJECT_CODE}-------"
export DATADIR=/Users/zhuang/Documents/MRI/Projects/Travel/data/ExemData/RSA
INPUTDIR=${DATADIR}/RSA_${TRAGET}

MAP_IN=${INPUTDIR}/${TYPE}_SS0_${SUBJECT_CODE}.nii.gz
MAP_OUT=${INPUTDIR}/${TYPE}_SS5_${SUBJECT_CODE}.nii.gz

echo "MAP_IN: ${MAP_IN}"
echo "MAP_OUT: ${MAP_OUT}"

fslmaths ${MAP_IN} -kernel gauss 2.1233226 -fmean ${MAP_OUT}

echo "------${SUBJECT_CODE}--${TRAGET}--${TYPE}--SMOOTH 5mm done----"
