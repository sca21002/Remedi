use utf8;
package Remedi::Types::Remedi;

# ABSTRACT: Types library for Remedi specific types 

use strict;
use warnings;
use Carp qw(confess);
use DateTime::Format::Strptime;
use Log::Log4perl qw(:levels);

# predeclare our own types
use MooseX::Types -declare => [ qw(
    ArrayRefOfImagefile
    ArrayRefOfRemediFile
    ArrayRefOfSimpleStr
    ArrayRefOfMaybeSimpleStr 
    ArrayRefOfUsetype
    B3KatID
    Colortype
    DateTime
    Digit
    Dir
    DateTime
    DoubleStr
    File
    FontSize
    HashRefOfNonEmptySimpleStr
    HashRefOfNum
    HashRefOfWord
    ImageExifTool
    Imagefile
    ImagefileDestFormat
    ImagefileDestFormatKey
    ImagefileSourceFormat
    ImageSizeClass
    ISIL
    Lang
    Library_id
    Library_union_id
    LogLevel
    LWPUserAgent
    MaybeFile
    MaybeRemediFile
    MaybeSimpleStr
    MetadataFormat
    Niss
    NonEmptyDoubleStr 
    Path
    PathOrUndef
    PDFDict
    PDFDate
    RemediExifToolTag
    RemediFile
    RemediMETSCSV
    RemediPdfApi2
    RemediPdfApi2Page
    RemediRegexpRef
    ThumbnailFormat
    TimeTracker
    URN_level
    Usetype
    Word
) ];

use MooseX::Types::Common::String qw( NonEmptySimpleStr SimpleStr);

use MooseX::Types::Moose qw(
    ArrayRef CodeRef HashRef Int Maybe Num Str RegexpRef
);

subtype ArrayRefOfSimpleStr, as ArrayRef[SimpleStr]; 

subtype MaybeSimpleStr, as Maybe[SimpleStr];

subtype ArrayRefOfMaybeSimpleStr, as ArrayRef[MaybeSimpleStr];

use Path::Tiny ();

subtype B3KatID,
    as Str,
    where { /^BV\d{9}$/ },
    message { msg($_, "'%s' is not a valid BV-Nr.") }
    ;  

enum    Colortype, [qw( monochrome grayscale color )];  

class_type DateTime, {class => 'DateTime'};

subtype Digit,
    as Int,
    where { $_ >= 0 && $_ < 10  },
    message { msg($_, "'%s' is not a digit") };


subtype DoubleStr,
    as Str,
    where { (length($_) <= 255 * 2) && ($_ !~ m/\n/) },
    message { "Must be a single line of no more than 512 chars" },
    ( $Moose::VERSION >= 2.0200
        ? inline_as {
          $_[0]->parent()->_inline_check( $_[1] ) . ' && '
          . qq{ ( (length($_[1]) <= 255 * 2) && ($_[1] !~ m/\n/) ) };
        }
        : ()
    );

subtype NonEmptyDoubleStr,
    as DoubleStr,
    where { length($_) > 0 },
    message { "Must be a non-empty single line of no more than 512 chars" },
    ( $Moose::VERSION >= 2.0200
        ? inline_as {
            $_[0]->parent()->_inline_check( $_[1] ) . ' && '
            . qq{ (length($_[1]) > 0) };
        }
        : ()
    );

class_type PDFDict, { class => 'PDF::API2::Basic::PDF::Dict' };
    
subtype FontSize,
    as Int,
    where { $_ >= 4  && $_ <= 72 },
    message { msg($_, "not a valid font size '%s'") };

class_type ImageExifTool, { class => 'Image::ExifTool' };

class_type Imagefile, { class => 'Remedi::Imagefile' };

subtype ArrayRefOfImagefile, as ArrayRef[Imagefile];

class_type LWPUserAgent, { class => 'LWP::UserAgent' };

class_type RemediExifToolTag, { class => 'Remedi::ExifTool::Tag' };

class_type RemediFile, { class => 'Remedi::RemediFile' };

subtype MaybeRemediFile, as Maybe[RemediFile];

subtype ArrayRefOfRemediFile, as ArrayRef[RemediFile];

class_type RemediMETSCSV, { class => 'Remedi::METS::CSV' };

class_type RemediPdfApi2, { class => 'Remedi::PDF::API2' };

class_type RemediPdfApi2Page, { class => 'Remedi::PDF::API2::Page' };

class_type TimeTracker, { class => 'Log::Log4perl::Util::TimeTracker' };

enum    ImagefileDestFormat, [qw(PDF TIFF)];

enum    ImagefileDestFormatKey, [qw(JPEG_TIFF PDF TIFF)];
      
coerce  ImagefileDestFormat,
    from Str,
    via { uc $_ };
    
enum    ImagefileSourceFormat, [qw(TIFF PDF)];
      
coerce  ImagefileSourceFormat,
    from Str,
    via { uc $_ };

enum    ImageSizeClass, [qw(small large)];

subtype ISIL,
    as Str,
    where { /^DE-[A-Za-z0-9\/\-:]{1,11}$/},
    message { msg($_, "'%s' is not a valid ISIL(DE)") };

subtype Library_id,
    as Str,
    where { /^[A-Z\d][A-Za-z0-9\/]*$/ },
    message { msg($_, "'%s' is not a valid library id") };

subtype Library_union_id,
    as Str,
    where { /^[a-z]{3}$/ },
    message { msg($_, "'%s' is not a valid library union id") };
    
enum LogLevel, [$OFF, $FATAL, $ERROR, $WARN, $INFO, $DEBUG, $TRACE, $ALL];

coerce LogLevel,
    from Str,
    via { Log::Log4perl::Level::to_priority($_) }; 

enum    MetadataFormat, [qw(MARC DC)];

subtype Niss,
    as Str,
    where { /^[a-z0-9\:\-]*$/ },
    message {msg($_, "'%s' is not a valid identifier string (NISS) for a URN")};
    
subtype Path, as 'Path::Tiny';

subtype PDFDate,
    as Str,
    where {
        return unless s/([+-])(\d{2})'(\d{2})'\z/$1$2$3/;
        my $strp = DateTime::Format::Strptime->new(
            pattern   => 'D:%Y%m%d%H%M%S%z',
            locale    => 'de_DE',
            time_zone => 'Europe/Berlin',
        );
        my $dt = $strp->parse_datetime($_);
    },    
    message { msg($_, "'%s' is not a valid PDF date format") };

# creation date in acrobat date format, e.g. D:20080428120000+02'00'

coerce PDFDate,
    from DateTime,
    via {
        my $pdfdate = $_->strftime('D:%Y%m%d%H%M%S%z');
        $pdfdate =~ s/([+-])(\d{2})(\d{2})\z/$1$2'$3'/
            or croak("Falsche Zeitangaben $pdfdate");
        return $pdfdate;
    },
;

subtype File, as Path,
    where { $_->is_file }, message { msg($_, "File '%s' does not exist") };

subtype Dir,  as Path,
    where { $_->is_dir },  message { msg($_, "Directory '%s' does not exist") };

subtype MaybeFile, as Maybe[File];

for my $type ( Path, File, Dir, MaybeFile ) {
    coerce(
        $type,
        from Str,
            via {
                return unless $_;
                my $path = Path::Tiny::path(
                    s#__HOME__#Path::Tiny::path(__FILE__)->parent(4)#er
                );
                return $path;
            },
        from ArrayRef,
            via {
                Path::Tiny::path(
                    map { s#__HOME__#Path::Tiny::path(__FILE__)->parent(4)#er }
                    @$_
                );
            },
    );        
};

subtype HashRefOfNonEmptySimpleStr, as HashRef[NonEmptySimpleStr];
subtype HashRefOfNum,               as HashRef[Num];


subtype Lang, as Str,
    where { (length($_) == 3) && ($_ =~ m/^[a-z]+$/) },
    message { msg( $_,
        "Must be a 3 letter language code, but got '%s'"
    ) }; 

subtype RemediRegexpRef, as RegexpRef;

coerce  RemediRegexpRef,
    from Str,
    via {
        my $reg;
        eval { $reg = qr{$_}ixms };
        confess msg($_, "'%s' is not a valid regular expresion: $@") if $@;
        return $reg;
    };
    
enum    ThumbnailFormat, [qw ( GIF PNG )];

enum    URN_level, [qw(no_urn object single_page)];

enum    Usetype, [qw( archive reference ocr thumbnail ingest)];

subtype ArrayRefOfUsetype, as ArrayRef[Usetype];

subtype Word, as Str,
    where { (length($_) <= 255) && ($_ =~ m/^[A-Za-z0-9_]+$/) },
    message { msg( $_,
        "Must be a alphanumeric string of no more than 255 chars, but got '%s'"
    ) }; 

# declaration order is important here: Word before HashRef[Word], otherwise
# Word type constraint is created silently and undesirable by Moose itself

subtype HashRefOfWord,              as HashRef[Word];



eval { require MooseX::Getopt; };
if ( !$@ ) {
    MooseX::Getopt::OptionTypeMap->add_option_type_to_map( $_, '=s', )
      for ( 'Path::Tiny', Path );
}



sub msg {
    my ($value, $format) = @_;
    
    $value = defined $value ? $value : 'undef';
    sprintf($format, $value); 
}

1;
