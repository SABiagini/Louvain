#!/bin/bash

stop=$1

awk -v a="$stop" '$a="NA"' Summary_Table.txt  > filter1
awk '{if (NR!=1) {print $1"\t"$2"-"$3"-"$4"-"$5"-"$6}}' filter1 > indcode

sed -i 's/NA//g' indcode
sed -i 's/\-\-//g' indcode
sed -i 's/\-$//g' indcode

cut -f2 indcode |sort| uniq -c | sed -e 's/^ *//;s/ /\t/' >tmp 
awk 'NR == FNR{a[$2] = $1;next}; {print $1"\t"$2, $2 in a?a[$2]: "NA"}' tmp indcode | awk '$3 < 10 {$2 = $3 = "["$2"]"} 1 {print $1"\t"$2}' > indcode2
rm indcode tmp filter* 
mv indcode2 indcode
