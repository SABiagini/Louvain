#!/bin/bash

#HOW2RUN: sh SumMatrix.sh Communityfile file.coef

# This script creates a summary table with rows as samples and columns as comunities. 
# Values are number of connections between a specific sample and the correspondig community in a specific column.
# Values are then divided by the total of samples in each community and a new table is generated PercMatrix.txt.

ind=$1 # 2 column file (no header): SampleID\tLouvainCommunityCode
test=$2 # file.coef (from ibis)

#Create a 5 columns file with comunity code assignation to each sample of a couple in file.coef: ID1	CommunityCode_ID1	ID2		CommunityCode_ID2	coef 
awk 'NR == FNR{a[$1] = $2;next}; {print $1, $1 in a?a[$1]: "NA", $2" "a[$2]" "$3}' $ind $test | tail -n +1 > a.txt
#Fix column separator: replace spaces with tabs
perl -p -i -e 's/ /\t/g' a.txt
#Create a 5 columns file with comunity code assignation to each sample of a couple in file.coef: ID2	CommunityCode_ID2	ID1		CommunityCode_ID1	coef
#This step does the same as the first awk command but swapping the IDs positions. 
#This step allows to have the same full list of samples in both columns 1 and 4. This will be necessary for the following crossmap step.
awk 'NR == FNR{a[$1] = $2;next}; {print $2, $1 in a?a[$2]: "NA", $1" "a[$1]" "$3}' $ind $test  | tail -n +1 > b.txt
#Fix column separator: replace spaces with tabs
perl -p -i -e 's/ /\t/g' b.txt
#Add b.txt to a.txt
cat b.txt >> a.txt
#Fix column separator: replace spaces with tabs
perl -p -i -e 's/ /\t/g' a.txt
#Remove b.txt
rm b.txt
#Cross-tabulation between the first field (ID1) and the fourth field (ID2). It will count how many times each pair of samples appears in the newly generated file a.txt and store the output in file c.txt. Missing values (N/A) are set as 0 with the flag --filler. File c.txt will be a matrix. Flag -s sort the input before performing the intersection.
datamash -s crosstab 1,4 --filler 0 < a.txt > c1.txt
#Extract the header from c.txt and store it into d.txt file
head -n 1 c1.txt > d.txt
#Sort c1.txt for first column (datamash is not case insensitive when sorting and can generate some issue, with this step the issues are avoided) 
tail -n +2 c1.txt | sort -k1 > c.txt
rm c1.txt
#Add "ID" and "Community" labels to the header (it will be needed for a later step)
awk 'BEGIN{FS=OFS=""} {print (NR>1?0:"ID\tCommunity"), $0}' d.txt > e.txt
#Join $ind file and c.txt based on sample ID. This generates a new matrix (f.txt) which is identical to the previous one but with Community codes assignation in the second field.
join -1 1 -2 1 $ind c.txt > f.txt
#Sort f.txt matrix by the second filed (Community codes)
sort f.txt -k 2 > g.txt 
#Add the fixed header to the newly generated matrix 
cat e.txt g.txt > SumMatrix.txt
#Remove files you don't need anymore
rm a.txt c.txt d.txt e.txt f.txt g.txt
#Tell me the output is ready
echo "Output SumMatrix.txt is ready!" 
#First, datamash counts how many samples per community are in the table. The header is removed. Only the column with the counts is retained and then it is transposed using datamash. 
datamash -W -s groupby 2 count 2 --filler 0 < SumMatrix.txt | tail -n +2 | cut -f2 | datamash transpose | sed 'N;s/\n/ /' > count
#A label "N" for Number is placed at the beginning of the count line
sed 's/^/\tN\t/' count > count2
#File count is removed
rm count 
#The new line with the count of samples per community is added at the beginning of the original matrix
cat count2 SumMatrix.txt > tmp1

#The number of connections between a sample and a community in a specific column is divided by the total number of samples belonging to that same community (that's why we added the header created in the previous step). The following steps will thus generate the file PercMatrix.txt.
awk '{ if (NR==1) { n = split($0, a, "\t"); } for (i=3; i<n; i++) { printf("%.5f\t", ($i/a[i])); } printf("%.5f\n", ($n/a[n])); }' tmp1 | awk '{if(NR>2) print}' > tempmat
cut -f1,2 -d' ' tmp1 | cut -f1,2 -d' ' | tail -n +3 > tempcol
head -n2 tmp1 > temphead
paste tempcol tempmat > tmp2
cat temphead tmp2 > PercMatrix.txt
#Intermediate files are removed.
rm count2 tmp1 tempmat tempcol temphead tmp2
#Tell me the file is ready.
echo "Output PercMatrix.txt is ready!"
echo "Done!" 
