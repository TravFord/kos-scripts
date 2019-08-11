// Grasshopper rocket 


declare function printAndLog 
{ 
    parameter text.
    print Round(missionTime, 1) + " " + text.
    log Round(missionTime, 1) + " " +  text to log.txt.
}

declare function LogIt
{
    parameter text.
    log Round(missionTime, 1) + " " + text to log.txt.
}

declare function DataDump
{
    
    log "--------- " + time:clock + "---------" to "DataDumpFile.txt".  
    log Round(missionTime, 1) + " " + "Altitude: " + Ship:altitude to "DataDumpFile.txt".
    log Round(missionTime, 1) + " " +  "Orbital Velocity: " + Ship:velocity:orbit:mag to "DataDumpFile.txt".
    log Round(missionTime, 1) + " " +  "Vertical Speed: " + Ship:verticalspeed to "DataDumpFile.txt".
    log Round(missionTime, 1) + " " +  "MaxThrust: " + Ship:maxthrust to "DataDumpFile.txt".
    log Round(missionTime, 1) + " " +  "Mass: " + Ship:mass to "DataDumpFile.txt".
    log Round(missionTime, 1) + " " +  "Heading: " + Ship:heading to "DataDumpFile.txt".
    log Round(missionTime, 1) + " " +  "Q: " + Ship:q to "DataDumpFile.txt".
    log Round(missionTime, 1) + " " +  "Airspeed: " + Ship:Airspeed to "DataDumpFile.txt".
}

LogIt("-------------------------------------------------------").
LogIt("------------------ [Beginning log] --------------------").
LogIt("-------------------------------------------------------").

declare runmode to 100.

on runmode 
{
	printAndLog("runmode changed to " + runmode).
	return true.
}

declare dumpTime to time.

when time > dumptime + 1 then 
{
    DataDump().
    set dumpTime to time.
    return true.
}


// Altitude logging/reporting
declare lastAltitude to 0.

when lastaltitude < altitude - 5000 and verticalSpeed > 0 then 
{
    set lastAltitude to lastaltitude + 5000.
    printAndLog("Altitude " + lastaltitude/1000 + "km").
    return true.
}

when lastaltitude > altitude + 5000 and verticalSpeed < 0 then 
{
    set lastAltitude to lastaltitude - 5000.
    printAndLog("Altitude " + lastaltitude/1000 + "km").
    return true.
}    

declare MaxAlt to 0.
declare MaxSpeed to 0.
declare LastMaxSpeed to 0.
declare LastMaxAlt to 0.
declare LastReading to time.
declare ReadingInterval to 1.

when time - LastReading > ReadingInterval then 
{
    set MaxSpeed to Max(maxspeed, Ship:airSpeed).
    set MaxAlt to Max(MaxAlt, Ship:altitude).
    if  round(MaxSpeed, 0) <> round(LastMaxSpeed, 0) or round(MaxAlt, 0) <> round(LastMaxAlt, 0) 
    {
        LogIt("MaxSpeed: " + Round(MaxSpeed, 1)).
        LogIt("MaxAltitude: " + Round(MaxAlt, 3)).
        set LastReading to time.
    } 
    return true.
}
// Science triggers
// when altitude > 5000 then {toggle ag1. return false.} // low atmo
// when altitude > 51000 then {toggle ag2. return false.} // high atmo
// when altitude > 141000 then {toggle ag3. return false.} // space
// when altitude < 20000 and verticalspeed < -10 then {toggle ag4. return false.} // low atmo again. But, possibly in different biome.
 
until runmode = 0
{   
    if runmode = 100
    {
        lock throttle to 1.
        lock steering to up.
        wait 3.
        stage. //Start engine
        set runmode to 200.
        
    }

    else if runmode = 200
    {
        wait 1.
        stage. // Release clamp. //Fire Tiny Tim booster
        set runmode to 300.
    }

    else if runmode = 300
    {
       wait 0.8.
       stage. // Decouple Tiny Tim booster
       set runmode to 600.
    }

    else if runmode = 600
    {
        if ship:mass < 1.089 // Almost out of fuel in 1st stage
        or ship:maxthrust < 20 // If we messed up the weight, try to salvage the mission by instantly igniting the 2nd stage at 1st stage cutoff to avoid ullage problems.
        {
            set runmode to 650.
        }   
    }

    else if runmode = 650
    {   
        printAndLog("Igniting stage 2").
        stage.
        set runmode to 670.
    }

    else if runmode = 670
    {
        wait 1.
        if ship:maxthrust < 20 // Main engines have cut off
        stage. 
        printAndLog("Main engine cutoff. Stage sep.").
        set runmode to 700.
    }

    else if runmode = 700
    {
        if ship:maxThrust < 1 // Second stage burnout
        or ship:verticalSpeed < 0 // Failsafe
        {
            
            set runmode to 800.
        }
    } 
    else if runmode = 800
    {
       printAndLog("2nd stage engine cutoff. Beginning coast phase.").
       set runmode to 950.
    } 

    else if runmode = 950 
    {
        wait 0.
    }

    else if runmode = 999
    {
        printAndLog("aborting.").
        toggle abort.
        set runmode to 0.
    }

    wait 0.
}