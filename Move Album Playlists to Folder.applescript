tell application "Music"
	-- Let User choose Folder
	set allFolderNames to name of every folder playlist
	set chosenFolderName to (choose from list allFolderNames with prompt "Select the folder to move album playlists to." without empty selection allowed)
	-- if the user presses cancel, abort
	if chosenFolderName is false then
		display dialog "Please choose a playlist folder."
		return
	end if
	set myFolder to every folder playlist whose name is chosenFolderName
	if number of items of myFolder is greater than 0 then
		set myFolder to first item of myFolder
	else
		display dialog "Please choose a playlist folder."
	end if
	-- Collect all (User) Playlists with no parent
	set myCounter to 0
	--
	set myPlaylistList to {}
	set userPlaylists to every user playlist
	repeat with userPlaylist in userPlaylists
		copy userPlaylist to myUserPlayList
		set hasParent to false
		tell userPlaylist
			try
				get parent of it
				set hasParent to true
			on error
				set hasParent to false
			end try
			if hasParent is false then
				set end of myPlaylistList to {name of it, myUserPlayList}
				set myCounter to myCounter + 1
			end if
			if myCounter is 100 then
				-- exit repeat
			end if
		end tell
	end repeat
	-- Album Playlist Regular Expression
	set albumRegEx to "[^\\-|^–]*[-|–] .*"
	set movedPlaylists to {}
	-- Search for all matching playlists
	set myCounter to 0
	--
	repeat with myPlaylist in myPlaylistList
		set myPlaylistName to first item of myPlaylist
		set myPlaylistRefernce to second item of myPlaylist
		tell myPlaylistRefernce
			if number of items of (my matchRegEx(myPlaylistName, albumRegEx)) is greater than 0 then
				-- set name of it to (my replaceRegEx(myPlaylistName, "☆ ", ""))
				move it to myFolder
				set end of movedPlaylists to myPlaylistName
				set myCounter to myCounter + 1
				if myCounter is 1 then
					-- exit repeat
				end if
			end if
		end tell
	end repeat
	return movedPlaylists
end tell

-- Cocoa helpers

use framework "Foundation"
on trim(sourceText)
	-- create Cocoa string from passed AppleScript string
	set sourceString to current application's NSString's stringWithString:sourceText
	-- trim white space around Cocoa string
	set the trimmedCocoaString to ¬
		sourceString's stringByTrimmingCharactersInSet:(current application's NSCharacterSet's whitespaceCharacterSet)
	-- return result coerced to an AppleScript string
	return (trimmedCocoaString as string)
end trim

on matchRegEx(someText, regEx)
	set theOptions to ((current application's NSRegularExpressionDotMatchesLineSeparators) as integer) + ((current application's NSMatchingWithoutAnchoringBounds) as integer)
	set theRegEx to current application's NSRegularExpression's regularExpressionWithPattern:regEx options:theOptions |error|:(missing value)
	set theFinds to theRegEx's matchesInString:someText options:0 range:{location:0, |length|:length of someText}
	set theFinds to theFinds as list -- so we can loop through
	set theResult to {} -- we will add to this
	set theNSString to current application's NSString's stringWithString:someText
	repeat with i from 1 to count of items of theFinds
		set theRange to (item i of theFinds)'s range()
		set end of theResult to (theNSString's substringWithRange:theRange) as string
	end repeat
	return theResult
end matchRegEx

on replaceRegEx(someText, regEx, replaceBy)
	set theString to current application's NSString's stringWithString:someText
	set theString to theString's stringByReplacingOccurrencesOfString:regEx withString:replaceBy options:(current application's NSRegularExpressionSearch) range:{location:0, |length|:length of someText}
	return theString as text
end replaceRegEx

on listToStringUsingTextItemDelimiter(sourceList, textItemDelimiter)
	-- create a Cocoa array from the passed AppleScript list
	set the CocoaArray to current application's NSArray's arrayWithArray:sourceList
	-- create a Cocoa string from the Cocoa array using the passed delimiter string
	set the CocoaString to CocoaArray's componentsJoinedByString:textItemDelimiter
	-- return the Cocoa string coerced into an AppleScript string
	return (CocoaString as string)
end listToStringUsingTextItemDelimiter