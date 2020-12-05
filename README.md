### subset_fq.pl: subset paired fastq files in parallel.

```sh
perl subset_fq.pl -list rawData.list -thread 8 -out /path/to/output -num 60000000

-list     List  # sample name and the corresponding fastq files
-thread   Number of threads to use
-out      Output path, default is "./"
-num      Number of reads to be kept
```
For example, you have four samples, named Ctl.rep1, Ctl.rep2, Treat.rep1, Treat.rep2,
fastq or gziped fastq is ok. the rawData.list is as follows:
```sh
#======================================================================================
Ctl.rep1    /path/to/fastq/Ctl.rep1.R1.fq.gz, /path/to/fastq/Ctl.rep1.R2.fq.gz
Ctl.rep2    /path/to/fastq/Ctl.rep2.R1.fq.gz, /path/to/fastq/Ctl.rep2.R2.fq.gz
Treat.rep1    /path/to/fastq/Treat.rep1.R1.fq.gz, /path/to/fastq/Treat.rep1.R2.fq.gz
Treat.rep2    /path/to/fastq/Treat.rep2.R1.fq.gz, /path/to/fastq/Treat.rep2.R2.fq.gz
#======================================================================================
```
Dependency:
```sh
#========================
use threads;
use Thread::Queue;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';
use Compress::Zlib;
#========================
```
Good luck.
