The scripts are designed to process, analyze, and visualize velocity field data generated from hydrodynamic simulations or laboratory experiments.

They compute velocity relaxation times, plot scaled velocity profiles, and produce contour maps of relaxation behavior across varying speeds, depths, and flow directions.

Scripts Included
File	Description
VelocityRelaxationAnalysis.m	Computes the velocity relaxation time from simulation output files and generates scaled velocity profile plots for each depth and direction.
VelocityRelaxationAndProfiles.m	Extends the previous script to include both U and V velocity components (solid/dashed lines), and produces contour maps of relaxation time across speeds, depths, and directions.
Sample Data Files (not included)	Scripts expect input files named as <dir>_<speed>_<depth>outU.txt and <dir>_<speed>_<depth>outV.txt containing time–depth velocity data.
Output examples, in order of the above: 
<img width="2400" height="1099" alt="image" src="https://github.com/user-attachments/assets/45f98833-4286-4904-a1e2-936b075f2c82" /> and 
<img width="751" height="535" alt="image" src="https://github.com/user-attachments/assets/c9962d6f-b996-4306-8867-d4c7a22615d8" />

