--Flight Mode Numbers:
--Mode_Manual = 0
--Mode_Auto = 10
Mode_RTL = 11
--Mode_Loiter = 12

CH_Throttle = 3  --Throttle Channel
Throttle_FS_PWM = 1000  --PWM Value that throttle drops below with RC loss

FailTime = 0 -- initialize
KillTime = 30 -- seconds after loiter initiated for termination

function checkGCS()

    if arming:is_armed() then

        local modeNum = vehicle:get_mode()

        if modeNum == Mode_RTL and FailTime == 0 then
            FailTime = millis():tofloat() * .001
        end

        if modeNum == Mode_RTL then

            RTLTime =  millis():tofloat() * .001 - FailTime
            gcs:send_text(1,"GCS LOSS: " .. tostring(RTLTime))

            --set initial GCS failsafe here?

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