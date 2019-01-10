# subset-fastq
subset fastq sequence in parallel

perl subset_fq.pl -list rawData.list -thread 8 -out /path/to/output -num 60000000

#Example: rawData.list
Ctl.rep1    /path/to/fastq/Ctl.rep1.R1.fq.gz, /path/to/fastq/Ctl.rep1.R2.fq.gz
Ctl.rep2    /path/to/fastq/Ctl.rep2.R1.fq.gz, /path/to/fastq/Ctl.rep2.R2.fq.gz
Treat.rep1    /path/to/fastq/Treat.rep1.R1.fq.gz, /path/to/fastq/Treat.rep1.R2.fq.gz
Treat.rep2    /path/to/fastq/Treat.rep2.R1.fq.gz, /path/to/fastq/Treat.rep2.R2.fq.gz
