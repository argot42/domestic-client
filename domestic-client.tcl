#!/usr/bin/tclsh

package require Tk
package require json;   # using tcllib

# arguments
if { $argc < 1 } {
    puts stderr "usage: $argv0 <jsonfile>"
    exit 1
}
set filepath [lindex $argv 0]

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
ttk::frame .body -padding "3 3 12 12"
grid .body -column 0 -row 0 -sticky nsew

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

grid .body.treasury -column 0 -row 0 -sticky new
grid .body.treasury.savingsTitle -column 0 -row 0 -sticky nw -padx $xpadding
grid .body.treasury.freeTitle -column 1 -row 0 -sticky nw -padx $xpadding
grid .body.treasury.savings -column 0 -row 1 -sticky nw -padx $xpadding
grid .body.treasury.free -column 1 -row 1 -sticky nw -padx $xpadding

# income
set incomeTitle "Income"
global income; set income 0

ttk::frame .body.income -borderwidth 1 -relief solid
ttk::label .body.income.title -textvariable incomeTitle
ttk::label .body.income.value -textvariable income

grid .body.income -column 0 -row 1 -sticky ew
grid .body.income.title -column 0 -row 0
grid .body.income.value -column 1 -row 0

# expenses
set expensesTitle "Expenses"
global expenses; set expenses 0

ttk::frame .body.expenses -borderwidth 1 -relief solid
ttk::label .body.expenses.title -textvariable expensesTitle
ttk::label .body.expenses.value -textvariable expenses

grid .body.expenses -column 0 -row 2 -sticky ew
grid .body.expenses.title -column 0 -row 0
grid .body.expenses.value -column 1 -row 0

# balance
set balanceTitle "Net Gain"
global balance; set balance 0

ttk::frame .body.balance -borderwidth 1 -relief solid
ttk::label .body.balance.title -textvariable balanceTitle
ttk::label .body.balance.value -textvariable balance

grid .body.balance -column 0 -row 3 -sticky ew
grid .body.balance.title -column 0 -row 0
grid .body.balance.value -column 1 -row 0

# #####################

refresh $filepath
