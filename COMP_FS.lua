-- Penn State UAS Comms Loss Failsafe for AUVSI SUAS Competition
-- Will result in flight termination in the event of communications loss

KillTime = 30 -- seconds after loiter initiated for termination

--Test 4


Mode_RTL = 11 -- Mode Number associated with RTL

AFS_Enabled = param:get('AFS_ENABLE')  --Is AFS Enabled? 1 or 0
CH_Throttle = param:get('RCMAP_THROTTLE')  --Throttle Channel Number
Throttle_FS_PWM = param:get('THR_FS_VALUE') --PWM Value that throttle drops below with RC loss

FailTime = 0 -- initialize time of failure

function checkGCS()

    if arming:is_armed() and AFS_Enabled then
        local modeNum = vehicle:get_mode()

        if modeNum == Mode_RTL and FailTime == 0 then
            FailTime = millis():tofloat() * .001
        end

        if modeNum == Mode_RTL then
            RTLTime =  millis():tofloat() * .001 - FailTime
            gcs:send_text(1,"GCS LOSS: " .. tostring(RTLTime))

            if RTLTime >= KillTime then
                param:set_and_save('AFS_TERMINATE', 1)  -- TERMINATES FLIGHT! UNRECOVERABLE!!!
                gcs:send_text(0,"GCS LOSS: TERMINATED!")
            end
        end

        modeNum = vehicle:get_mode()

        if modeNum ~= Mode_RTL then
            FailTime = 0   --Resets Failtime if connection is regained
        end
    else
        FailTime = 0;
    end
    return checkGCS, 1000  --Function repeats every 1000ms (1 second)
end

return checkGCS, 1000

--Add some sort of redundancy check
    -- Currently, any RTL will cause GCS termination to occur after delay. Also termination will occur on the ground, but this could actually be good for testing
--AFS must be enabled for termination to occur, but this specifically uses standard GCS Failsafes. Should I change to REMRSSI and Heartbeat?

--Ideas
    --Use RTL in conjunction with FLTMODE_CH not being RTL
    --Use RTL in conjunction with RC Loss (Throttle failsafe), but this is no different from regular RC failsafe unless i disable rc failsafe and only do them together in this script but thats a bit sketchy
