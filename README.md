# Louvain NCD
Nested Community Detection

Here, we make available the pipeline used for community detection in our work "Patterns of genetic connectedness between modern and medieval Estonians reveal the origins of a major ancestry component of Finns". All credits will be given to the creators of each tool, R library, and software implemented in our scripts.

This guide provides a step-by-step instruction for reproducing our analysis.

We made things easier by reducing the process to three main steps:

1. Prepare a network edgelist for your data
2. Run the NCD.R script
3. Calculate individual connectedness score (PiC)

# Prepare the edgelist

Generally speaking, a network edgelist is a dataset containing two mandatory columns (from and to) and a third optional one (weight). For reproducing our pipeline, you will need a three-column tab-separated file like: 

```
ID1 ID2 value
ID1 ID3 value
ID2 ID4 value
...
...
```

with each row from the first two columns representing two connected individuals in your dataset (nodes), and the third column describing the weight of their connection (edge). As in our paper, this value is represented by a kinship coefficient that we calculated using IBIS (https://github.com/williamslab/ibis).

In the following example, INPUT is a PLINK file (.bed, .bim, and .fam files) and OUT.coef is the output from our run.

```
ibis -bfile INPUT -min_l 5 -a 0 -c 0.0005 -maxDist 0.1 -mt 400 -er .004 -2 -mt2 400 -t 16 -noFamID -bin -printCoef -f OUT

awk '$3>0.001' OUT.coef | cut -f1-3 | tail -n +2 > edgelist.coef

```
Each line in the edgelist.coef file will contain a pair of individuals sharing at least one >5 cM IBD chunk and with a kinship coefficient >0.001.

By the end of this first step, your edgelist will contain three columns: individual1, individual2, their kinship coefficient.

# NCD.R 

Required R libraries:

```
install.packages(psych)
install.packages(igraph)
install.packages(exactRankTests)
install.packages(data.table)
```
Then, run the program:
```
Rscript NCD.R edgelist.coef
```
The script is designed to run for 5 nested cycles (a first Mother level "M", followed by 4 Daughter levels "D"). After the run, a folder for each level will be generated. Within each folder you will find the corresponding Community files (a two column file with sample ID in first column and Community assignment in the second one). In the main folder, you will also find a file per Community level listing the p-values associated to each detected Community.
# PiC score
In this last step you will calculate the probability of individual connectedness (PiC) score. By the end of this last step, outliers will be removed and a matrix of individual connectedness will be generated. 

Required R libraries:
```
install.packages(EnvStats)
install.packages(outliers)
install.packages(reshape)
```
You will also need datamash (https://www.gnu.org/software/datamash/).

Then you can run the program:
```
sh PiC.sh
```
This program has been tested on different dataset with a variable number of edges. In the following image the results for nine different dataset. Time is in minutes (on the X axis) while number of edges is in millions (on the Y axis). We ran each test on 5 cores with 5Gb each. Regarding the previous step, the time needed for running NCD.R was of about 3 minutes for eight out of nine dataset, and about 7 minutes for the remaining dataset. 

![alt text](https://github.com/SABiagini/Louvain/blob/main/PiC_test.svg)

After running this program, a matrix of individual connectedness will be generated within each of the Community folders. Consider the matrix you want based on which level you want to explore (e.g., imagine you want to explore the second Community level, then you will have to look into the folder MDD, the second Daughter level). The file to look at is PercMatrix_alpha.txt but, if your Community number is higher than 26, consider the non alphanumeric matrix PercMatrix.txt. 

File edgelist.zip is a compressed edgelist.coef file. It is ready for testing steps 2 and 3 of the pipeline.
