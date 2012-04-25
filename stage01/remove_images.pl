#!/usr/bin/perl
use strict;

require "../lib/timed_run.pl";

print "\n";
print "Reading Input File ../input/2b_tested.lst\n";
print "\n";

read_input_file();
print "\n";

if( is_run_remove_images_from_memo() ){
	print "\n"; 
	print "Detected Request Not to Run the Script\n";
	print "Exiting\n"; 
	print "\n"; 
	exit(0);
};


print "\n"; 
print "Deleting all images\n";
print "\n";

print "Running ./doit_remove.sh\n";
print "\n";

my $toed = system("./doit_remove.sh", 300);
my $output = get_recent_outstr();
my $err_str = get_recent_errstr();

print "\n################# STDOUT ##################\n";
print $output . "\n";
print "\n\n################# STDERR ##################\n";
print $err_str . "\n";

if( $toed ){
	print "[TEST_REPORT]\tFAILED : REMOVE IMAGES TIME-OUT !!\n";
	exit(1);
};

sleep(5);

print "\n";

my $check_remove = `euca-describe-images`;
chomp($check_remove);
print "COMMAND:\n";
print "euca-describe-images\n";
print "$check_remove\n";
print "\n";

if( $check_remove ne "" ){	
	print "[TEST_REPORT]\tFAILED: REMOVE IMAGES has Failed\n";
	exit(0);
};


print "[TEST_REPORT]\tREMOVE IMAGES has Completed\n";
exit(0);


1;


############################################### SUBROUTINES ####################################################


sub is_run_remove_images_from_memo{
	$ENV{'QA_MEMO_RUN_REMOVE_IMAGES'} = "";
        if( $ENV{'QA_MEMO'} =~ /^RUN_REMOVE_IMAGES=NO/m ){
                my $extra = $1;
                $extra =~ s/\r//g;
                print "FOUND in MEMO\n";
                print "RUN_REMOVE_IMAGES=NO\n";
                $ENV{'QA_MEMO_RUN_REMOVE_IMAGES'} = "NO";
                return 1;
        };
        return 0;
};



# Read input values from input.txt
sub read_input_file{

	my $is_memo = 0;
	my $memo = "";

	open( INPUT, "< ../input/2b_tested.lst" ) || die $!;

	$ENV{'QA_DISTRO'} = "";

	my $line;
	while( $line = <INPUT> ){
		chomp($line);
		if( $is_memo ){
			if( $line ne "END_MEMO" ){
				$memo .= $line . "\n";
			};
		};

        	if( $line =~ /^([\d\.]+)\t(.+)\t(.+)\t(\d+)\t(.+)\t\[(.+)\]/ ){
			my $qa_ip = $1;
			my $qa_distro = $2;
			my $qa_distro_ver = $3;
			my $qa_arch = $4;
			my $qa_source = $5;
			my $qa_roll = $6;

			my $this_roll = lc($6);
			if( $this_roll =~ /clc/ && $ENV{'QA_DISTRO'} eq "" ){
				print "\n";
				print "IP $qa_ip [Distro $qa_distro, Version $qa_distro_ver, ARCH $qa_arch] is built from $qa_source as Eucalyptus-$qa_roll\n";
				$ENV{'QA_DISTRO'} = $qa_distro;
				$ENV{'QA_DISTRO_VER'} = $qa_distro_ver;
				$ENV{'QA_ARCH'} = $qa_arch;
				$ENV{'QA_SOURCE'} = $qa_source;
				$ENV{'QA_ROLL'} = $qa_roll;
			};
		}elsif( $line =~ /^MEMO/ ){
			$is_memo = 1;
		}elsif( $line =~ /^END_MEMO/ ){
			$is_memo = 0;
		};
	};	

	close(INPUT);

	$ENV{'QA_MEMO'} = $memo;

	return 0;
};


1;

