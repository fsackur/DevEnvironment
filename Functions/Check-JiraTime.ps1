$t = import-csv "C:\Users\mich8638\Downloads\IAWW Issues Work Log Table - 20181221-1334.csv"
$t = $t | ?{$_.'Work Logged By' -eq 'Freddie Sackur'} | select Date, Issue, Summary, Hours
$g = $t | Group Date
$g | Add-Member ScriptProperty "Total" -Value {($this.Group.Hours | Measure-Object -Sum).Sum}
$g | ft Name, Total

<#
Name       Total
----       -----
2018-11-22   6.5
2018-11-23  6.25
2018-11-26  5.74
2018-11-27  6.67
2018-11-28     5
2018-11-29     8
2018-11-30  7.26

2018-12-03  5.34
2018-12-04  7.67
2018-12-05  1.25    *
2018-12-06  1.33    *
2018-12-07   3.5    *

2018-12-10     3
ill
ill
2018-12-13  1.17
mtg

2018-12-17     8
2018-12-18  6.25
2018-12-19  0.75
2018-12-20     5
2018-12-21   0.5
#>