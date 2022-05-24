# Calendar Sync template
This repository contains a template for a Microsoft Power Automate Flow that can be used to sync events between two Office 365 calendar.

All the magic is present in the `scheduled-calendar-sync-template` folder. The flow contains some variables that needs to be substituted, namely `<email>`, `<source-calendar>` and `<target-calendar>`. To handle this there is a `substitution.sh` script to do this for you.

## How this works
The flow is built to run without your involvement, but you need to share the calendar you wish to copy events from to your current account.

The flow is also build to self-heal, so if any event is out of sync it will be resynced next iteration.

Example:
You have a Calendar A and wish to copy events from Calendar B. In order to achieve this you need to go to Calendar B and share that calendar to your Calendar A account. It's possible (even encouraged) to choose to only share statuses between the accounts.
If you _also_ wish to sync Calendar A events to Calendar B then you need to do the same thing sharing Calendar A to your Calendar B account. The flow should then be imported both in Calendar A Power Automate and Calendar B Power Automate. Note that if you want two-way sync, you need to run the substitute script twice.


## How to set it up
Setup: You want to copy events from Calendar B into Calendar A

1. Share calendar <br>Go to Calendar B and share the calendar to the Calendar A account. It's possible to share only status information.
2. Find out calendar ids<br>Now we need to know the calendar ids, this is done with graph explorer. <br>
  a) Go to https://developer.microsoft.com/en-us/graph/graph-explorer# and login with Calendar A account<br>
  b) Under Sample queries execute `GET all my calendars` (under Outlook Calendar section) <br>
  c) In the output copy "id" from Calendar A (usually named just "Calendar"), and copy "id" from Calendar B
3. Run `substitute.sh` script. Note: `-t` is the id of Calendar A and `-s` is the id of Calendar B<br>
`substitute.sh -e <email-connected-to-calendar-A> -t <id-for-calendar-A> -s <id-for-calendar-B>`<br>  
Example:<br>
`substitute.sh -e erica.edholm@omegapoint.se -t AAMkADRmZTI0NmNiLTMyNDUtNDk1Yi04MTJkLWQ5OTYzMGMxZmFjMwBGAAAAAABhxLwFLBSnT5Bn24RLPLh5BwAoipq4bgqGR6BQclPKEG6vAAAAIiA8AAD-5ca2-udDRrE5W13bPydcAAAkY20VAAA= -s AAMkADRmZTI0NmNiLTMyNDUtNDk1Yi04MTJkLWQ5OTYzMGMxZmFjMwBGAAAAAABhxLwFLBSnT5Bn24RLPLh5BwAoipq4bgqGR6BQclPKEG6vAAAAIiA8AAD-5ca2-udDRrE5W13bPydcAAYUjHdzAAA=`

This will create a folder containing the substitutions as well as create a zip-file that will be used to import the flow into Calendar A.

4. Go to Power Automate in Calendar A account, and choose "My flows" on the left panel
5. In the top, press Import
6. Press Upload and choose the zip file
7. In the next step you need to connect the email to your office account. Press the "Setup during import" link and press your email in the window that shows up. Press save.
8. Press Import
9. When the import is done, there is a link "Open flow" on the top of the page, press it to show your flow.
10. Ensure that the flow has been imported correctly, a hint is to check the "Flow checker" button on the right. It will tell you if anything is wrong. If you have errors you might have copied some values wrong in the substitution script. Redo the process or manually fix the issues.
11. To use your flow, press "Save", back arrow and then "Turn on"  button to enable the flow.
If you are exited you can press the `Run` button so that the flow is triggered straight away or you can wait until the first run is triggered (each 6 hours)
If you need to sync events from Calendar A to Calendar B, do the same steps but the other way around and import the flow into Calendar B account.

## Flow chart
In an attempt to explain the flow, here is a flow-chart representation

```mermaid
flowchart TD
  A(Trigger each 10 hours) -->B("Get all source events <br>from today with `showAs` == busy");
  B ---> C("Get all target events<br>from today");
  C ---> D{"For source event x<br>Is x last event?"}
  subgraph &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbspCreate and update events
    D --No--> E("Filter out replicated event in target list")
    E ----> F{"Replicated event found?"}
    F --Yes-->G{"Is start- and end-time <br>same between x and replicated event?"}
    G --Yes-->H{"Does any conflicting events exist?"}
    H --Yes-->I("Do nothing")
    H --No-->J("Remove conflict from title")
    F --No-->K{"Does any conflicting events exist?"}
    K --Yes-->L(Create event with conflict<br>Send email about conflicts)
    K --No-->M(Create new event)
    G --No-->N{Does any conflicting events exist?}
    N --Yes-->O("Update event with conflict<br>Send email about conflicts")
    N --No-->P("Update event with new start- and end-time")
  end
    D --Yes--> Q(Filter out replicated events from target list)
    P----> Q
    O----> Q
    L ----> Q
    M ----> Q
    I ----> Q
    J ----> Q
    Q ---> R{"For target event y<br>Is y last event?"}
  subgraph &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbspDelete target events no longer in source
    R --No--> S("Find matching non-replicated event(s) in source list, <br>matching start- and end-time with event y")
    S--->T{"Does any conflicting event exists?"}
    T--No-->U("Delete event (since source event no longer exists)")
    T--Yes-->V("Does replicated event exist among conflicting events?")
    V--Yes-->W("Do nothing")
    V--No-->X("Delete replicated event y")
  end
  U--->Y
  W--->Y
  R--Yes-->Y
  X--->Y("Success")
