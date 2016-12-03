#!/usr/bin/perl -w

# A hash for each class pair of tutors for the 6 classes in the course
%tutors = (	"M16A"=>"Alex and PG",
		"M16B"=>"Shawn and Monica",
		"M17A"=>"Ravi and Jeff",
		"M17B"=>"Gab and Olivia",
		"T17A"=>"Chris, Harrison and Mitchel",
		"T17B"=>"Joseph and Malik");

# The web page containing the raw individual grades corresponding
# to each students' student number to search through
open F,"<$ARGV[0]"  or die;
@search = <F>;
close(F);

# A pre-made list of each student's ID details and which class they are in
# Creating a hash for each entry type
open G, "<Group_lists.txt" or die;
@array = <G>;
foreach $line (@array){
	$line =~ /([MT]1[67][AB]) Group (\d+) (z\d{7}) ([^ ]*) (.*)/;
	$session_groups{"$1 Group $2"}.="$3 ";
	$session{$3} = $1;
	$group{$3} = $2;
	$f_name{$3} = $4;
	$l_name{$3} = $5;
}
close(G);

# Searching through the list of individual grades to find a match with
# a student number, when will grab the grade 3 lines ahead
foreach $stu_num (keys %session){
	foreach $index (0..$#search){
		if ($search[$index] =~ m/\s$stu_num\s+Grade/){
			next if (defined $grades{$stu_num});
			foreach $sub_index (1..5){
				if ($search[$index+$sub_index] =~ /^\s*(\d+\.?\d*)\s*\/\s100/){
					$grades{$stu_num} = $1;
					last;
				}
			}
		}
	}
}

# Printing out the summary and average of each student's grade organized
# by group and which class they are in
foreach $session ("M16A","M16B","M17A","M17B","T17A","T17B"){
	#print "Session: $session\n";
	print "====================================== Session";
	print "$session ====================================\n";
	printf("%50s","Tutors: $tutors{$session}\n\n");

	my @session_grades = ();
	my $num_sub = 0;
	my $num_students = 0;
	my $num_groups = 0;

	print "INDIVIDUAL SUBMISSIONS:, Session, Group, zID, First Name, Last Name, Grade\n";
	foreach $group (1..12){
		$hash_key = "$session Group $group";
		next if (!defined $session_groups{$hash_key});
		#print "$hash_key $session_groups{$hash_key}\n";

		$student_string = $session_groups{$hash_key};
		@students = $student_string =~ /z\d{7}/g;

		foreach $stu (@students){
			$grade = $grades{$stu} || "-";
			printf("\t%5s,", $session{$stu});
			printf("%3s,", $group{$stu});
			printf("%10s,", $stu);
			printf("%15s,", $f_name{$stu});
			printf("%30s,", $l_name{$stu});
			printf("%4s,", $grade);
			$num_students++;
			if (defined $grades{$stu}){
				push @session_grades, $grades{$stu};
				$num_sub++;
			}
			print "\n";
		}

		print "\n";
		$num_groups++;
	}

	print "NUMBER OF STUDENTS: $num_students\n";
	print "NUMBER OF GROUPS: $num_groups\n";

	@sorted = sort { $a <=> $b } @session_grades;
	my $min = $sorted[0] || 0;
	my $max = $sorted[$#sorted] || 0;
	my $sum = (@sorted) ? eval join '+', @session_grades : 0;
	my $average = ($num_sub != 0) ? average($sum,$num_sub) : 0;
	print "NUMBER OF SUBMISSIONS: $num_sub\n";
	print "AVERAGE GRADE: $average";
	print "\n";
	print "GRADE RANGE: $min -> $max\n";
	print "\n";

}

# Helper function to display the average as a decimal
sub average{
	my $num = shift;
	my $den = shift;

	return int(10*$num/$den)/10;
}
