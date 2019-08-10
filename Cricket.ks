// Cricket rocket 

// declare desiredApoapsis to 160000.
// declare desiredHeading to 90.

declare function printAndLog 
{ 
    parameter text.
    print text.
    log time + text to log.txt.
}

declare function LogIt
{
    parameter text.
    log time + text to log.txt.
}

declare function DataDump
{
    
    log "--------- " + time:clock + "---------" to "DataDumpFile.txt".  
    log time:clock + " Altitude: " + Ship:altitude to "DataDumpFile.txt".
    log time:clock + " Orbital Velocity: " + Ship:velocity to "DataDumpFile.txt".
    log time:clock + " Vertical Speed: " + Ship:verticalspeed to "DataDumpFile.txt".
    log time:clock + " MaxThrust: " + Ship:maxthrust to "DataDumpFile.txt".
    log time:clock + " Mass: " + Ship:mass to "DataDumpFile.txt".
    log time:clock + " Heading: " + Ship:heading to "DataDumpFile.txt".
    log time:clock + " Q: " + Ship:q to "DataDumpFile.txt".
}

LogIt("-------------------------------------------------------").
LogIt("------------------ [Beginning log] --------------------").
LogIt("-------------------------------------------------------").

// declare IsIgnited to 0.
// declare IsLiftedOff to 0.
// declare ignitionTime to time + 10000.
// declare liftOffTime to time + 10000.
// declare abortArmed to 0.

declare runmode to 100.

on runmode 
{
	printAndLog("runmode changed to " + runmode).
	return true.
}

declare dumpTime to time.

when time > dumptime + 0.5 then 
{
    DataDump().
    set dumpTime to time.
    return true.
}

declare lastAltitude to 0.

when lastaltitude < altitude - 5000 and verticalSpeed > 0 then 
{
    set lastAltitude to lastaltitude + 5000.
    printAndLog(lastaltitude).
    return true.
}

when lastaltitude > altitude + 5000 and verticalSpeed < 0 then 
{
    set lastAltitude to lastaltitude - 5000.
    printAndLog(lastaltitude).
    return true.
}    


// when ship:verticalspeed < -1 and abortArmed = 1 then
// {
// 	printAndLog("descent detected during ascent phase. Aborting").
// 	set runmode to 999. // Ship is falling. Abort.
//     if altitude < 50000 { return true.}
//     else {return false.}
// }

// when Ship:FACING:FOREVECTOR:Y < 0  and abortArmed = 1 and altitude < 5000 then 
// {
// 	printAndLog("Detected nose facing down during ascent phase. Aborting").
// 	set runmode to 999. // Ship is pointed down. Abort.
//     if altitude < 50000 { return true.}
//     else {return false.}
// }

// when ship:verticalspeed < 0 and abortArmed = 1 and time > liftofftime + 2 then
// {
// 	printAndLog("descent or hover detected during ascent phase. Aborting").
// 	set runmode to 999. // Ship is falling. Abort.
//     if altitude < 50000 { return true.}
//     else {return false.}
// }


 
until runmode = 0
{   
    if runmode = 100
    {
        lock throttle to 1.
        lock steering to up.
        wait 3.
        stage. //Start engine
        // set ignitionTime to time.
        // set abortArmed to 1.
        set runmode to 200.
        
    }

    else if runmode = 200
    {
        wait 1.
        stage. // Release clamp. //Fire Tiny Tim booster
        // set liftOffTime to time. 
        set runmode to 300.
    }

    else if runmode = 300
    {
       wait 0.8.
       stage. // Decouple Tiny Tim booster
       set runmode to 800.
    }

   else if runmode = 800
   {
       printAndLog("beginning coast phase.").
       wait until ship:verticalSpeed < 0.
       {
            printAndLog("Negative vertical speed detected").
            printAndLog("Vertical speed: " + ship:verticalSpeed).
            wait 5.
            set runmode to 900.
       }
   } 

    else if runmode = 900
    {
        printAndLog("Arming chutes").
        stage. // Arm chutes
        set runmode to 0.
    }

    else if runmode = 999
    {
        printAndLog("aborting.").
        toggle abort.
        set runmode to 0.
    }

    wait 0.
}