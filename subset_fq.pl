#!/usr/bin/env perl
## author: zhangwei
## email: admin\@ncrna.net
## fix a bug at 2016-09-01
use strict;
use warnings;
use threads;
use Thread::Queue;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';
use Compress::Zlib;

my ($list,$out,$num,$nb_process,$help)=();
GetOptions (
	"list=s"=>\$list,
	"out=s"=>\$out,
	"num=s"=>\$num,
	"thread=s"=>\$nb_process,
	"help=s"=>\$help,
);

my $usage = <<USAGE;

perl $0 -list rawData.list -thread 8 -out /path/to/output -num 60M

#Example: rawData.list
Ctl.rep1    /path/to/fastq/Ctl.rep1.R1.fq.gz, /path/to/fastq/Ctl.rep1.R2.fq.gz
Ctl.rep2    /path/to/fastq/Ctl.rep2.R1.fq.gz, /path/to/fastq/Ctl.rep2.R2.fq.gz
Treat.rep1    /path/to/fastq/Treat.rep1.R1.fq.gz, /path/to/fastq/Treat.rep1.R2.fq.gz
Treat.rep2    /path/to/fastq/Treat.rep2.R1.fq.gz, /path/to/fastq/Treat.rep2.R2.fq.gz

USAGE

if ($help){
	die $usage;
	exit;
}
die $usage unless (defined $list && -f $list);
die $usage unless (defined $num);

$nb_process ||= 8;

unless (defined $out){
	$out = abs_path("./");
	print STDERR "Output is set at $out\n";
}else{
	$out = abs_path($out);
}
unless (-d $out){
	mkdir($out,0755);
}
## 读取rawData.list
my @data = ();
open LIST, "<$list" or die $!;
while(<LIST>)
{
	chomp;
	next if /^\#/;
	my ($sample,$fqs) = (split /\t/, $_)[0,1];
	my ($fq1,$fq2) = (split /,\s*/, $fqs)[0,1];
	mkdir $out, 0755;
	if ($fq1 =~ /\.gz$/){
		system("gzip -df $fq1");
	}
	if ($fq2 =~ /\.gz$/){
		system("gzip -df $fq2");
	}
	$fq1 =~ s/\.gz//;
	$fq2 =~ s/\.gz//;
	my $cmd = "$fq1" . ",$fq2" . ",$sample" . ",$out" . ",$num";
	push @data, $cmd;
}
close LIST;

sub run{
	my ($cmd) = @_;
	my ($fq1,$fq2,$sample,$out) = split /,/, $cmd;

	my $fq1_name = basename($fq1) . ".clean.fq";
	my $fq2_name = basename($fq2) . ".clean.fq";
	
	open my $fh_fq1_in, "<$fq1";
	open my $fh_fq1_out, ">$out/$fq1_name";
	open my $fh_fq2_in, "<$fq2";
	open my $fh_fq2_out, ">$out/$fq2_name";
	my $count = 0;
	my $rand = int(rand(500000));
	while(1){
		my $sid1 = <$fh_fq1_in>;
		last if not defined $sid1; ## EOF
		chomp($sid1);
		my $prefix1 = (split/\s+/,$sid1)[0];
		
		my $seq1 = <$fh_fq1_in>;
		my $qid1 = <$fh_fq1_in>;
		my $qseq1= <$fh_fq1_in>;
		
		my $sid2 = <$fh_fq2_in>;
		last if not defined $sid2; ## EOF
		chomp($sid2);
		my $prefix2 = (split/\s+/,$sid2)[0];
		my $seq2 = <$fh_fq2_in>;
		my $qid2 = <$fh_fq2_in>;
		my $qseq2= <$fh_fq2_in>;
		
		unless($prefix1 eq $prefix2){
			print STDERR "Sth. wrong with the IO.\n";
			exit(1);
		}

		if($count < $num - $rand){
			print $fh_fq1_out "$sid1\n$seq1$qid1$qseq1";
			print $fh_fq2_out "$sid2\n$seq2$qid2$qseq2";
			$count ++;
		}else{
			last;
		}
	}
	close $fh_fq1_in;
	close $fh_fq1_out;
	close $fh_fq2_in;
	close $fh_fq2_out;

	return 0;
}
########################################  MAIN  #############################################

my $stream = Thread::Queue->new(@data,undef);
my $nb_mission = scalar @data;

my @running = ();
my @Threads;
while (scalar @Threads < $nb_mission) {
    @running = threads->list(threads::running);

    if (scalar @running < $nb_process) {
	my $command = $stream->dequeue();
        my $thread = threads->new(\&run,$command);
        push (@Threads, $thread);
        my $tid = $thread->tid;
    }
    @running = threads->list(threads::running);
    foreach my $thr (@Threads) {
        if ($thr->is_running()) {
            my $tid = $thr->tid;
        }
        elsif ($thr->is_joinable()) {
            my $tid = $thr->tid;
            $thr->join;
        }
    }
 
    @running = threads->list(threads::running);
}

while (scalar @running != 0) {
    foreach my $thr (@Threads) {
        $thr->join if ($thr->is_joinable());
    }
    @running = threads->list(threads::running);
    sleep(3);
}

exit 0;

############################################# SUBROUTINE ###############################################
