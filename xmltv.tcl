package require tdom

#################################
# convert the channel xml entries to a dictionary of dictionaries
# id is the channel id (blah.labs.zap2it.com)
# then there is a dict of lists with the content of any child nodes
# NOTE: nodes can repeat, that is why it is lists
proc hashChannels {root} {
	set ret [dict create]

	set channels [$root selectNodes {//channel}]
	foreach c $channels {

		set id [$c getAttribute "id"]

		set nodes [dict create]
		foreach ch [$c childNodes] {
			set nodeName [$ch nodeName]
			dict lappend nodes $nodeName [$ch text]
      }

		dict set ret $id $nodes
   }

	return $ret
}


#################################
set f [open "listings.xml"]
set root [dom parse -channel $f]
close $f

set chnGrp [hashChannels $root]

