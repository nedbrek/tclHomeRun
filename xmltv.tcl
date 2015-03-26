package require sqlite3
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

# update db with channel xml entries
# id is the channel id (blah.labs.zap2it.com)
# then there is a dict of lists with the content of any child nodes
# NOTE: nodes can repeat, that is why it is lists
proc channelsToDb {db root} {

	$db eval {
		CREATE TABLE IF NOT EXISTS channels(
			k INTEGER PRIMARY KEY AUTOINCREMENT,
			id TEXT not null UNIQUE ON CONFLICT REPLACE,
			nodes TEXT not null
		)
	}

	$db eval {BEGIN TRANSACTION}

	set channels [$root selectNodes {//channel}]
	foreach c $channels {

		set id [$c getAttribute "id"]

		set nodes [dict create]
		foreach ch [$c childNodes] {
			set nodeName [$ch nodeName]
			dict lappend nodes $nodeName [$ch text]
      }

		$db eval {
			INSERT INTO channels
			(id, nodes)
			VALUES
			($id, $nodes)
		}
   }

	$db eval {END TRANSACTION}
}


#################################
sqlite3 db "xmltv.db"

set f [open "listings.xml"]
set root [dom parse -channel $f]
close $f

#set chnGrp [hashChannels $root]
channelsToDb db $root

if {0} {
	set chns [db eval {SELECT id, nodes from channels WHERE nodes LIKE $chnName}]
	foreach {id nodes} $chns { puts "[dict get $nodes display-name]" }
}

