## Spike sorting

### Installation

#### Linux:

1. Install prerequisites using apt-get: 
```
sudo apt-get install h5utils libhdf5-dev 
sudo apt-get install libblas-dev liblapack-dev gfortran
sudo apt-get install python-sip-dev python-qt4-dev 
sudo apt-get install python-qt4 qt4-dev-tools libxext-dev
```
2. Install klustasuite from http://klusta.readthedocs.io
3. Download Benware from http://github.com/beniamino38/benware

#### Mac:

1. Install prerequisites using brew:
```
brew install hdf5 <others?>
```
2. Install klustasuite from http://klusta.readthedocs.io
3. Download Benware from http://github.com/beniamino38/benware


#### Windows (NOT RECOMMENDED)

1. Download Benware from http://github.com/beniamino38/benware

2. Install pythonxy (MinGW package needed)

3. Install generic python packages using pythonxy: You *must* have pytables
version 3.0.0, numpy version 1.8.1 and pandas version 0.12

4. Make sure that distutils uses MinGW (howto see for example
https://github.com/cython/cython/wiki/InstallingOnWindows) Create a file named
distutils.cfg (if you already don't have it) in your PythonXYLibdistutils and
add to it the following lines:
```
[build]
compiler = mingw32
```

6. Download and install klustakwik (using 'git clone' or .zip link on the
page): https://github.com/klusta-team/klustakwik -- click zip link or
```
git clone https://github.com/klusta-team/klustakwik.git
```

Then:
```
cd klustakwik
make NOOPENMP=1
sudo mv KlustaKwik /usr/local/bin/
[Check it works by typing: cd~; KlustaKwik]
```
7. Download *customised* klustaviewa from:
http://willmore.eu/klustaviewa-0.3.0-bw.zip

 cd klustaviewa-0.3.0-bw
 sudo python setup.py install

[Check it works by typing: 'cd ~; klusta', cd ~; klustaviewa' ]


### Clustering

If your data from expt 64 was saved in /data/expt64, in Matlab:
```
>> cd benware
>> clusterspikes('/data/expt64');
```

This will go through each directory in turn, convert the data to a klusta-
compatible format, find spikes and do automatic clustering. You can redo this
for a single directory with (not in matlab):
```
$ cd /data/expt64/P10-decorr.v2
$ klusta *.kwik
```

Now, you can load the results of clustering back into matlab with:
>> spiketimes = getsortedspikes('/data/expt64', true, true) % NB 3rd argument = true

Setting the 3rd argument to true gets the auto-clustered spikes, not hand-
sorted ones.

### Manual editing of clusters

Now, in terminal, run klustaviewa: on all shanks, e.g.:
```
$ cd /data/expt64/P10-decorr.v2
$ klustaviewa *kwik
```

You can go through the different shanks using the File menu -> change shank

Now, get the spike times into Matlab:
```
>> spiketimes = getsortedspikes('/data/expt64')
```

Not setting the third argument (i.e. letting it default to false) gets the
hand-sorted spikes.

