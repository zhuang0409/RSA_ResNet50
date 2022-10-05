#!/bin/bash 
matlab -nodisplay A04_Run_RSA
./A05_run_smooth.sh

matlab -nodisplay A06_createStatMapRSA('glmRNobjectvsaction','RN50')
matlab -nodisplay A06_createStatMapRSA('RNobject','RNobject')
matlab -nodisplay A06_createStatMapRSA('RNaction','RNaction')

matlab -nodisplay A09_TFCE_groupGLMDNNs('glmRNactionvsobject','RN50')
matlab -nodisplay TFCE_group('RNaction','RNaction')
matlab -nodisplay TFCE_group('RNobject','RNobject')
