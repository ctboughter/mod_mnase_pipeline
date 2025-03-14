# Introduction

So this repository relies entirely on the ENCODE ATAC-seq pipeline (https://github.com/encode-dcc/atac-seq-pipeline), but is modified to process MNase-digested DNA.

To get this analysis done, we need the help of ~5
different software packages.

# Instructions

1. Download the ENCODE atac-seq pipeline (link above), if you haven't already, and follow steps 1-3 in their installation.
2. Download this repository: git clone https://github.com/ctboughter/mod_mnase_pipeline.git
3. Edit the included "my_mnase.json" file in this repository to fit your data: alter the atac.title, atac.fastqs_rep1_R1, and atac.fastqs_rep1_R2 variables to fit your project title and the path to your individual paired FASTQs.
4. Move this my_mnase.json file to the previously downloaded atac-seq-pipeline directory.
5. Run caper using: caper run atac.wdl -i my_mnase.json --docker
6. This will take a long time to run, then output some crazy, poorly formatted directory inside a new directory called "atac"
7. It is *very* important that you do not move or rename these files and directories. Annoyingly, ENCODE uses a lot of "references" to data objects, so changing names invalidates a lot of these references.
8. Copy down new directory name (if you have run the pipeline many times, you can find the most recently generated one with "ls -ltr")
9. In the following steps, replace what I call "CRAZYDIRNAME" with that copied directory name
10. Generate a bam file as an output using: croo atac/CRAZYDIRNAME/metadata.json
11. This will create a bunch of new directories: align, peak, qc, signal
12. Generate a qc report: qc2tsv qc/qc.json
13. We need to utilize samtools to reformat these bam files (samtools can be downloaded in many ways, rely on google for the howto)
14. Run samtools (obviously replacing XXX with your output name): samtools sort -n align/rep1/XXX.srt.bam > sorted_dXXX.bam OR parallel samtools (faster): samtools sort --threads 30 -n align/rep1/XXX.srt.bam > sorted_XXX.bam
15. Create an index for this bam: samtools index align/rep1/XXX.srt.bam OR parallel samtolls (faster): samtools index --threads 30 align/rep1/XXX.srt.bam
16. Now interestingly, note that the sorted bam and the sorted bai do NOT go together. The bai is for the longer name output by croo
17. I *think* the key to the analysis is either in these bams or in the "peaks" directory (the narrowPeak files) but I just haven't figured out how to analyze/compare these quantitatively...

# Deprecated
I'm leaving these steps here, just in case you get any more data that fails the ENCODE QC. In that case, the my_mnase.json file needs to be edited, and "atac.align_only" needs to be set to "True". This is how I analyzed the first subsampled dataset, and may be useful if troubleshooting is ever needed again. Once the my_mnase.json is edited, you can just pick up from step 5 in the above protocol. Only difference is you won't get a "peaks" output after running croo, so you have to do peakcalling manually, as below:
17. If you haven't already, download Genrich (https://github.com/jsh58/Genrich)
18. From the sorted bam, we can now identify peaks using Genrich: ./Genrich/Genrich -t sorted_dXXX.bam -o sample.narrowPeak -v -r
19. That's as far as I got... you can visualize these peaks using something like IGV (https://igv.org/) but it isn't quantitative.

# Notes

- run_script.sh was my attempt to automate this process. Keep it here so we have it, but it DOES NOT WORK. As mentioned above, moving these outputs breaks the pipeline, which is incredible frustating...
- If you run this pipeline multiple times, you should move a bunch of the outputs to a folder with a name you can keep track of.
- You can only analyze one experimental condition at a time.
- We set "align_only:true" because our data (currently) fails QC. We may be able to run more of the automated pipeline with the new (better) data