# ##crawl-offtopic link logger

bind pub - +link     ml-add
bind pub - !link     ml-add
bind pub - +nsfw     ml-add-nsfw
bind pub - !nsfw     ml-add-nsfw
bind pub - ?link     ml-find
bind pub - ?url      ml-find-url
bind pub - -link     ml-remv
bind pub - ?last5    ml-last5
bind pub - #link     ml-id
bind pub - ?linkulator ml-help
bind pub - ?help     ml-help
bind pub - !help     ml-help

bind msg - ?link     ml-msg-find
bind msg - ?url      ml-msg-find-url
bind msg - #link     ml-msg-id

proc ml-help { nick - - channel - } {
	putserv "PRIVMSG $channel :$nick, see my private message for assistance."
	puthelp "PRIVMSG $nick :Hi! I'm Linkulator!  For a link to all sorts of information about me, type #link 1 in the IRC channel where you asked for help."
	puthelp "PRIVMSG $nick :Command list:  +link, -link, +nsfw, ?nsfw, ?url, ?last5, #link, and, of course, ?help"
}

proc ml-find { nick - - channel data } {
	set tags [ list nsfw nws nms ]
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "DBUSER" -password "DBPASSWD" -db "DBNAME" ]
	mysql::use $dbconn "DBNAME"
	putlog "Linkulator: $nick searched the DB: '$data'"
	set nws 0
	foreach sw $tags {
		set fullsw {-}
		append fullsw $sw
		append fullsw { }
		if { [ string first $fullsw [ string tolower $data ] ] != -1 } {
			incr nws
			set data [ string map -nocase [ list $fullsw {} ] $data ]
		}	
	}
	set needle [ join $data " " ]
	if { [ string length [ string trim $needle ] ] < 1 } {
		putserv "PRIVMSG $channel :$nick, you didn't give me any criteria to searh for!"
		return 0
	}
	set query {select * from linkulator where status != 'ARCHIVED' and lower(description) like lower('%}
	append query $needle
	append query {%') and linktype }
	if { ( $nws > 0 ) } {
		append query {in ('SFW', 'NSFW') }
	} else {
		append query {= 'SFW' }
	}
	append query {order by id asc}
	set matches {}
	set hits 0

	putlog "Linkulator: Query '$query'"
	
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	if { ( $hits == 0 ) } {
		putlog "Linkulator: No matches found."
		putserv "PRIVMSG $channel :No matches found for $data."
		return 0
	}
	if { ( $hits > 0 ) && ( $hits < 5 ) } {
		if { ( $hits > 1 ) } {
			putserv "PRIVMSG $channel :$hits matches found:"
		}
		putlog "Linkulator: $hits match(es) found."
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]

			putserv "PRIVMSG $channel :$feedback"
		}
		return 0
	}
	if { ( $hits > 5 ) } {
		putlog "Linkulator: $hits matches found."
		puthelp "PRIVMSG $nick :Too many ($hits) matches found. Refine your search or use one of the following link IDs:"
		set idlist {}
		foreach item $matches {
			append idlist [ lindex $item 0 ]
			append idlist { }
		}
		puthelp "PRIVMSG $nick :$idlist"
		set randid [ lindex $idlist [ expr { int( rand() * [ llength $idlist ] ) } ] ]
		set query "select * from linkulator where id = $randid"
		set matches {}
		set hits 0
		foreach row [ mysqlsel $dbconn $query -list ] {
			lappend matches $row
			incr hits
		}
		putserv "PRIVMSG $channel :There were too many matches.  Here is one, selected randomly:"
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]
			putserv "PRIVMSG $channel :$feedback"
		}
		return 0
	}
}

proc ml-msg-find { nick - - data } {
	set tags [ list nsfw nws nms ]
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick searched the DB: '$data' via PM"
	set nws 0
	foreach sw $tags {
		set fullsw {-}
		append fullsw $sw
		append fullsw { }
		if { [ string first $fullsw [ string tolower $data ] ] != -1 } {
			incr nws
			set data [ string map -nocase [ list $fullsw {} ] $data ]
		}	
	}
	set needle [ join $data " " ]
	if { [ string length [ string trim $needle ] ] < 1 } {
		putserv "PRIVMSG $nick :Sorry, you didn't give me any criteria to searh for!"
		return 0
	}
	set query {select * from linkulator where status != 'ARCHIVED' and lower(description) like lower('%}
	append query $needle
	append query {%') and linktype }
	if { ( $nws > 0 ) } {
		append query {in ('SFW', 'NSFW') }
	} else {
		append query {= 'SFW' }
	}
	append query {order by id asc}
	set matches {}
	set hits 0

	putlog "Linkulator: Query '$query'"
	
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	if { ( $hits == 0 ) } {
		putlog "Linkulator: No matches found."
		putserv "PRIVMSG $nick :No matches found for $data."
		return 0
	}
	if { ( $hits > 0 ) && ( $hits < 5 ) } {
		if { ( $hits > 1 ) } {
			putserv "PRIVMSG $nick :$hits matches found:"
		}
		putlog "Linkulator: $hits match(es) found."
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]

			putserv "PRIVMSG $nick :$feedback"
		}
		return 0
	}
	if { ( $hits > 5 ) } {
		putlog "Linkulator: $hits matches found."
		puthelp "PRIVMSG $nick :Too many ($hits) matches found. Refine your search or use one of the following link IDs:"
		set idlist {}
		foreach item $matches {
			append idlist [ lindex $item 0 ]
			append idlist { }
		}
		puthelp "PRIVMSG $nick :$idlist"
		set randid [ lindex $idlist [ expr { int( rand() * [ llength $idlist ] ) } ] ]
		set query "select * from linkulator where id = $randid"
		set matches {}
		set hits 0
		foreach row [ mysqlsel $dbconn $query -list ] {
			lappend matches $row
			incr hits
		}
		putserv "PRIVMSG $nick :There were too many matches.  Here is one, selected randomly:"
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]
			putserv "PRIVMSG $nick :$feedback"
		}
		return 0
	}
}

proc ml-find-url { nick - - channel data } {
	set tags [ list nsfw nws nms ]
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick searched the DB: '$data'"
	set nws 0
	foreach sw $tags {
		set fullsw {-}
		append fullsw $sw
		append fullsw { }
		if { [ string first $fullsw [ string tolower $data ] ] != -1 } {
			incr nws
			set data [ string map -nocase [ list $fullsw {} ] $data ]
		}	
	}
	set needle [ join $data " " ]
	set query {select * from linkulator where status != 'ARCHIVED' and lower(url) like lower('%}
	append query $needle
	append query {%') and linktype }
	if { ( $nws > 0 ) } {
		append query {in ('SFW', 'NSFW') }
	} else {
		append query {= 'SFW' }
	}
	append query {order by id asc}
	set matches {}
	set hits 0

	putlog "Linkulator: Query '$query'"
	
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	if { ( $hits == 0 ) } {
		putlog "Linkulator: No matches found."
		putserv "PRIVMSG $channel :No matches found for $data."
		return 0
	}
	if { ( $hits > 0 ) && ( $hits < 5 ) } {
		if { ( $hits > 1 ) } {
			putserv "PRIVMSG $channel :$hits matches found:"
		}
		putlog "Linkulator: $hits match(es) found."
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]

			putserv "PRIVMSG $channel :$feedback"
		}
		return 0
	}
	if { ( $hits > 5 ) } {
		putlog "Linkulator: $hits matches found."
		puthelp "PRIVMSG $nick :Too many ($hits) matches found. Refine your search or use one of the following link IDs:"
		set idlist {}
		foreach item $matches {
			append idlist [ lindex $item 0 ]
			append idlist { }
		}
		puthelp "PRIVMSG $nick :$idlist"
		set randid [ lindex $idlist [ expr { int( rand() * [ llength $idlist ] ) } ] ]
		set query "select * from linkulator where id = $randid"
		set matches {}
		set hits 0
		foreach row [ mysqlsel $dbconn $query -list ] {
			lappend matches $row
			incr hits
		}
		putserv "PRIVMSG $channel :There were too many matches.  Here is one, selected randomly:"
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]
			putserv "PRIVMSG $channel :$feedback"
		}
		return 0
	}
}

proc ml-msg-find-url { nick - - data } {
	set tags [ list nsfw nws nms ]
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick searched the DB: '$data' via PM"
	set nws 0
	foreach sw $tags {
		set fullsw {-}
		append fullsw $sw
		append fullsw { }
		if { [ string first $fullsw [ string tolower $data ] ] != -1 } {
			incr nws
			set data [ string map -nocase [ list $fullsw {} ] $data ]
		}	
	}
	set needle [ join $data " " ]
	set query {select * from linkulator where status != 'ARCHIVED' and lower(url) like lower('%}
	append query $needle
	append query {%') and linktype }
	if { ( $nws > 0 ) } {
		append query {in ('SFW', 'NSFW') }
	} else {
		append query {= 'SFW' }
	}
	append query {order by id asc}
	set matches {}
	set hits 0

	putlog "Linkulator: Query '$query'"
	
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	if { ( $hits == 0 ) } {
		putlog "Linkulator: No matches found."
		putserv "PRIVMSG $nick :No matches found for $data."
		return 0
	}
	if { ( $hits > 0 ) && ( $hits < 5 ) } {
		if { ( $hits > 1 ) } {
			putserv "PRIVMSG $nick :$hits matches found:"
		}
		putlog "Linkulator: $hits match(es) found."
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]

			putserv "PRIVMSG $nick :$feedback"
		}
		return 0
	}
	if { ( $hits > 5 ) } {
		putlog "Linkulator: $hits matches found."
		puthelp "PRIVMSG $nick :Too many ($hits) matches found. Refine your search or use one of the following link IDs:"
		set idlist {}
		foreach item $matches {
			append idlist [ lindex $item 0 ]
			append idlist { }
		}
		puthelp "PRIVMSG $nick :$idlist"
		set randid [ lindex $idlist [ expr { int( rand() * [ llength $idlist ] ) } ] ]
		set query "select * from linkulator where id = $randid"
		set matches {}
		set hits 0
		foreach row [ mysqlsel $dbconn $query -list ] {
			lappend matches $row
			incr hits
		}
		putserv "PRIVMSG $nick :Here is one, selected randomly:"
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]
			putserv "PRIVMSG $nick :$feedback"
		}
		return 0
	}
}

proc ml-add { nick - - channel data } {
        package require mysqltcl
        set tags [ list nsfw nws nms ]
        set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
        mysql::use $dbconn "offtopic"
        putlog "Linkulator: $nick added to the DB: '$data'"
        # Check for -nsfw switch
        set nws 0
        foreach sw $tags {
                set fullsw {-}
                append fullsw $sw
                append fullsw { }
                if { [ string first $fullsw [ string tolower $data ] ] != -1 } {
                        incr nws
                        set data [ string map -nocase [ list $fullsw {} ] $data ]
                }
        }

        set descsep [ string first " " $data ]
        set url [ string range $data 0 $descsep ]
        set description [ string range $data [ expr $descsep + 1 ] end ]

        putlog "url: $url"
        set newnick [ string map -nocase [ list "\\" "\\\\" "'" "\\'" ] $nick ]
        set description [ string map -nocase [ list "\\" "\\\\" "'" "\\'" ] $description ]
        if { ( $nws != 0 ) } {
                if { ! [ string match -nocase "*nsfw*" $description ] } then {
                        set description "$description (NSFW!)"
                } 
        }
        set url [ string map -nocase [ list "\\" "\\\\" "'" "\\'" ] $url ] 
        set desclen [ string length $description ]
        if { ( $desclen < 5 ) } {
                putserv "PRIVMSG $channel :$nick, you need to describe the link, please.  It has not been recorded."
                return 0
        } else {
                set query "insert into linkulator (owner, url, description, linktype) values ('$newnick', '$url', '$description', "
                if { ( $nws == 0 ) } {
                        append query "'SFW' )"
                } else {
                        append query "'NSFW' )"
                }
                mysql::exec $dbconn $query
                #putlog "L: Query: $query"
                set linkid [ mysql::insertid $dbconn ]
                putserv "PRIVMSG $channel :Thanks, $nick! You have added link #$linkid."
        }
}

proc ml-add-nsfw { nick - - channel data } {
	package require mysqltcl
	set tags [ list nsfw nws nms ]
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick added to the DB: '$data'"
	# Check for -nsfw switch
	set nws 1
	foreach sw $tags {
		set fullsw {-}
		append fullsw $sw
		append fullsw { }
		if { [ string first $fullsw [ string tolower $data ] ] != -1 } {
			incr nws
			set data [ string map -nocase [ list $fullsw {} ] $data ]
		}	
	}
	set sansurl [ lassign $data url ]
	putlog "url: $url"
	set newnick [ string map -nocase [ list {'} {\'} ] $nick ]
	set description [ string map -nocase [ list {'} {\'} ]  [ join $sansurl " " ] ]
	if { ! [ string match -nocase "*nsfw*" $description ] } then {
		set description "$description (NSFW!)"	
	}
	set url [ string map -nocase [ list {'} {\'} ] [ lindex $url end ] ]
	set desclen [ string length $description ]
	if { ( $desclen < 5 ) } {
		putserv "PRIVMSG $channel :$nick, you need to describe the link, please.  It has not been recorded."
		return 0
	} else {
		set query "insert into linkulator (owner, url, description, linktype) values ('$newnick', '$url', '$description', 'NSFW' )"
		mysql::exec $dbconn $query
		set linkid [ mysql::insertid $dbconn ]
		putserv "PRIVMSG $channel :Thanks, $nick! You have added link #$linkid."
	}
}

proc ml-remv { nick - - channel data } {
	if { ( [ string is digit [ string trim $data ] ] ) } {
	} else {
		putserv "PRIVMSG $channel :$nick, -link must be followed by a number."
		return 0
	}
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick tried to kill link # $data."
	set query "select * from linkulator where id = $data and status != 'ARCHIVED'"
	set matches {}
	set hits 0
	putlog "Linkulator: Query '$query'"
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	if { ( $hits == 0 ) } {
		putlog "Linkulator: No matches found."
		putserv "PRIVMSG $channel :No such link id, $nick."
		return 0
	}
	if { ( $hits == 1 ) } {
		set query "update linkulator set status='ARCHIVED' where id = "
		append query [ string trim $data ]	
		mysql::exec $dbconn $query
		putserv "PRIVMSG $channel :Link has been archived."
		return 0
	}
	
}

proc ml-last5 { nick - - channel data } {
	set tags [ list nsfw nws nms ]
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick searched the DB: '$data'"
	set nws 0
	foreach sw $tags {
		set fullsw {-}
		append fullsw $sw
		append fullsw { }
		if { [ string first $fullsw [ string tolower $data ] ] != -1 } {
			incr nws
			set data [ string map -nocase [ list $fullsw {} ] $data ]
		}	
	}
	set needle [ join $data " " ]
	if { [ string length [ string trim $needle ] ] < 1 } {
		set searchowner 0
	} else {
		set searchowner 1
	}

	set qs "select * from linkulator where status != 'ARCHIVED' "
	set qws "and linktype = 'SFW' "
	set qo "and lower(owner) like lower('$data') "
	set qe "order by ts desc limit 5"
	
	set query $qs
	if { ( $nws > 0 ) } {
	} else {
		append query $qws
	}

	if { ( $searchowner > 0 ) } {
		append query $qo
	}

	append query $qe

#	putlog "Linkulator: Query - $query"
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	foreach item $matches {
		set feedback {Link #}
		append feedback [ lindex $item 0 ]
		append feedback {: }
		append feedback [ lindex $item 2 ]
		append feedback { - }
		append feedback [ lindex $item 3 ]
		append feedback {, from }
		append feedback [ lindex $item 1 ]

		putserv "PRIVMSG $channel :$feedback"
	}
	return 0

}

proc ml-id { nick - - channel data } {
	if { ( [ string is digit [ string trim $data ] ] ) } {
	} else {
		putserv "PRIVMSG $channel :$nick, #link must be followed by a number."
		return 0
	}
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick sought out link # $data."
	set query "select * from linkulator where id = $data and status != 'ARCHIVED'"
	set matches {}
	set hits 0
	putlog "Linkulator: Query '$query'"
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	if { ( $hits == 0 ) } {
		putlog "Linkulator: No matches found."
		putserv "PRIVMSG $channel :No such link id, $nick."
		return 0
	} 
	if { ( $hits == 1 ) } {
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]
			putserv "PRIVMSG $channel :$feedback"
		}
		return 0	
	}
}

proc ml-msg-id { nick - - data } {
	if { ( [ string is digit [ string trim $data ] ] ) } {
	} else {
		putserv "PRIVMSG $nick :$nick, #link must be followed by a number."
		return 0
	}
	package require mysqltcl
	set dbconn [ mysqlconnect -host localhost -user "offtopic" -password "BteGN21B" -db "offtopic" ]
	mysql::use $dbconn "offtopic"
	putlog "Linkulator: $nick sought out link # $data."
	set query "select * from linkulator where id = $data and status != 'ARCHIVED'"
	set matches {}
	set hits 0
	putlog "Linkulator: Query '$query'"
	foreach row [ mysqlsel $dbconn $query -list ] {
		lappend matches $row
		incr hits
	}
	if { ( $hits == 0 ) } {
		putlog "Linkulator: No matches found."
		putserv "PRIVMSG $nick :No such link id, $nick."
		return 0
	} 
	if { ( $hits == 1 ) } {
		foreach item $matches {
			set feedback {Link #}
			append feedback [ lindex $item 0 ]
			append feedback {: }
			append feedback [ lindex $item 2 ]
			append feedback { - }
			append feedback [ lindex $item 3 ]
			append feedback {, from }
			append feedback [ lindex $item 1 ]
			putserv "PRIVMSG $nick :$feedback"
		}
		return 0	
	}
}

putlog "MySQL Testing Linkulator 2.0 loaded"
