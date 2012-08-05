#!/usr/bin/perl

use Linux::Inotify2;

#change the Maildir here if needed:
my $watchdir = $ENV{'HOME'} . "/Maildir/INBOX/new";
$watchdir = $ARGV[0] if($ARGV[0] ne "")

sub awesomeNotify {
	open(fh, "<", $_[0]);
		my @email = <fh>;
	close(fh);
	($from, @from) = grep(/From:/,@email);
	print $from;
	$from =~ s/From://;
	$from =~ s/\n//;
	($subject, @subject) = grep(/Subject:/,@email);
	print $subject;
	$subject =~ s/Subject://;
	$subject =~ s/\n//;
	open(fh,'|awesome-client'); #uses awesome-client to execute the lua command
		print fh "naughty.notify({ title=\"".$from."\", text = \"".$subject."\", timeout = 10 })"; 
	close fh;
}


# create a new object
my $inotify = new Linux::Inotify2
    or die "unable to create new inotify object: $!";



 # add watchers
 $inotify->watch ($watchdir, IN_ALL_EVENTS, sub {
    my $e = shift;
    my $name = $e->fullname;
    #print "test\n";
    print "$name was accessed\n" if $e->IN_CREATE;
    awesomeNotify($name) if $e->IN_CREATE;
    awesomeNotify($name) if $e->IN_MOVED_TO;
    print "$name is no longer mounted\n" if $e->IN_UNMOUNT;
    print "$name is gone\n" if $e->IN_IGNORED;
    print "events for $name have been lost\n" if $e->IN_Q_OVERFLOW;
 
    # cancel this watcher: remove no further events
    #$e->w->cancel;
 });

 # manual event loop
 1 while $inotify->poll;
# }
