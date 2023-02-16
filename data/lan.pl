:- discontiguous powerProfile/2.

% lifecycle(Years).
lifecycle(3).
% carbonIntensity(kgCO2/kWh).
carbonIntensity(i, 0.389). 
carbonIntensity(u, 0.389). 
carbonIntensity(f, 0.389). 
% energetic cost of energy transport
transport(_, 0.95).

% system(Id, EquipmentIds, SubstitutionEquipment).
system(system1, [switch1, link1, link2], [switch1bis, link2bis]).
system(system2, [switch1, switch2, link1, link2, link3, link4], [switch1bis, link2bis]).
system(system3, [switch1, switch2, switch3, link1, link2, link3, link4, link5, link6], [switch1bis, link2bis]).

% equipment(Id, TypeAndParams, IsReusable?, RecyclabilityPercentage, ProductionEnergyKWh, DismantlementEnergyKWh).
% system 1
% (switch, TotalPorts, ActivePortLoads, IdlePower, ActivePortPower, IdlePortPower)
equipment(switch1, (switch, 2, [0.1, 0.1], 0.050, 0.015, 0.006), no, 0.7, 750, 400). % it breaks and is replaced by switch1bis
equipment(switch1bis, (switch, 2, [], 0.050, 0.015, 0.006), no, 0.7, 750, 400).
equipment(link1, link, yes, 0.9, 1, 1).
equipment(link2, link, no, 0.9, 1, 1).      % it breaks and is replaced by link2bis
equipment(link2bis, link, yes, 0.9, 1, 1). 

% system 2 (Hp: no active ports almost all the time thanks to spanning tree protocol)
equipment(switch2, (switch, 2, [], 0.050, 0.015, 0.006), no, 0.7, 750, 400).
equipment(link3, link, yes, 0.9, 1, 1).
equipment(link4, link, yes, 0.9, 1, 1).

% system 3 (Hp: no active ports almost all the time thanks to spanning tree protocol)
equipment(switch3, (switch, 2, [], 0.050, 0.015, 0.006), no, 0.7, 750, 400).
equipment(link5, link, yes, 0.9, 1, 1).
equipment(link6, link, yes, 0.9, 1, 1).

% Links power profile: a link does not consume energy when in use.
powerProfile(link,0).

% Switch power profile according to the model by Reviriego et al. (2012) [https://ieeexplore.ieee.org/iel5/6260982/6266874/06266897.pdf]
% increment in power consumption per increment in traffic load per port
switchPowerIncrement(18).

% (switch, TotalPorts, ActivePortLoads, IdlePower, ActivePortPower, IdlePortPower)
powerProfile((switch, TotalPorts, ActivePortLoads, IdlePower, ActivePortPower, IdlePortPower), P) :-
    switchPowerIncrement(D), powerForActivePorts(ActivePortLoads, D, PowerIncrement),
    length(ActivePortLoads, ActivePorts), IdlePorts is TotalPorts - ActivePorts,        % number of idle ports
    P is IdlePower + PowerIncrement * ActivePortPower + IdlePorts * IdlePortPower.

powerForActivePorts([P|Ps], D, R) :-
    powerForActivePorts(Ps, D, TmpR),
    RP is min(1,D*P), R is TmpR + RP.
powerForActivePorts([], _, 0).