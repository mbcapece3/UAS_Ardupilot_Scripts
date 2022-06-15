-- Penn State UAS Comms Loss Failsafe for AUVSI SUAS Competition
-- Will result in flight termination in the event of communications loss

-- Use with Standard RC Failsafe, Advanced RC Failsafe, and Standard GCS Failsafe activated
-- Note: UPON REAQUIRING GCS SIGNAL, YOU MUST MANUALLY SWITCH INTO AUTO TO AVOID TERMINATION!!!


KillTime = 30 -- seconds after RTL initiated for termination


Mode_RTL = 11 

AFS_Enabled = param:get('AFS_ENABLE')  --Is AFS Enabled? 1 or 0
CH_FLTMODE = param:get('FLTMODE_CH') 
FLTMODE_MIN_PWM = param:get('RC8_MIN') --Minimum PWM Value of flight mode chanel. MAKE SURE THIS IS SET FOR RTL!!!!!!!!! 

FailTime = 0 -- initialize time of failure

function checkGCS() 

    if arming:is_armed() and AFS_Enabled then

        local modeNum = vehicle:get_mode()
        CURR_FLTMODE_PWM  = rc:get_pwm(CH_FLTMODE)

        if modeNum == Mode_RTL and CURR_FLTMODE_PWM ~= FLTMODE_MIN_PWM then
            IS_FAIL = true
        else
            IS_FAIL = false
        end

        if IS_FAIL and FailTime == 0 then
            FailTime = millis():tofloat() * .001  --Initial time of failure
        end

        if IS_FAIL then
            RTLTime =  millis():tofloat() * .001 - FailTime  --Checks time since failure
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