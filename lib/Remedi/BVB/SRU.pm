use utf8;
package Remedi::BVB::SRU;

# ABSTRACT: Class for fetching MARC-XML via SRU Interface

use Moose;
use LWP::UserAgent;
use MooseX::AttributeShortcuts;
use Remedi::Types qw(B3KatID LWPUserAgent);
use URI::FromHash qw(uri_object);
use namespace::autoclean;

has 'user_agent' => ( is => 'lazy', isa => LWPUserAgent );
   
sub get_uri {
    my ($self, $marcxml_idn) = @_;

    my $query_param =  'marcxml.idn=' . $marcxml_idn;

    my $query = {
        version        => '1.1',
        recordSchema   => 'marcxml',
        operation      => 'searchRetrieve',
        query          => $query_param,
        maximumRecords => 1,          
                 
    };
    my $uri_hash = {
        scheme => 'http',
        host   => 'bvbr.bib-bvb.de',
        port   => 5661,
        path   => '/bvb01sru',
        query  => $query,
    };

    return uri_object($uri_hash);
}

sub _build_user_agent { LWP::UserAgent->new() }
    
   
sub get_marc_xml {
    my ($self, $bv_nr) = @_;
    
    die "'$bv_nr' is not a valid B3KatID" unless is_B3KatID($bv_nr);
    
    my $response = $self->user_agent->get( $self->get_uri($bv_nr) );

    if ($response->is_success) {    # uncoverable branch false
        return $response->decoded_content;
    }
    else {
        # uncoverable statement
        die 'Fetching ' . $bv_nr . ' failed: ' .  $response->status_line; 
    }
}


__PACKAGE__->meta->make_immutable; 
1;
