
use Relations;

$first = 'first';
$second = 'second';
$third = 'third';

@args_ordered = ($first,$second,$third);

($first_ordered,$second_ordered,$third_ordered) = rearrange(['FIRST','SECOND','THIRD'],@args_ordered);

die "ordered rearrange failed" unless (($first_ordered eq $first) and 
                                       ($second_ordered eq $second) and 
                                       ($third_ordered eq $third));

@args_named = (-first  => $first,
               -second => $second,
               -third  => $third);

($first_named,$second_named,$third_named) = rearrange(['FIRST','SECOND','THIRD'],@args_named);

die "named rearrange failed" unless (($first_named eq $first) and 
                                     ($second_named eq $second) and 
                                     ($third_named eq $third));

$bit_byte = "salad bit Garden byte dressing bit Blue Cheese";
$bit_byte_switch = "dressing bit Blue Cheese byte salad bit Garden";

$where_hash = {salad    => 'Garden',
               dressing => 'Blue Cheese'};

$bit_byte_hash = delimit_clause(' bit ',' byte ',0,$where_hash);

die "hash delimit_clause failed" unless ($bit_byte_hash eq $bit_byte) ||
                                        ($bit_byte_hash eq $bit_byte_switch);

$where_reverse = {'Garden'      => salad,
                  'Blue Cheese' => dressing};

$bit_byte_reverse = delimit_clause(' bit ',' byte ',1,$where_reverse);

die "reverse delimit_clause failed" unless ($bit_byte_hash eq $bit_byte) ||
                                           ($bit_byte_hash eq $bit_byte_switch);

$where_array = ["salad bit Garden",
                "dressing bit Blue Cheese"];

$bit_byte_array = delimit_clause(' bit ',' byte ',0,$where_array);

die "array delimit_clause failed" unless ($bit_byte_hash eq $bit_byte) ||
                                         ($bit_byte_hash eq $bit_byte_switch);

$where_string = "salad bit Garden byte dressing bit Blue Cheese";

$bit_byte_string = delimit_clause(' bit ',' byte ',0,$where_string);

die "string delimit_clause failed" unless ($bit_byte_hash eq $bit_byte) ||
                                          ($bit_byte_hash eq $bit_byte_switch);

$hand = {'me' => 'free', 'I'  => 'sky'};

$as_hand = as_clause($hand);
$as_one_hand = "free as me,sky as I";
$as_other_hand = "sky as I,free as me";

die "as_clause failed" unless ($as_hand eq $as_one_hand) ||
                              ($as_hand eq $as_other_hand);

$equals_hand = equals_clause($hand);
$equals_one_hand = "me=free and I=sky";
$equals_other_hand = "I=sky and me=free";

die "equals_clause failed" unless ($equals_hand eq $equals_one_hand) ||
                                  ($equals_hand eq $equals_other_hand);
 
$comma_hand = comma_clause($hand);
$comma_one_hand = "me,free,I,sky";
$comma_other_hand = "I,sky,me,free";

die "comma_clause failed" unless ($comma_hand eq $comma_one_hand) ||
                                 ($comma_hand eq $comma_other_hand);
 
$assign_hand = assign_clause($hand);
$assign_one_hand = "me=free,I=sky";
$assign_other_hand = "I=sky,me=free";

die "assign_clause failed" unless ($assign_hand eq $assign_one_hand) ||
                                  ($assign_hand eq $assign_other_hand);
 
$add_hand = {'car' => 'far'};

$add_as_hand = add_as_clause($as_hand,$add_hand);
$add_as_one_hand = "free as me,sky as I,far as car";
$add_as_other_hand = "sky as I,free as me,far as car";

die "add_as_clause failed" unless ($add_as_hand eq $add_as_one_hand) ||
                                  ($add_as_hand eq $add_as_other_hand);
  
$add_equals_hand = add_equals_clause($equals_hand,$add_hand);
$add_equals_one_hand = "me=free and I=sky and car=far";
$add_equals_other_hand = "I=sky and me=free and car=far";

die "add_equals_clause failed" unless ($add_equals_hand eq $add_equals_one_hand) ||
                                      ($add_equals_hand eq $add_equals_other_hand);
 
$add_comma_hand = add_comma_clause($comma_hand,$add_hand);
$add_comma_one_hand = "me,free,I,sky,car,far";
$add_comma_other_hand = "I,sky,me,free,car,far";

die "add_comma_clause failed" unless ($add_comma_hand eq $add_comma_one_hand) ||
                                     ($add_comma_hand eq $add_comma_other_hand);
 
$set_hand = {'link' => 'think'};

$set_as_hand = set_as_clause($as_hand,$set_hand);
$set_as_one_hand = "think as link";

die "set_as_clause failed" unless ($set_as_hand eq $set_as_one_hand);
  
$set_equals_hand = set_equals_clause($equals_hand,$set_hand);
$set_equals_one_hand = "link=think";

die "set_equals_clause failed" unless ($set_equals_hand eq $set_equals_one_hand);
 
$set_comma_hand = set_comma_clause($comma_hand,$set_hand);
$set_comma_one_hand = "link,think";

die "set_comma_clause failed" unless ($set_comma_hand eq $set_comma_one_hand);
 
$thing = to_array('fee,fie,foe');

die "to_array failed string" unless (($thing->[0] eq 'fee') and 
                                     ($thing->[1] eq 'fie') and 
                                     ($thing->[2] eq 'foe'));

$thang = to_array(['me','my','moe']);

die "to_array failed array" unless (($thang->[0] eq 'me') and 
                                    ($thang->[1] eq 'my') and 
                                    ($thang->[2] eq 'moe'));

$bang = to_hash('fee,fie,foe');

die "to_hash failed string" unless ($bang->{'fee'} and 
                                    $bang->{'fie'} and 
                                    $bang->{'foe'});

$bang = to_hash(['me','my','moe']);

die "to_hash failed array" unless ($bang->{'me'} and 
                                   $bang->{'my'} and 
                                   $bang->{'moe'});

$bong = to_hash({'see'  => 1,
                 'sigh' => 1,
                 'so'   => 1});

die "to_hash failed hash" unless ($bong->{'see'} and 
                                  $bong->{'sigh'} and 
                                  $bong->{'so'});

$sing = add_array(['earth','air'],['fire','water']);

die "add_array failed" unless (($sing->[0] eq 'earth') and 
                               ($sing->[1] eq 'air') and 
                               ($sing->[2] eq 'fire') and 
                               ($sing->[3] eq 'water'));

$song = add_hash({'yin' => 1},{'yang' => 1});

die "add_hash failed" unless ($song->{'yin'} and 
                              $song->{'yang'});

open SET, ">set.pl";

print SET "use Relations;\n";
print SET "configure_settings('test','me','hide','here','2525')";

close SET;

open SETTER, "| perl set.pl";

print SETTER "\n";
print SETTER "\n";
print SETTER "\n";
print SETTER "\n";
print SETTER "\n";

close SETTER;

open SETTINGS, "<Settings.pm";

while ($set_line = <SETTINGS>) {

  eval $set_line;

}

close SETTINGS;

die "default configure_settings failed" unless (($database eq 'test') and 
                                                ($username eq 'me') and 
                                                ($password eq 'hide') and 
                                                ($host eq 'here') and 
                                                ($port eq '2525'));
                               
open SETTER, "| perl set.pl";

print SETTER "pass\n";
print SETTER "you\n";
print SETTER "find\n";
print SETTER "there\n";
print SETTER "5252\n";

close SETTER;

open SETTINGS, "<Settings.pm";

while ($set_line = <SETTINGS>) {

  eval $set_line;

}

close SETTINGS;

die "entered configure_settings failed" unless (($database eq 'pass') and 
                                                ($username eq 'you') and 
                                                ($password eq 'find') and 
                                                ($host eq 'there') and 
                                                ($port eq '5252'));
                               
unlink 'set.pl';
unlink 'Settings.pm';

print "\n\nEverything seems fine.\n";
