# This package contains some generalized functions for 
# dealing with databases and queries.

package Relations;
require Exporter;
require 5.004;

# You can run this file through either pod2man or pod2html to produce pretty
# documentation in manual or html file format (these utilities are part of the
# Perl 5 distribution).

# Copyright 2001 GAF-3 Industries, Inc. All rights reserved.
# Written by George A. Fitch III (aka Gaffer), gaf3@gaf3.com

# This program is free software, you can redistribute it and/or modify it under
# the same terms as Perl istelf

$Relations::VERSION='0.93';

@ISA = qw(Exporter);

@EXPORT = qw(
              add_array
              add_as_clause 
              add_comma_clause 
              add_equals_clause
              add_hash
              as_clause 
              assign_clause 
              comma_clause 
              configure_settings
              delimit_clause
              equals_clause
              rearrange
              set_as_clause 
              set_comma_clause 
              set_equals_clause
              to_array
              to_hash
            );

@EXPORT_OK = qw(
                add_array
                add_as_clause 
                add_comma_clause 
                add_equals_clause
                add_hash
                as_clause 
                assign_clause 
                comma_clause 
                configure_settings
                delimit_clause
                equals_clause
                rearrange
                set_as_clause 
                set_comma_clause 
                set_equals_clause
                to_array
                to_hash
               );

%EXPORT_TAGS = ();

# From here on out, be strict and clean.

use strict;



# Rearranges arguments from either the straight ordered format, or named format, 
# into their respective variables.

# This code was modified from the standard CGI module by Lincoln D. Stein

sub rearrange {

  ### First we're going to get whatever's sent and make sure there's 
  ### something to parse

  # Get how to order of the arguments and the arguments themselves.

  my ($order,@param) = @_;

  # Return unless there's something to parse.

  return () unless @param;

  ### Second, we're going to format whatever's sent in an array, with the  
  ### even members being the keys, and the odd members being the values.
  ### If the caller just sent the argument in the order the function 
  ### requires without names, we'll just return those values in their.
  ### sent order.
  
  # If the first parameter is a hash.

  if (ref($param[0]) eq 'HASH') {

    # Then we have to change it to an array, with the evens = keys, 
    # odds = values.

    @param = %{$param[0]};

  } 

  # If it's not a hash
  
  else {

    # Then return the values array as is, unless the first member of the array 
    # is preceeded by a '-', which would be indicated of a named parameters 
    # calling style, i.e. 'function(-name => $value)'. 

    return @param unless (defined($param[0]) && substr($param[0],0,1) eq '-');

  }

  ### Third, we're going to figure out the where each arguments value is to 
  ### go in the array returned.

  # Declare some locals (Howdy folks!) to figure out the order it which to 
  # return the arugment values.

  my ($i,%pos);

  # Initialize count

  $i = 0;

  # Go through each value in the order array

  foreach (@$order) {

    # The order of this argument name is the current location of the counter.

    $pos{$_} = $i;

    # Increase the counter to the next position.

    $i++;

  }

  ### Fourth, we're going insert the argument values into the return array in
  ### their proper order, and then send the results array on it's way.

  # Declare the array that will return the argument values in there proper 
  # order.

  my (@result);

  # Preextend the results array to match the length of the order aray. I
  # guess this speeds things up a bit.

  $#result = $#$order;  # preextend

  # While there's arguments and values left to parse.

  while (@param) {

    # The argument's name is the even member (zero is even, right?)

    my $key = uc(shift(@param));

    # Take out the '-' preceeding the name of the argument

    $key =~ s/^\-//;

    # If we calculated a position for this argument name.

    if (exists $pos{$key}) {

      # Then store the arugments value at the arguments proper position in the
      # result array.

      $result[$pos{$key}] = shift(@param);

    } 

  }

  # Return the array of arugments' values.

  @result;

}

# This routine is used for concatenting hashes, arrays and (leaving alone) 
# strings to be used in different clauses within an SQL statement. 
# If sent a hash, the field-value pairs will be concatentated with the minor 
# string and those pairs will be concatenated with the major string, and 
# that string returned. If an array is sent, the members of the array with 
# will be concatenated with the major string, and that string returned. 
# If a string is sent, that string will be returned. 

sub delimit_clause {

  # Get delimitters passed

  my ($minor) = shift;
  my ($major) = shift;
  my ($reverse) = shift;

  my (%clause,@clause,$clause);

  ### First, figure out whether we were passed a hash ref, an array ref 
  ### or string. 

  # Create a hash from the next argument hash reference, if next argument 
  # is in fact a hash reference.

  %clause = %{$_[0]} if (ref($_[0]) eq 'HASH');

  # Create an array from the clause_info array reference, unless we 
  # already determined it was a hash

  @clause = @{$_[0]} if (ref($_[0]) eq 'ARRAY');

  # Create a string from clause_info string, unless we 
  # already determined it was a hash or array.

  $clause = $_[0] unless (%clause || @clause);

  ### Second concatenate, we're appropriate. Hash ref's use the field name
  ### as the key, and each pair represents a piece of the clause. (Like, 
  ### something between and's in a where clause) Array ref's have each
  ### member being a piece of the clause.  Strings are all the pieces
  ### of the clase concanated together.

  # If the clause hash is defined, meaning we were passed a hash ref of
  # clause info.

  if ((keys %clause)+0) {

    # Go through the fields and values, adding to the array to make it seem
    # we were really passed an array.

    my $field;

    foreach $field (keys %clause) {

      # Unless we're supposed to reverse the order

      unless ($reverse) {

        # Concantenate the values.

        push @clause,"$field$minor$clause{$field}";

      }

      else {

        # Concantenate the values in reverse order.

        push @clause,"$clause{$field}$minor$field";

      }

    }

  }

  # If the clause array is defined, meaning we were passed an array ref of
  # clause info, (or made to think that we were).

  if (@clause+0) {

    # Concatenate the array into a string, as if we were really
    # passed a string.

    $clause = join $major, @clause;

  }

  # Return the string since that's all we were passed, (or made to think
  # we were).

  $clause;

}



# Builds the meat for a select or from clause

sub as_clause {

  # Get the clause to be as'ed

  my ($as) = shift;

  # If there's something to delimit

  if (defined($as)) {

    # Return the proper clause manimpulation
 
    return delimit_clause(' as ',',',1,$as);

  }

  # If where here, than there's nothing to 
  # delimit.

  return '';

}



# Builds the meat for a where or having clause

sub equals_clause {

  # Get the clause to be equals'ed

  my ($equals) = shift;

  # If there's something to delimit

  if (defined($equals)) {

    # Return the proper clause manimpulation
 
    return delimit_clause('=',' and ',0,$equals);

  }

  # If where here, than there's nothing to 
  # delimit.

  return '';

}



# Builds the meat for a group by, order by, or limit clause

sub comma_clause {

  # Get the clause to be comma'ed

  my ($comma) = shift;

  # If there's something to delimit

  if (defined($comma)) {

    # Return the proper clause manimpulation
 
    return delimit_clause(',',',',0,$comma);

  }

  # If where here, than there's nothing to 
  # delimit.

  return '';

}



# Builds the meat for a set clause

sub assign_clause {

  # Get the clause to be assign'ed

  my ($assign) = shift;

  # If there's something to delimit

  if (defined($assign)) {

    # Return the proper clause manimpulation
 
    return delimit_clause('=',',',0,$assign);

  }

  # If where here, than there's nothing to 
  # delimit.

  return '';

}



# Add the meat for a select or from clause

sub add_as_clause {

  # Get the clause to be add as'ed

  my ($as) = shift;
  my ($add_as) = shift;

  # If there's something to add

  if (defined($add_as)) {

    # If there's something already there

    if (length($as)) {

      # Return what's there, plus a comma,
      # plus what's to be added

      return $as . ',' . as_clause($add_as);

    }

    # If we're here than there's nothing
    # already there so just return what's
    # to be added.

    return as_clause($add_as);

  }
  
  # If we're here than there's nothing
  # to be added so just return what's 
  # already there.

  return $as;

}



# Add the meat for a where or having clause

sub add_equals_clause {

  # Get the clause to be add equals'ed

  my ($equals) = shift;
  my ($add_equals) = shift;

  # If there's something to add

  if (defined($add_equals)) {

    # If there's something already there

    if (length($equals)) {

      # Return what's there, plus a comma,
      # plus what's to be added

      return $equals . ' and ' . equals_clause($add_equals);

    }

    # If we're here than there's nothing
    # already there so just return what's
    # to be added.

    return equals_clause($add_equals);

  }
  
  # If we're here than there's nothing
  # to be added so just return what's 
  # already there.

  return $equals;

}



# Add the meat for a order by, group by, or 
# limit clause

sub add_comma_clause {

  # Get the clause to be add comma'ed

  my ($comma) = shift;
  my ($add_comma) = shift;

  # If there's something to add

  if (defined($add_comma)) {

    # If there's something already there

    if (length($comma)) {

      # Return what's there, plus a comma,
      # plus what's to be added

      return $comma . ',' . comma_clause($add_comma);

    }

    # If we're here than there's nothing
    # already there so just return what's
    # to be added.

    return comma_clause($add_comma);

  }
  
  # If we're here than there's nothing
  # to be added so just return what's 
  # already there.

  return $comma;

}



# Sets the meat for a select or from clause

sub set_as_clause {

  # Get the clause to be set as'ed

  my ($as) = shift;
  my ($set_as) = shift;

  # If there's something to set

  if (defined($set_as)) {

    # Just return what's to be set.

    return as_clause($set_as);

  }
  
  # If we're here than there's nothing
  # to be set so just return what's 
  # already there.

  return $as;

}



# Sets the meat for a where or having clause

sub set_equals_clause {

  # Get the clause to be set equals'ed

  my ($equals) = shift;
  my ($set_equals) = shift;

  # If there's something to set

  if (defined($set_equals)) {

    # Just return what's to be set.

    return equals_clause($set_equals);

  }
  
  # If we're here than there's nothing
  # to be set so just return what's 
  # already there.

  return $equals;

}



# Sets the meat for a order by, group by, or 
# limit clause

sub set_comma_clause {

  # Get the clause to be set comma'ed

  my ($comma) = shift;
  my ($set_comma) = shift;

  # If there's something to set

  if (defined($set_comma)) {

    # Return what's to be set.

    return comma_clause($set_comma);

  }
  
  # If we're here than there's nothing
  # to be set so just return what's 
  # already there.

  return $comma;

}



# Takes a comma delimitted string or array ref 
# and returns an array ref.

sub to_array {

  # Grab the value sent. 

  my $value = shift;

  # Unless it's a reference to something

  unless (ref($value)) {

    # Assume its a comma delimitted string and
    # break it up into an array.

    my @value = split ',', $value;

    # Store the new array ref in $value

    $value = \@value;

  }

  # Return the array refence
  
  return $value;

}



# Takes a comma delimitted string, array ref or 
# hash ref and returns a hash ref.

sub to_hash {

  # Grab the value sent. 

  my $value = shift;

  # Unless it's a reference to something

  unless (ref($value) eq 'HASH') {

    # Assume its a comma delimitted string or an
    # array ref and send it to to_array

    $value = to_array($value);

    # Declare the hash to send back.

    my %value = ();

    # Go through each one

    foreach my $val (@{$value}) {

      $value{$val} = 1;

    }

    # Streot he new hash ref in $value

    $value = \%value;

  }

  # Return the hash refence
  
  return $value;

}



# Takes two arrays and places one onto the 
# end of the other

sub add_array {

  # Grab the arrays sent. 

  my $value = shift;
  my $adder = shift;

  # Push the adder onto the value

  push @{$value},@{$adder};

  # Return the value
  
  return $value;

}



# Takes two hash ref and adds the key value pairs
# from one to the other.

sub add_hash {

  # Grab the hashes sent. 

  my $value = shift;
  my $adder = shift;

  # Go through each adder key 

  foreach my $add (keys %{$adder}) {

    $value->{$add} = $adder->{$add};

  }

  # Return the value
  
  return $value;

}



# Takes a comma delimitted string, array ref or 
# hash ref and returns a hash ref.

sub add_hash {

  # Grab the hashes sent. 

  my $value = shift;
  my $adder = shift;

  # Go through each adder key 

  foreach my $add (keys %{$adder}) {

    $value->{$add} = $adder->{$add};

  }

  # Return the value
  
  return $value;

}



# Creates a default database settings module.
# Takes in the defaults, prompts the user for
# info. If the user sends info, that's used. 
# Once the settings a determine, it creates a
# Settings.pm file in the current direfctory.

sub configure_settings {

  # Get the defaults sent.

  my ($def_database,
      $def_username,
      $def_password,
      $def_host,
      $def_port) = rearrange(['DATABASE',
                              'USERNAME',
                              'PASSWORD',
                              'HOST',
                              'PORT'],@_);

  # Declare the actual values

  my ($database,$username,$password,$host,$port);

  # Prompt the user for each value

  print "\nBefore we can get started, I need to know some\n";
  print "info about your MySQL settings. Please fill in\n";
  print "the blanks below. To accept the default values\n";
  print "in []'s, just hit return.\n";

  print "\nMYSQL DATABASE NAME\n";
  print "Make sure the database isn't the same as the name\n";
  print "as an existing database of yours, since the demo\n";
  print "will delete that database in preparing the demo.\n";

  print "\nDatabase name [$def_database]:";
  $database = <STDIN>;
  chomp $database;
  $database = $database ? $database : $def_database;

  print "\nMYSQL USERNAME AND PASSWORD\n";
  print "Make sure the this username password account can\n";
  print "create and destory databases.\n";

  print "\nUsername [$def_username]:";
  $username = <STDIN>;
  chomp $username;
  $username = $username ? $username : $def_username;

  print "\nPassword [$def_password]:";
  $password = <STDIN>;
  chomp $password;
  $password = $password ? $password : $def_password;

  print "\nMYSQL HOST AND PORT\n";
  print "Make the computer running the demo can connect to\n";
  print "this host and port, or the demo will not function\n";
  print "properly.\n";

  print "\nHost [$def_host]:";
  $host = <STDIN>;
  chomp $host;
  $host = $host ? $host : $def_host;

  print "\nPort [$def_port]:";
  $port = <STDIN>;
  chomp $port;
  $port = $port ? $port : $def_port;

  print "\n\nUsing settings:\n\n";
  print "database: $database\n";
  print "username: $username\n";
  print "password: $password\n";
  print "host: $host\n";
  print "port: $port\n";

  # Create a Settings.pm file

  open SETTINGS, ">Settings.pm";

  print SETTINGS "\$database = '$database';\n";
  print SETTINGS "\$username = '$username';\n";
  print SETTINGS "\$password = '$password';\n";
  print SETTINGS "\$host = '$host';\n";
  print SETTINGS "\$port = '$port';\n";

  close SETTINGS;

}



$Relations::VERSION;

__END__

=head1 NAME

Relations - Functions to Use with Databases and Queries

=head1 SYNOPSIS

  use Relations;

  $as_clause = as_clause({full_name => "concat(f_name,' ',l_name)",
                         {status    => "if(married,'Married','Single')"})

  $query = "select $as_clause from person";

  $avoid = to_hash('virus,bug');

  if ($avoid->{bug}) {

    print "Avoiding the bug...";

  }

  unless ($avoid->{code}) {

    print "Not avoiding the code...";

  }

  configure_settings(-database => 'relations',
                     -username => 'root',
                     -password => '',
                     -host     => 'localhost',
                     -port     => 3306);

=head1 ABSTRACT

This perl library contains functions for dealing with databases.
It's mainly used as the the foundation for all the other 
Relations modules. It may be useful for people that deal with
databases in Perl as well.

The current version of Relations is available at

  http://www.gaf3.com

=head1 DESCRIPTION

=head2 WHAT IT DOES

Relations has functions for creating clauses of queries (like where, 
from etc.) from hashes, arrays and strings. It also has functions
for converting strings to arrays or hashes, if they're not hashes
or arrays already. It even has an argument parser, which is 
used quite heavily by the other Relations modules.

=head2 CALLING RELATIONS ROUTINES

All standard Relations routines use an ordered argument calling style. 
This is because the routines have very few arguments, and they're 
mainly used bu other modules with far friendlier objects and 
functions. So the argument order matters for all functions, and you 
should consult the function defintions later in this document to 
determine the proper order to use.

=head1 LIST OF RELATIONS FUNCTIONS

An example of each function is provided in 'test.pl'. When you run 
it, don't be surprised if a bunch of stuff appears on the screen
appearing to ask then answer questions. That's just test.pl 
pretending to be you while it talks to itself. :)

=head2 rearrange

  my (@arg_list) = rearrange($order,@param]);

Rearranges arguments from either the straight ordered format, or 
named format, into their respective variables. 

B<$order> - 
Array ref to of argument names in their proper order. Names must
be capitalized.

B<@param> - 
Array of values to parse.

EXAMPLES

B<Using:>

  sub example {

    # Get the defaults sent.

    my ($first,
        $second,
        $third) = rearrange(['FIRST',
                             'SECOND',
                             'THIRD'],@_);
  }

B<Calling:>

  example('one','two','three');

  example(-first  => 'one',
          -second => 'two',
          -third  => 'three');

=head2 delimit_clause

  delimit_clause($minor,$major,$reverse,$clause);

Creates a clause for a query from a hash ref,0 an array ref, or 
string. If sent a hash ref, the field-value pairs will be concatentated 
with the minor string and those pairs will be concatenated with the major 
string, and that string returned. If an array ref is sent, the members 
of the array with will be concatenated with the major string, and that 
string returned. If a string is sent, that string will be returned. 

B<$minor> - 
String to use to concatenate between the $clause hash ref key and 
value. 

B<$major> - 
String to use as the key-value pair if $clause is a hash ref, or 
array members if $clause is an array ref.

B<$reverse> - 
Value indicating whether to concatenate keys and values if $clause 
is a hash ref in key-value order ($reverse is false), or value-key
order ($reverse is true).

B<$clause> - 
Info to parse into a clause. Can be a hash ref, array ref, or 
string. 

=head2 as_clause

  as_clause($as);

Creates a 'select' or 'from' clause for a query from a hash ref, 
an array ref, or string. If sent a hash ref, the field-value pairs 
will be concatentated with an ' as ' between each value-key pair and 
those pairs will be concatenated with a ',' , and that string 
returned. If an array ref is sent, the members of the array with will 
be concatenated with a ',' and that string returned. If a string is 
sent, that string will be returned. 

B<$as> - 
Info to parse into a clause. Can be a hash ref, array ref, or 
string. 

EXAMPLES

B<Hash:>

as_clause({full_name => "concat(f_name,' ',l_name)",
          {status    => "if(married,'Married','Single')"})

returns: "concat(f_name,' ',l_name) as full_name,if(married,'Married','Single') as status"

B<Array:>

as_clause(['phone_num','address'])

returns: "phone_num,address"

B<String:>

as_clause("if(car='blue','sweet','ug') as dude,sweet")

returns: "if(car='found','sweet','ug') as dude,sweet"

=head2 equals_clause

  equals_clause($equals);

Creates a 'where' or 'having' clause for a query from a hash ref, 
array ref, or string. If sent a hash ref, the field-value pairs will 
be concatentated with an '=' between each value-key pair and those 
pairs will be concatenated with a ' and ' , and that string returned. 
If an array ref is sent, the members of the array with will be 
concatenated with a ' and ' and that string returned. If a string is 
sent, that string will be returned. 

B<$equals> - 
Info to parse into a clause. Can be a hash ref, array ref, or 
string. 

EXAMPLES

B<Hash:>

equals_clause({man    => "'strong'",
              {woman  => "'confident'"})

returns: "man='strong' and woman='confident'"

B<Array:>

equals_clause(["Age > 40","Hair='grey'"])

returns: "Age > 40 and Hair='grey'"

B<String:>

equals_clause("reason is not null or intuition > 25")

returns: "reason is not null or intuition > 25"

=head2 comma_clause

  comma_clause($equals);

Creates a 'group by', 'order by' or 'limit' clause for a query from
an array ref or string. If an array is sent, the members of the array 
with will be concatenated with a ',' and that string returned. If 
a string is sent, that string will be returned. 

B<$comma> - 
Info to parse into a clause. Can be an array ref, or string. 

EXAMPLES

B<Array:>

comma_clause(["Age > 40","Hair='grey'"])

returns: "Age > 40 and Hair='grey'"

B<String:>

comma_clause("reason is not null or intuition > 25")

returns: "reason is not null or intuition > 25"

=head2 assign_clause

  assign_clause($assign);

Creates a 'set' clause for a query from a hash ref, array ref, or string. 
If sent a hash ref, the field-value pairs will be concatentated with an 
'=' between each value-key pair and those pairs will be concatenated with 
a ',' , and that string returned. If an array ref is sent, the members of 
the array with will be concatenated with a ',' and that string returned. 
If a string is sent, that string will be returned. 

B<$assign> - 
Info to parse into a clause. Can be a hash ref, array ref, or 
string. 

EXAMPLES

B<Hash:>

assign_clause({boy    => "'testing'",
              {girl   => "'trying'"})

returns: "boy='testing',girl='trying'"

B<Array:>

assign_clause(["Age=floor(12.34)","Hair='black'"])

returns: "Age=floor(12.34),Hair='black'"

B<String:>

assign_clause("reason=.5")

returns: "reason=.5"

=head2 add_as_clause

  add_as_clause($as,$add_as);

Adds more as clause info onto an existing as clause, or creates
a new as clause from what's to be added.

B<$as> - 
Existing as clause to add to. Must be a string.

B<$add_as> - 
As clause to add to. Can be a hash ref, array ref or string.
See as_clause for more info.

=head2 add_equals_clause

  add_equals_clause($equals,$add_equals);

Adds more equals clause info onto an existing equals clause, or creates
a new equals clause from what's to be added.

B<$equals> - 
Existing equals clause to add to. Must be a string.

B<$add_equals> - 
Equals clause to add to. Can be a hash ref, array ref or string.
See equals_clause for more info.

=head2 add_comma_clause

  add_comma_clause($comma,$add_comma);

Adds more comma clause info onto an existing comma clause, or creates
a new comma clause from what's to be added.

B<$comma> - 
Existing comma clause to add to. Must be a string.

B<$add_comma> - 
Equals comma to add to. Can be a hash ref, array ref or string.
See comma_clause for more info.

=head2 set_as_clause

  set_as_clause($as,$set_as);

Overwrites as clause info over an existing as clause, only if the
over writing info is not empty.

B<$as> - 
Existing as clause to add to. Must be a string.

B<$set_as> - 
As clause to set. Can be a hash ref, array ref or string.
See as_clause for more info.

=head2 set_equals_clause

  set_equals_clause($equals,$set_equals);

Overwrites equals clause info over an existing equals clause, only if the
over writing info is not empty.

B<$equals> - 
Existing equals clause to add to. Must be a string.

B<$set_equals> - 
Equals clause to set. Can be a hash ref, array ref or string.
See equals_clause for more info.

=head2 set_comma_clause

  set_comma_clause($comma,$set_comma);

Overwrites comma clause info over an existing comma clause, only if the
over writing info is not empty.

B<$comma> - 
Existing comma clause to add to. Must be a string.

B<$set_comma> - 
Comma clause to set. Can be a hash ref, array ref or string.
See comma_clause for more info.

=head2 to_array

  to_array($value);

Takes a comma delimitted string or array ref and returns an array ref.
If a comma delimitted string is sent, it splits the string by the 
commas.

B<$value> - 
Value to convert or just send back. Can be an array ref or comma 
delimitted string.

=head2 to_hash

  to_hash($value);

Takes a comma delimitted string, array ref or hash ref and returns 
a hash ref. The hash ref returned will have keys based on the string,
array ref, or hash ref, with the keyed values being 1. If a comma 
delimitted string is sent, it splits the string by the commas into 
an array, and that array is used to add keys to a hash, with the 
values being 1 and the hash ref returned. If an array is sent, that 
array is used to add keys to a hash, with the values being 1 and the
hash ref returned. If a hash ref is sent, its just returned.

B<$value> - 
Value to convert or just send back. Can be a hash ref, array ref or 
comma delimitted string.

=head2 add_array

  add_array($value,$adder);

Takes two array refs and places one onto the end of the other.
Does not take strings!

B<$value> - 
Array ref to be added to.

B<$adder> - 
Array ref to add.

=head2 add_hash

  add_hash($value,$adder);

Takes two hash ref and adds the key value pairs from one to the other.

B<$value> - 
Hash ref to be added to.

B<$adder> - 
Hash ref to add.

=head2 configure_settings

  configure_settings($database,
                     $username,
                     $password,
                     $host,
                     $port) 

  configure_settings(-database => $database,
                     -username => $username,
                     -password => $password,
                     -host     => $host,
                     -port     => $port) 

Creates a default database settings module. Takes in the defaults, 
prompts the user for info. If the user sends info, that's used. 
Once the settings a determine, it creates a 'Settings.pm' file in 
the current direfctory.

B<$database> - 
Default database name to use for test.pl or demo.pl

B<$username> and B<$password> - 
Default MySQL account to use to connect to the database. 

B<$host> and B<$port> - 
Default MySQL host and access port to use to connect to the database. 

=head1 TODO LIST

=head2 Create add_assign_clause and set_assign_clause. 

=head1 OTHER RELATED WORK

=head2 Relations

This perl library contains functions for dealing with databases.
It's mainly used as the the foundation for all the other 
Relations modules. It may be useful for people that deal with
databases in Perl as well.

=head2 Relations::Abstract

A DBI/DBD::mysql Perl module. Meant to save development time and code 
space. It takes the most common (in my experience) collection of DBI 
calls to a MySQL databate, and changes them to one liner calls to an
object.

=head2 Relations::Query

An Perl object oriented form of a SQL select query. Takes hash refs,
array refs, or strings for different clauses (select,where,limit)
and creates a string for each clause. Also allows users to add to
existing clauses. Returns a string which can then be sent to a 
MySQL DBI handle. 

=head2 Relations.Admin.inc.php

Some generalized PHP classes for creating Web interfaces to relational 
databases. Allows users to add, view, update, and delete records from 
different tables. It has functionality to use tables as lookup values 
for records in other tables.

=head2 Relations::Family

A Perl query engine for relational databases.  It queries members from 
any table in a relational database using members selected from any 
other tables in the relational database. This is especially useful with 
complex databases; databases with many tables and many connections 
between tables.

=head2 Relations::Display

An Perl module creating GD::Graph objects from database queries. It 
takes in a query through a Relations::Query object, along with 
information pertaining to which field values from the query results are 
to be used in creating the graph title, x axis label and titles, legend 
label (not used on the graph) and titles, and y axis data. Returns a 
GD::Graph object built from from the query.

=head2 Relations::Choice

An Perl CGI interface for Relations::Family, Reations::Query, and 
Relations::Display. It creates complex (too complex?) web pages for 
selecting from the different tables in a Relations::Family object. 
It also has controls for specifying the grouping and ordering of data
with a Relations::Query object, which is also based on selections in 
the Relations::Family object. That Relations::Query can then be passed
to a Relations::Display object, and a graph or table will be displayed.
A working model already exists in a production enviroment. I'd like to 
streamline it, and add some more functionality before releasing it to 
the world. Shooting for early mid Summer 2001.

=cut