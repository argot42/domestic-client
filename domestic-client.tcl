#!/usr/bin/tclsh

package require Tk
package require json;   # using tcllib

# arguments
#if { $argc < 1 } {
#    puts stderr "usage: $argv0 <jsonfile>"
#    exit 1
#}
#set filepath [lindex $argv 0]
set filepath status.json

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
    set treasuryEntries [dict get $unmarshalled "Treasury" "Entries"]

    # income
    global income
    set income [dict get $unmarshalled "Income" "Total"]
    global incomeEntries
    set incomeEntries [dict get $unmarshalled "Income" "Entries"]

    # expenses
    global expenses
    set expenses [dict get $unmarshalled "Expenses" "Total"]
    global expensesEntries
    set expensesEntries [dict get $unmarshalled "Expenses" "Entries"]

    # balance
    global balance
    set balance [dict get $unmarshalled "Balance"]
}

# ### Main Page ###

# top menubar
option add *tearOff 0; # prevent some weird stuff on the menues

set m .menubar

menu $m
. configure -menu $m

menu $m.file
$m add cascade -menu $m.file -label File
$m.file add command -label "Refresh" -command {"refresh" $filepath}
$m.file add command -label "Close" -command "closeWindow"

proc closeWindow {} {
    exit 0
}

# body

# make outer frame fill the window
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

ttk::frame .body -padding "5 5 5 5"
grid .body -column 0 -row 0 -sticky nsew

# make body fill length
grid columnconfigure .body 0 -weight 1

# treasury
set savingsTitle "Savings"
set freeTitle "Free"
global savings; set savings 0
global free; set free 0
set xpadding 10

ttk::frame .body.treasury -borderwidth 1 -relief solid
ttk::label .body.treasury.savingsTitle -textvariable savingsTitle
ttk::label .body.treasury.freeTitle -textvariable freeTitle
ttk::label .body.treasury.savings -textvariable savings
ttk::label .body.treasury.free -textvariable free 

grid .body.treasury -column 0 -row 0 -sticky news
grid .body.treasury.savingsTitle -column 0 -row 0 -sticky nw -padx $xpadding
grid .body.treasury.freeTitle -column 1 -row 0 -sticky nw -padx $xpadding
grid .body.treasury.savings -column 0 -row 1 -sticky nw -padx $xpadding
grid .body.treasury.free -column 1 -row 1 -sticky nw -padx $xpadding

# income
set incomeTitle "Income"
global income; set income 0
global incomeEntries

ttk::frame .body.income -borderwidth 1 -relief solid
ttk::label .body.income.title -textvariable incomeTitle
ttk::label .body.income.value -textvariable income
tk::listbox .body.income.entries -yscrollcommand ".body.income.scroll set" -height 5
ttk::scrollbar .body.income.scroll -command ".body.income.entries yview" -orient vertical

grid .body.income -column 0 -row 1 -sticky news
grid .body.income.title -column 0 -row 0
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
tk::listbox .body.expenses.entries -yscrollcommand ".body.expenses.scroll set" -height 5
ttk::scrollbar .body.expenses.scroll -command ".body.expenses.entries yview" -orient vertical

grid .body.expenses -column 0 -row 2 -sticky news
grid .body.expenses.title -column 0 -row 0
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

grid .body.balance -column 0 -row 3 -sticky news
grid .body.balance.title -column 0 -row 0
grid .body.balance.value -column 1 -row 0

# #####################

refresh $filepath
