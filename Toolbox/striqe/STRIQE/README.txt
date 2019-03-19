//------// Lab FOr Video And Image Analysis (LFOVIA) //------//
//------// STeReoscopic Image QUality Evaluator (STRIQUE) //------//
0)  Download STRIQE code from http://www.iith.ac.in/~lfovia

1)	Download the Steerable pyramid toolbox from the following link:  
        http://www.cns.nyu.edu/pub/eero/matlabPyrTools.tar.gz 

2)	Disparity map can be estimated using the files from the following link:
        http://live.ece.utexas.edu/research/quality/MJ3DFR_release.zip 

3)	Copy all the files present in the folder "STRIQUE_Software" to the steerable pyramid toolbox folder.

4)	Open the mfile strique.m

5)	Consider the following as inputs and output:
	Inputs:
	--> (Il, Ir)-- Ref Stereo Pair 
	--> (il, ir)-- Test Stereo Pair
	--> (Dl, Dr)-- Left and Right Disparity Map Of Ref Stereo Pair
	-->    a    -- Alpha Power generally in the range [0.8, 0.85]
     
     Outputs:
	-->  score   -- Objective Quality Score Of Stereo Pair.
