#!/usr/bin/env python

import os, sys
import matplotlib.pyplot as plt
import numpy as np
import math
import glob
import argparse


def file_len(filename):
    with open(filename) as f:
        for i, l in enumerate(f):
            pass
    return i+1

def get_band(lv):

    sysbands = glob.glob('*.bands')[0]
    tlines = file_len('%s' %sysbands)
    
    speck = []
    speclabel = []

    f = open('%s'%sysbands)
    for i in range(tlines):
        line = f.readline()
        words = line.split()
        if i == 0: E_f = float(words[0])     # fermi level
        elif 0<i<2: pass
        elif i == 2:                         # min and max of E
            MinE = np.float64(words[0])
            MaxE = np.float64(words[1])
        elif i == 3:
            nbands = int(words[0])           # number of bands
            nspin = int(words[1])            # number of spins
            nk = int(words[2])               # number of k
            specialkline = int(math.ceil(float(nbands*nspin)/10)*nk + 4)  # line where specialK loc is
    
            k = np.zeros((nk), dtype = np.float64)
            E = np.zeros((nbands*nspin,nk), dtype = np.float64)
    
        elif 3 < i < specialkline:
    
            klabel = (i-4)//int(math.ceil(float(nbands*nspin)/10))
    
            if (i-4)%int(math.ceil(float(nbands*nspin)/10))==0:
                k[(i-4)//int(math.ceil(float(nbands*nspin)/10))] = np.float64(words[0])
                for j in range(1,len(words)):
                    E[j-1][klabel]=np.float64(words[j])
    
            else:
                blabel = ((i-4)%int(math.ceil(float(nbands*nspin)/10)))*10
                for j in range(len(words)):
                    E[blabel+j][klabel]=np.float64(words[j])
    
    #
    #   Get high symmetry point
    #
    
        elif i==specialkline:      # band data
            nspecialk = int(words[0])
        elif i>specialkline:
            
            speck.append(float(words[0]))        
            speclabel.append(words[1][1:-1])
    f.close()
    
    #
    #   Find VBM CBM
    #
    
    vbmloc = []
    cbmloc = []
    vbm_list = []
    cbm_list = []
    
    for j in range(nk):
        for i in range(nbands*nspin):
            if E[i][j] < E_f and E[i+1][j] > E_f:
                vbm_list.append(E[i-lv][j])
                cbm_list.append(E[i+1][j])
    
    vbm = max(vbm_list)
    cbm = min(cbm_list) 
    bandgap = cbm - vbm
    
    
    return k, E, nbands, nspin, speck, speclabel, E_f, bandgap, vbm
    

def plot_band(K, E, NBANDS, NSPIN, SPEC, LABEL, EF, EG, EMIN, EMAX, KMIN , KMAX, VBM):
    

    ef = EF
    AVG = VBM

    ######visualization####
    fig = plt.figure(figsize = (3,5))
    ax = fig.add_subplot(111)

    for axis in ['top','bottom','left','right']:
        ax.spines[axis].set_linewidth(2)
    ax.xaxis.set_tick_params(width=2)
    ax.yaxis.set_tick_params(width=2)

    ax.tick_params(axis="x", direction='in', length=6)
    ax.tick_params(axis="y", direction='in', length=6)

    labels = [item.get_text() for item in ax.get_yticklabels()]
    empty_string_labels = ['']*len(labels)
    ax.set_yticklabels(empty_string_labels)


    c = ['k','r']
    for isp in range(NSPIN):
        for i in range(NBANDS):
            plt.plot(K, E[i]-AVG, linewidth=2, color=c[isp])

    #for i in range(NBANDS, NBANDS*2):
    #    plt.plot(K,E[i]-AVG,'r')

        
    plt.xlim(KMIN,KMAX)
    plt.ylim(EMIN,EMAX)
    spec = []
    label = []
    
    idx = 0
    for i in SPEC:
        if KMIN < i and i < KMAX:
            spec.append(SPEC[idx])
            label.append(LABEL[idx])
        
        idx += 1


    #### X-ticks
    plt.xticks(SPEC,LABEL,fontsize=16)   
    labels = [item.get_text() for item in ax.get_xticklabels()]
    empty_string_labels = ['']*len(labels)
    ax.set_xticklabels(empty_string_labels)

#    plt.xticks(spec,label,fontsize=16)
    plt.yticks(fontsize=16)
 
    for i in range(len(spec)):
        plt.axvline(x=spec[i], color='k', linestyle='--', linewidth=2)

#    plt.axhline(y=-5.74740347687753-AVG, color='k', linestyle='--', linewidth=1.5)
#    plt.axhline(y=-5.16870460109694-AVG, color='k', linestyle='--', linewidth=1.5)

    plt.tight_layout()
    plt.savefig('band.png') 
    plt.close()

    np.array(E, dtype = float)

    np.savetxt('specialk.csv',SPEC)
    np.savetxt('kpath.csv', K)
    np.savetxt('test.csv', (E-AVG).T, delimiter=',')


def main(emin, emax, lv):

    k, e, nbands, nspin, spec, label, ef, eg, vbm = get_band(lv)

    kmin = min(k)
    kmax = max(k)

    print(vbm)
    print(eg)

    plot_band(k, e, nbands, nspin, spec, label, ef, eg, emin, emax, kmin, kmax, vbm)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='SIESTA bandstructure visualization')
    
    parser.add_argument('--emin', type=float, default=-2,
                         help='Minimum energy for bandstructure (eV)')
    parser.add_argument('--emax', type=float, default=+4,
                         help='Minimum energy for bandstructure (eV)')
    parser.add_argument('--level', type=int, default=0,
                         help='The order of reference eigenvalue level')

    args = parser.parse_args()

    main(args.emin,args.emax,args.level)
