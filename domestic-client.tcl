#!/usr/bin/tclsh

package require Tk
package require json;   # using tcllib

# arguments
if { $argc < 1 } {
    puts stderr "usage: $argv0 <jsonfile>"
    exit 1
}
set filepath [lindex $argv 0]
set configpath "config.json"

proc refresh { filepath } {
    # get info from the status file 
    set f [open $filepath]
    set data [read $f]
    close $f
    set unmarshalled [json::json2dict $data]

    # treasury
    global treasury
    set treasury [dict get $unmarshalled "Treasury" "Total"]
    global treasuryEntries
    set entries [dict get $unmarshalled "Treasury" "Entries"]
    set treasuryEntries [getEntryList $entries]
    
    global savingsPercent
    global savings
    global free
    set numericPercent [expr $savingsPercent / 100.0]
    set savings [format %.2f [expr $treasury * $numericPercent]]
    set free [format %.2f [expr $treasury - $savings]]

    # income
    global income
    set income [dict get $unmarshalled "Income" "Total"]
    global incomeEntries
    set entries [dict get $unmarshalled "Income" "Entries"]
    set incomeEntries [getEntryList $entries]    

    # expenses
    global expenses
    set expenses [dict get $unmarshalled "Expenses" "Total"]
    global expensesEntries
    set entries [dict get $unmarshalled "Expenses" "Entries"]
    set expensesEntries [getEntryList $entries]

    # balance
    global balance
    set balance [dict get $unmarshalled "Balance"]
}

proc getEntryList { entryMap } {
    set entries [list]

    foreach entry $entryMap {
        set name [dict get $entry "Name"]
        set amount [dict get $entry "Amount"]
        set date [dict get $entry "Date"]

        lappend entries "$name $amount $date"
    }

    return $entries
}

proc save {path} {
    global savingsPercent
    set cfg [dict create savingsPercent $savingsPercent]    
    set j [json::dict2json $cfg]

    set configFile [open $path "w"]
    puts $configFile $j
    close $configFile
}

proc closeWindow {} {
    exit 0
}

proc loadConfig {path} {
    set f [open $path]
    set data [read $f]
    close $f

    set cfg [json::json2dict $data]

    global savingsPercent
    set savingsPercent [dict get $cfg "savingsPercent"]
}

# ### Main Page ###

# top menubar
option add *tearOff 0; # prevent some weird stuff on the menues

set m .menubar

menu $m
. configure -menu $m

menu $m.file
$m add cascade -menu $m.file -label File
$m.file add command -label "Save" -command {"save" $configpath}
$m.file add command -label "Refresh" -command {"refresh" $filepath}
$m.file add command -label "Close" -command "closeWindow"

# body

# make outer frame fill the window
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

ttk::frame .body -padding "5 5 5 5"
grid .body -column 0 -row 0 -sticky nsew

# make body fill length
grid columnconfigure .body 0 -weight 1

# labels padding
set top "5 0"

# treasury
set savingsTitle "Savings"
set freeTitle "Free"
global savings; set savings 0
global free; set free 0
global savingsPercent;

ttk::frame .body.treasury -borderwidth 1 -relief solid
ttk::label .body.treasury.savingsTitle -textvariable savingsTitle
ttk::label .body.treasury.freeTitle -textvariable freeTitle
ttk::label .body.treasury.savings -textvariable savings
ttk::label .body.treasury.free -textvariable free 
tk::listbox .body.treasury.entries -yscrollcommand ".body.treasury.scroll set" -height 5 -listvariable treasuryEntries
ttk::scrollbar .body.treasury.scroll -command ".body.treasury.entries yview" -orient vertical
tk::scale .body.treasury.scale -from 0 -to 100 -orient horizontal -variable savingsPercent

grid .body.treasury -column 0 -row 0 -sticky news -pady $top
grid .body.treasury.savingsTitle -column 0 -row 0 -sticky nw -padx "0 10"
grid .body.treasury.freeTitle -column 1 -row 0 -sticky nw
grid .body.treasury.savings -column 0 -row 1 -sticky nw
grid .body.treasury.free -column 1 -row 1 -sticky nw
grid .body.treasury.entries -columnspan 3 -column 0 -row 2 -sticky news
grid .body.treasury.scroll -column 3 -row 2 -sticky ns
grid .body.treasury.scale -column 0 -row 3 -columnspan 3 -sticky news

# make income frame and listbox resize with window
grid rowconfigure .body 0 -weight 1
grid columnconfigure .body.treasury 2 -weight 1
grid rowconfigure .body.treasury 2 -weight 1

# income
set incomeTitle "Income"
global income; set income 0
global incomeEntries

ttk::frame .body.income -borderwidth 1 -relief solid
ttk::label .body.income.title -textvariable incomeTitle
ttk::label .body.income.value -textvariable income
tk::listbox .body.income.entries -yscrollcommand ".body.income.scroll set" -height 5 -listvariable incomeEntries
ttk::scrollbar .body.income.scroll -command ".body.income.entries yview" -orient vertical

grid .body.income -column 0 -row 1 -sticky news -pady $top
grid .body.income.title -column 0 -row 0 -padx "0 10"
grid .body.income.value -column 1 -row 0
grid .body.income.entries -columnspan 3 -column 0 -row 1 -sticky nwes
grid .body.income.scroll -column 3 -row 1 -sticky ns

# make income frame height and width resize with window
grid rowconfigure .body 1 -weight 1; # parent frame
grid columnconfigure .body.income 2 -weight 1; # column 3 so only listbox width changes
grid rowconfigure .body.income 1 -weight 1; # row 1 so only listbox height changes

# expenses
set expensesTitle "Expenses"
global expenses; set expenses 0

ttk::frame .body.expenses -borderwidth 1 -relief solid
ttk::label .body.expenses.title -textvariable expensesTitle
ttk::label .body.expenses.value -textvariable expenses
tk::listbox .body.expenses.entries -yscrollcommand ".body.expenses.scroll set" -height 5 -listvariable expensesEntries
ttk::scrollbar .body.expenses.scroll -command ".body.expenses.entries yview" -orient vertical

grid .body.expenses -column 0 -row 2 -sticky news -pady $top
grid .body.expenses.title -column 0 -row 0 -padx "0 10"
grid .body.expenses.value -column 1 -row 0
grid .body.expenses.entries -columnspan 3 -column 0 -row 1 -sticky news
grid .body.expenses.scroll -column 3 -row 1 -sticky ns

# make income frame height and width resize with window
grid rowconfigure .body 2 -weight 1; # parent frame
grid columnconfigure .body.expenses 2 -weight 1; # column 3 so only listbox width changes
grid rowconfigure .body.expenses 1 -weight 1; # row 1 so only listbox height changes

# balance
set balanceTitle "Net Gain"
global balance; set balance 0

ttk::frame .body.balance -borderwidth 1 -relief solid
ttk::label .body.balance.title -textvariable balanceTitle
ttk::label .body.balance.value -textvariable balance

grid .body.balance -column 0 -row 3 -sticky news -pady $top
grid .body.balance.title -column 0 -row 0 -padx "0 10"
grid .body.balance.value -column 1 -row 0

# #####################

refresh $filepath
loadConfig $configpath
