# clogging
clogging simulation code:  from Hong et al., Phys Rev E 96, 062605 (2017).  Written in the IDL programming language, by Eric R. Weeks.  This implements the Durian bubble model introduced in Durian, PRL (1995) and slightly modified in Tewari et al., Phys. Rev. E 60, 4385 (1999).  An additional force is added to represent the viscous drag force from the walls; see Hong et al. for details.

For a copy of the original paper or simulation data from the article, go to Eric's lab website:  http://www.physics.emory.edu/~weeks/lab/

=======================================

The main program is “hopperbub16.pro”.  There are a bunch of subroutine code, that are mostly named sa_* where “sa” is for “stand-alone”.  This is after I pulled the various code chunks out of an earlier version of hopperbub.

hopperbub16.pro – main program
*    sa_setuphwall:  needed for boundary conditions
*    sa_buballneighbors:  slow, but finds all the nearest neighbors of all the droplets
*    sa_bubsomeneighbors:  faster, assumes we have a good estimate of the nearest neighbors, finds exact contacts
*    sa_buberic2urs2:  converts data structure of nearest neighbors (see below).
*    sa_bubdistance:  finds separation between all nearest neighbors
*    sa_buberic2urs3:  converts data structure and finds the inverse distance between neighbors, which is what you really need
*    sa_rungekutta:  does a Runge-Kutta step for the differential equation.  Basically, updates the ‘bub’ array which lists all the bubble positions and instantaneous velocities.
*    sa_bubplot:  plots the current state.  Currently plots the walls; Yonglun, you’d change this based on your simulation geometry.

ALSO:
*    sa_getnewvel:  called by sa_rungekutta.  sa_rungekutta just does the Runge-Kutta algorithm but doesn’t actually implement the bubble model.  sa_getnewvel is where the bubble model is implemented.
*    sa_squarewall, sa_bubhopperwall:  two different routines for the bubble-wall interactions, called by sa_getnewvel.

data structure of nearest neighbors:
*	“urs” structure (Urs Gasser wrote original version of this):  for each particle, has a list of data (N, neighbor1, neighbor2, … neighbor N, 0,0,0….).  This array is big because it has as many columns as the maximum number of neighbors any particle can ever have.  If you’re going for a highly polydisperse sample, this might need to have 100 columns if a big droplet could ever have 100 small neighbors.
*	“eric” structure (my version):  each pair of neighbors is listed:  (neighbor1, neighbor2).  So saves greatly on memory, but less efficient to use the data.
*	Thus “sa_buberic2urs2” converts from the eric format to the urs format.

===========================================================

To run the code:

b=hopperbub16(300,2500,seed=seed,gr=0.1,wi=8.0,ov=1.0,mo=mov,yr=[-20,70],nar=10.d,/nof,/noo,/us)

further explanation:

b=hopperbub16(300, $    ; 300 = number of bubbles

  2500, $               ; some moderately large number = how many time steps to simulate.  Hopefully it drains (or clogs) in fewer than 2500.
                        
  seed=seed, $          ; for the random number generator, just ignore
  
  grav=0.1, $           ; this is the value of gravity!  typically 0.3 to 0.001
  
  width=8.0, $          ; gap width.  d=2.0, so actually this is w/d=4.0.
  
  overflowmax=1.0, $    ; This has to do with how often the data are saved.  So, 1.0 means "the time it takes a droplet to fall a distance of 1.0 given the terminal velocity."
  
  mo=mov, $     ; this saves a movie in variable 'mov'
  
yr=[-20,70], $  ; This says yrange for plotting is -20,70

nar=10.d, $ ;     This says narrow hopper walls from -10 to +10.

/noforce, $     ; Don't plot lines indicating foces between droplets

/nooutlet,$     ; Below the exit, no vertical walls.

/useplot)       ; show the plot.  If you don't include this, then you won't get a plot and it will go faster.
        
Note that I coded this such that the particle radius is 1.0, thus all lengths (such as the width) are in these units.  Later we realized that we wanted to state everything in terms of the particle diameter, but that's not how it's coded.

Other options:
*  polyd =      set the polydispersity (default = 0.1)
*  f0 =         set the bubble model spring constant F_0 (default = 1)
*  startbub =   pass along an initial configuration... I don't think this option works properly
*  jamstring =  a string to print when the simulation is running.  Useful for keeping track of multiple simulations running in multiple windows.  Used by wrapbub (see below).
*  jamstate =   passes information back to calling program:  [bit, max time, num, vel] where bit = 0(did not clog) or 1(clogged), max time = total number of time steps simulated, num = how much is left in the hopper if it clogged, vel = minimum velocity, which gives a sense of how equilibrated the simulation is if it clogged
   
I'll note that there is some capacity to do a vibrated hopper, programmed by Mia Morrell, which is otherwise undocumented and unsupported.
        
======================

"wrapbub16.pro" is included to run the simulation multiple times, the better to generate statistics.

======================

For the nearest neighbor array structure, here's an example.

In the "eric" format:  if you want to know the neighbors of a given particle IDn, then you need to find all occurrences of IDn in either the first or second column.  Like, you might have a list of pairs such as:

- (1, 2)
- (1, 5)
- (2, 4)
- (2, 5)
- (3, 5)
- (4, 8)
- (4, 9)
- (5, 8)

So neighbors of particle 5 are 1, 2, 3, and 8.  Neighbors of particle 2 are 1, 4, 5.  The functions sa_buberic2urs2 or sa_buberic2urs3 convert this array format into a more useful format:

- (2, 2, 5, ...)    (particle 1 has 2 neighbors which are particles 2, 5)
- (3, 1, 4, 5, ...)    (particle 2 has 3 neighbors which are particles 1, 4, 5)
- (1, 5, ...)       (particle 3 has 1 neighbor which is particle 5)
- (3, 2, 8, 9, ...) (particle 4 has 3 neighbors which are particles 2, 8, 9)
- (4, 1, 2, 3, 8, ...)  (particle 5 has 4 neighbors which are particles 1, 2, 3, 8)

The ... stands for the fact that the array is large enough to accomodate many more neighbors, so each ... is just a bunch of "zero" entries to fill up the remainder of the row.

I realized later in life that there's better ways to store nearest neighbors that are both fast to use (like the urs format) and save on memory (like the eric format) but I don't want to bother going back and rewriting this code.  :-)


