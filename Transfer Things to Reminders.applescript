-- Choose list to import

tell application "Things3"
	activate
	set allLists to name of every project
	set chosenThingsList to (choose from list allLists with prompt "Select the list to add reminders from" without empty selection allowed)
	-- if the user presses cancel, abort
	if chosenThingsList is false then return
	set myLists to every project whose name is chosenThingsList
end tell

-- Choose list to import to

tell application "Reminders"
	activate
	-- ask which list to add to
	set allLists to name of every list
	set chosenReminderList to (choose from list allLists with prompt "Select the list to add reminders to" without empty selection allowed)
	-- if the user presses cancel, abort
	if chosenReminderList is false then return
	set chosenReminderList to chosenReminderList as string
end tell

-- Trabsfer list data

tell application "Things3"
	repeat with myList in myLists
		set myTodos to to dos in myList
		set myCount to 0
		repeat with myTodo in myTodos
			set myCount to myCount + 1
			set myName to name of myTodo
			set myTags to every tag of myTodo
			set myTagNames to ""
			repeat with myTag in myTags
				set myTagNames to myTagNames & " #" & (name of myTag)
			end repeat
			if myTagNames is not "" then
				set myName to myName & " " & myTagNames
			end if
			set myBody to notes of myTodo
			tell application "Reminders"
				show
				tell list chosenReminderList
					show
					make new reminder at end Â
						with properties {name:myName, body:myBody}
				end tell
			end tell
		end repeat
	end repeat
end tell