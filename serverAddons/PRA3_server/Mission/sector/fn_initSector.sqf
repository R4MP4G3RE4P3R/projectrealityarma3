#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas

    Description:
    Initialize the

    Parameter(s):
    0: Argument Name <TYPE>

    Returns:
    0: Return Name <TYPE>
*/

GVAR(competingSides) = [];
{
    GVAR(competingSides) pushBack configName _x;
    missionNamespace setVariable [format ["%1_%2",QGVAR(Flag),configName _x], getText (_x >> "flag")];
    missionNamespace setVariable [format ["%1_%2",QGVAR(SideColor),configName _x], getArray (_x >> "color")];
    nil;
} count ("true" configClasses (missionConfigFile >> "BG" >> "sides"));

if (isServer) then {
    [] spawn {
        GVAR(allSectors) = (call EFUNC(common,getLogicGroup)) createUnit ["Logic", [0,0,0], [], 0, "NONE"];
        publicVariable QGVAR(allSectors);
        GVAR(allSectorsArray) = [];


        private _sectors = "true" configClasses (missionConfigFile >> "BG" >> "CfgSectors");

        {
            [configName _x, getArray (_x >> "dependency"),getNumber (_x >> "ticketBleed"),getNumber (_x >> "minUnits"),getArray (_x >> "captureTime"), getText (_x >> "designator")] call FUNC(createSectorLogic);
            nil;
        } count _sectors;
        publicVariable QGVAR(allSectorsArray);
    };
};

{
    [_x] call FUNC(createSectorTrigger);
    nil;
} count GVAR(allSectorsArray);

if (isServer) then {
    GVAR(sectorLoopCounter) = 0;
    [FUNC(loop), 0.1, []] call FUNC(addPerFrameHandler);
    ["sector_side_changed", {
        params ["_sector", "_oldSide", "_newSide"];

        private _marker = _sector getVariable ["marker",""];

        if (_marker != "") then {
            _marker setMarkerColor format["Color%1",_newSide];
        };
    }] call EFUNC(Events,addEventHandler);
};

if (hasInterface) then {
    GVAR(captureStatusPFH) = -1;
    ["sector_entered", {[true,_this select 0] call FUNC(showCaptureStatus);}] call FUNC(events,addEventHandler);

    ["sector_leaved", {[false,_this select 0] call FUNC(showCaptureStatus);}] call FUNC(events,addEventHandler);

    // Todo make Own UI or use BI Task Hint for that and make useage of Task system/ add Better Visualisation(Check Posible use of Markers)
    ["sector_side_changed", {hint format["SECTOR %1 SIDE CHANGED FROM %2 TO %3",_this select 0,_this select 1,_this select 2];}] call FUNC(events,addEventHandler);

    /*
    player addEventHandler ["Respawn", {
        {
            [_x] call FUNC(createSectorTrigger);
            nil;
        } count GVAR(allSectorsArray);
        nil;
    }];
    */
};
