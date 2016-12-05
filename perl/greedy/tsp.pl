#!/usr/bin/env perl


package Node;
use v5.10.0;
use warnings;
use strict;
use Carp;

use Math::Complex; #sqrt()
use Storable 'dclone'; #for creating deep copies


# Node Object
# Stores Node number, x coordinate, and y coordinate
sub new {
    my $class = shift;
    my $self  = { @_ };
    croak "bad arguments" unless defined $self->{node_num} and defined $self->{x_val} and defined $self->{y_val};; 
    return bless $self, $class; #this is what makes a reference into an object
}

# Getter for Node number
sub get_node_num {
    my $self = shift;
    return $self->{node_num};
}

# Getter for x coordinate
sub get_x_val {
    my $self = shift;
    return $self->{x_val};
}

#Getter for y coordinate
sub get_y_val{
    my $self = shift;
    return $self->{y_val};
}

# main
sub main
{
    # create our array of nodes from the input file
    my @node_array = parse_file($ARGV[0]);

    my @result_array;
    my $total_distance = 0;


    # pick a random node to start from, can easily be changed by modifying x
    # and add this first node to our result_array
    my $x = int(rand(280));
    my $cur_node = splice @node_array, $x, 1;
    my $first_node = dclone $cur_node;
    push @result_array, $first_node;
    my $min_dist;
    my $min_index;
    my $dist;
    my $node;
    # loop over all the nodes in our node_array and find the closest node
    while (scalar @node_array > 0) {
        for (my $j=0; $j < scalar @node_array; $j++) {
            $node = $node_array[$j];
            $dist = distance($cur_node, $node);
            if (!defined $min_dist or $dist < $min_dist) {
                $min_dist = $dist;
                $min_index = $j;
            }
        }
        # remove the node and add it to our result_array
        # modify our total_distance
        # reset values in the loop
        $cur_node = splice @node_array, $min_index, 1;
        push @result_array, $cur_node;
        $total_distance = $total_distance + $min_dist;
        $min_dist = undef;
    }

    # account for distance from last node to first node
    $total_distance = $total_distance + distance($first_node, $cur_node);

    print "NAME : a280-greedy.tsp\n";
    print "TYPE : TOUR\n";
    print "DIMENSION : ";
    print scalar @result_array;
    print "\n";
    print "TOUR_SECTION\n";
    print "Distance: ";
    print $total_distance;
    print "\n";
    foreach my $result (@result_array) {
        print $result->get_node_num;
        print "\n";
    }
    print -1;
}

# calculates distance between two nodes
sub distance {
    my ($node1, $node2) = @_;
    return sqrt(($node1->get_x_val - $node2->get_x_val)**2 + ($node1->get_y_val - $node2->get_y_val)**2);
}

# parses the file and returns an array of Node objects
sub parse_file {
    my @node_array;
    my ($filename) = @_;
    open(my $fh, '<:encoding(UTF-8)', $filename)
      or die "Could not open file '$filename' $!";

    # used to skip first 6 lines of input file
    my $i = 0;
     
    while (my $row = <$fh>) {
        $i = $i + 1;
        chomp $row;
        if ($row eq "EOF") {
            last;
        }
        if ($i > 6) {
            my ($num, $x, $y) = split ' ', $row;
            my $node = Node->new(node_num => $num, x_val => $x, y_val => $y);
            push @node_array, $node;
        }
    }
    return @node_array;
}

main();



