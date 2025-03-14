# The command for running this pipeline is actually pretty easy
# All you need to do is define an input json, and then
# run the caper command below

i=18

# LAST THING TO DO IS WRITE A SCRIPT TO AUTO EDIT
# THE MY MNASE FILE

caper run atac.wdl -i my_mnase.json --docker

mkdir d0$i

# this will organize the outputs into final forms
# I think that a should have our crazy named directory...
a=$(ls -ltr atac | tail -1 | awk -F ' ' '{print $9}')
croo atac/$a/metadata.json

# this will create a spreadsheet of mapped read counts
qc2tsv qc/qc.json > spreadsheet.tsv

# It seems that the REAL issue with moving stuff is moving the atac
# file. Need to see if I can force a more reasonable name on it...
mv spreadsheet.tsv d0$i/.
mv caper-db* d0$i/.
mv cromwell* d0$i/.
mv croo* d0$i/.
mv qc d0$i/.
mv signal d0$i/.
mv align d0$i/.

# Next, we need to invoke samtools
samtools sort -n d0$i/align/rep1/*.srt.bam > sorted_d0$i.bam
samtools index d0$i/align/rep1/*.srt.bam

mv sorted_d0$i.bam d0$i/.
mv d0$i/align/rep1/*.bai d0$i/.
mv d0$i/align/rep1/*.srt.bam d0$i/.

# Lastly, call Genrich
../Genrich/Genrich -t d0$i/sorted_d0$i.bam -o sample.narrowPeak -v
mv sample.narrowPeak d0$i/.

# Hopefully all of that worked??
