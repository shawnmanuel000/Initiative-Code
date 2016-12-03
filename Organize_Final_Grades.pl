#!/usr/bin/perl -w

# Create a hash of all student grades
open_grades2();

# List of student details
open G, "<Group_lists.txt" or die;
@array = <G>;

# Concatenate student numbers for each group to collate the students
# in each group for each tutorial
foreach $line (@array){
	$line =~ /([MT]1[67][AB] Group \d+) (z\d{7})/;
	$session_groups{$1}.="$2 ";
}

# Hash for the tutor pairs of each class
%tutors = (	"M16A"=>"Alex and PG",
		"M16B"=>"Shawn and Monica",
		"M17A"=>"Ravi and Jeff",
		"M17B"=>"Gab and Olivia",
		"T17A"=>"Chris, Harrison and Mitchel",
		"T17B"=>"Joseph and Malik");

# Going through each hash entry and counting the number of each grade for each
# tutorial and printing the student grades
foreach $session ("M16A","M16B","M17A","M17B","T17A","T17B"){
	#print "Session: $session\n";
	print "====================================================================== Session";
	print "$session ========================================================================\n";
	printf("%90s","Tutors: $tutors{$session}\n\n");

	my $HDs = 0;	# high distinction
	my $DNs = 0;	# distinction
	my $CRs = 0;	# credit
	my $PSs = 0;	# pass
	my $FLs = 0; 	# fail
	my $num_stu = 0;	# number of students in the tutorial

	foreach $group (1..12){
		$hash_key = "$session Group $group";
		next if (!defined $session_groups{$hash_key});
		#print "$hash_key $session_groups{$hash_key}\n";

		$student_string = $session_groups{$hash_key};
		@students = $student_string =~ /z\d{7}/g;

		print "$session Group $group:\n";
		printf("%40s","Name,");
		printf("%12s","zID,");
		printf("%4s,  ","Pres");
		printf("%4s,  ","Peer");
		printf("%12s, , ,","Design exe");
		printf("%12s, , ,","Design rprt");
		printf("%8s, , ","Logbook");
		printf("%3s,","mean");
		print "\n";

		foreach $stu (@students) {

			printf("%40s,",$name{$stu});
			printf("%12s,","$stu");
			printf("%5s, ",$pres{$stu});
			printf("%4s, ",$peer{$stu});
			printf("%4s, ",$de1{$stu});
 			printf("%4s, ",$de2{$stu});
 			printf("%4s, ",$de3{$stu});
			printf("%4s, ",$dr1{$stu});
			printf("%4s, ",$dr2{$stu});
			printf("%4s, ",$dr3{$stu});
			printf("%4s, ",$mlb{$stu});
			printf("%4s, ",$flb{$stu});
			printf("%3s, ",$mean{$stu});

			$letter = get_grade($mean{$stu});
			print "\t$letter,";

			#print "\t <HD>" if ($mean{$stu} >= 87);
			if ($mean{$stu} >= 83 && $mean{$stu} <= 86){
				$diff = $mean{$stu}-85;
				$sign = ($diff >= 0) ? "+" : "";
				print "\t = HD$sign$diff";
			}

			#print "\t\t- <83-84>" if ($mean{$stu} == 84 || $mean{$stu} == 83);

			if ($flb{$stu} eq "-"){
				$boost = 85 - int($mean{$stu});
				print "\t - HD if logbook = $boost" if ($boost <= 20);
				#print "\t\t - no HD with logbook" if ($boost > 20);
				if ($boost <= $mlb{$stu}/5){
					$potential{$session}++;
					print " (Likely)";
				}
			} else {

				if ($mean{$stu} >= 73 && $mean{$stu} <= 76){
					$diff = $mean{$stu}-75;
					$sign = ($diff >= 0) ? "+" : "";
					print "\t\t\t   = D$sign$diff";
				}
				#print "\t\t\t   - <73-76>" if ($mean{$stu} => 73 && $mean{$stu} <= 76);
			}

			print "\n";

			if ($mean{$stu} >= 85){
				$HDs++ ;
			} elsif ($mean{$stu} >= 75){
				$DNs++;
			} elsif ($mean{$stu} >= 65){
				$CRs++;
			} elsif ($mean{$stu} >= 50){
				$PSs++;
			} else {
				$FLs++;
			}
			$num_stu++;

		}
	print "\n";

	}
	$pc_HD{$session} = percent($HDs,$num_stu);
	$pc_DN{$session} = percent($DNs,$num_stu);
	$pc_CR{$session} = percent($CRs,$num_stu);
	$pc_PS{$session} = percent($PSs,$num_stu);
	$pc_FL{$session} = percent($FLs,$num_stu);

	$HD_count{$session} = $HDs;
	$DN_count{$session} = $DNs;
	$CR_count{$session} = $CRs;
	$PS_count{$session} = $PSs;
	$FL_count{$session} = $FLs;

	$student_count{$session} = $num_stu;


	$potential_message = "";
	$pot_percent = "";
	if (defined $potential{$session}){
		$with_potential = $HDs + $potential{$session};
		$potential_message = "-- potentially $with_potential";
		$pot_pc = int(1000*$with_potential/$num_stu)/10;
		$pot_percent = "($pot_pc%)";
	}


	#print "NUMBER OF HDs = ($HDs / $num_stu students) -- $potential_message $pot_percent\n";
	print "PERCENTAGE HDs = $pc_HD{$session}%, ($HDs / $num_stu students)\n";
	print "PERCENTAGE DNs = $pc_DN{$session}%, ($DNs / $num_stu students)\n";
	print "PERCENTAGE CRs = $pc_CR{$session}%, ($CRs / $num_stu students)\n";
	print "PERCENTAGE PSs = $pc_PS{$session}%, ($PSs / $num_stu students)\n";
	print "PERCENTAGE FLs = $pc_FL{$session}%, ($FLs / $num_stu students)\n\n";

}

foreach $session ("M16A","M16B","M17A","M17B","T17A","T17B"){
	$total_HDs += $HD_count{$session};
	$total_DNs += $DN_count{$session};
	$total_CRs += $CR_count{$session};
	$total_PSs += $PS_count{$session};
	$total_FLs += $FL_count{$session};

	$total_stu += $student_count{$session};

	$pots = $potential{$session} || 0;
	$total_potentials += $pots;

	$potential_percent = percent(($HD_count{$session}+$pots),$student_count{$session});

	print "Session: $session has $pc_HD{$session}% HDs ";
	print "($HD_count{$session}/$student_count{$session})";
	print " + $potential{$session} potentials (max $potential_percent%)" if (defined $potential{$session});
	print "\n";
}

$total_percent_HD = percent($total_HDs,$total_stu);
$total_percent_DN = percent($total_DNs,$total_stu);
$total_percent_CR = percent($total_CRs,$total_stu);
$total_percent_PS = percent($total_PSs,$total_stu);
$total_percent_FL = percent($total_FLs,$total_stu);


$potential_percent_HD = percent(($total_HDs+$total_potentials),$total_stu);
print "Total:\n";
print " $total_percent_HD% HDs ( $total_HDs / $total_stu )\n ";
#print "---> potentially $potential_percent_HD% ( $total_HDs + $total_potentials / $total_stu )\n";
print " $total_percent_DN% DNs ( $total_DNs / $total_stu ) \n";
print " $total_percent_CR% CRs ( $total_CRs / $total_stu ) \n";
print " $total_percent_PS% PSs ( $total_PSs / $total_stu ) \n";
print " $total_percent_FL% FLs ( $total_FLs / $total_stu ) \n";
print "\n";

sub percent{
	my $num = shift;
	my $den = shift;

	return int(1000*$num/$den)/10;
}

sub open_grades2 {
	open F, "<final_output.txt", or die;
	@array = <F>;

	while (@array){
		$line = shift @array;
		@fields = split /;/, $line;
		#print join ',',@fields;

		$curr = $fields[0];
		$curr =~ /(z\d{7})/;
		$curr_student = $1;
		$name{$curr_student} = $fields[1];
		$pres{$curr_student} = get_int($fields[2]) || "-";
		$peer{$curr_student} = get_int($fields[3]) || "-";
		$de1{$curr_student} = get_int($fields[4]) || "-";
		$de2{$curr_student} = get_int($fields[5]) || "-";
		$de3{$curr_student} = get_int($fields[6]) || "-";
		$dr1{$curr_student} = get_int($fields[7]) || "-";
		$dr2{$curr_student} = get_int($fields[8]) || "-";
		$dr3{$curr_student} = get_int($fields[9]) || "-";
		$mlb{$curr_student} = get_int($fields[10]) || "-";
		$flb{$curr_student} = get_int($fields[11]);
		$mean{$curr_student} = get_int($fields[12]);
	}
	close(F);
}

sub get_int {
	$string = shift;
	$number = $string;
	return "-" if ($number =~ /-/);
	$number =~ s/\D//g;
	return int($number);
}

sub open_grades1 {
	open F, "<group_report.txt", or die;
	@array = <F>;

	while (@array){
		$line = shift @array;

		if ($line =~ /^User report - (.*) \((z\d{7})\)/){
			$curr_student = $2;
			$name{$curr_student} = $1;
		}
		if ($line =~ /AssignmentFinal Presentation/){
			$line =~ /\s(\d+)\s/;
			$pres{$curr_student} = $1 || "-";
		} elsif ($line =~ /AssignmentPeer/){
			$line =~ /\s(\d+)\s/;
			$peer{$curr_student} = $1 || "-";
		} elsif ($line =~ /Assignment1st Design Exercise/){
			$line =~ /\s(\d+)\s/;
			$de1{$curr_student} = $1 || "-";
		} elsif ($line =~ /Assignment2nd Design Exercise/){
			$line =~ /\s(\d+)\s/;
			$de2{$curr_student} = $1 || "-";
		} elsif ($line =~ /Assignment3rd Design Exercise/){
			$line =~ /\s(\d+)\s/;
			$de3{$curr_student} = $1 || "-";
		} elsif ($line =~ /Assignment1st Design Report/){
			$line =~ /\s(\d+)\s/;
			$dr1{$curr_student} = $1 || "-";
		} elsif ($line =~ /Assignment2nd Design Report/){
			$line =~ /\s(\d+)\s/;
			$dr2{$curr_student} = $1 || "-";
		} elsif ($line =~ /Assignment3rd Design Report/){
			$line =~ /\s(\d+)\s/;
			$dr3{$curr_student} = $1 || "-";
		} elsif ($line =~ /AssignmentMid/){
			$line =~ /\s(\d+)\s/;
			$mlb{$curr_student} = $1 || "-";
		} elsif ($line =~ /AssignmentFinal Logbook/){
			if ($line =~ /\s(\d+)\s/){
				$flb{$curr_student} = $1;
			} else {
				$flb{$curr_student} = "-";
			}
		} elsif ($line =~ /^(\d+)/){
			$mean{$curr_student} = $1;
		}
	}
	close(F);
}

sub get_grade {
	$num = shift;
	return "HD" if $num >= 85;
	return "DN" if $num >= 75;
	return "CR" if $num >= 65;
	return "PS" if $num >= 50;
	return "FL";
}
