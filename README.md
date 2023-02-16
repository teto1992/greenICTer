This prototype implements a simplified version of the model by [Drouant et al. (2014)](https://www.sciencedirect.com/science/article/pii/S0140366414000218) to estimate energy consumption and carbon emission of ICT systems. It is entirely written in the declarative logic programming language Prolog, which makes very readable and concise (the core of the prototype is less than 50 lines of code).

# Model

We declare ICT systems (see the `data/lan.pl` file as an example) via facts like:

```prolog
% system(Id, EquipmentIds, ReplacementEquipmentIds).
system(system1, [switch1, link1, link2], [switch1bis, link2bis]).
```

listing the identifiers of the main equipment and of replacement equipment used throughout the system lifecycle.

Each piece of equipment is specified via facts like: 

```prolog
% equipment(Id, TypeAndParams, IsReusable?, RecyclabilityPercentage, ProductionEnergyKWh, DismantlementEnergyKWh).
equipment(switch1, (switch, 2, [0.1, 0.1], 0.050, 0.015, 0.006), no, 0.7, 750, 400).
equipment(link1, link, yes, 0.9, 1, 1).
```

and its power profile via predicates like

```prolog
% powerProfile(TypeAndParams, Power).
powerProfile((switch, TotalPorts, ActivePortLoads, IdlePower, ActivePortPower, IdlePortPower), P) :-
    switchPowerIncrement(D), powerForActivePorts(ActivePortLoads, D, PowerIncrement),
    length(ActivePortLoads, ActivePorts), IdlePorts is TotalPorts - ActivePorts,        % number of idle ports
    P is IdlePower + PowerIncrement * ActivePortPower + IdlePorts * IdlePortPower.

powerForActivePorts([P|Ps], D, R) :-
    powerForActivePorts(Ps, D, TmpR),
    RP is min(1,D*P), R is TmpR + RP.
powerForActivePorts([], _, 0).
```

that give a type and the associated parameters of a piece of equipment to compute the absorbed Power according to some predefined model (the above is taken from [Reviriego et al. (2012)][https://ieeexplore.ieee.org/iel5/6260982/6266874/06266897.pdf]).

Last, the model enables specifying the lifecycle duration (in years), the average carbon intensity associated to the design and production, usage, and end-of-life steps and the energetic cost of energy transport as in:

```prolog

lifecycle(3). % lifecycle(Years).

carbonIntensity(i, 0.389). % carbonIntensity(kgCO2/kWh).
carbonIntensity(u, 0.389). 
carbonIntensity(f, 0.389). 

transport(_, 0.95). % energetic cost of energy transport

```

# Instructions

To run the prototype and assess the ecological footprint of your ICT systems:

1. Download and install [SWI-Prolog]https://www.swi-prolog.org/download/stable)
2. Open a terminal and issue the command `swipl main.pl` from the root directory of the project
3. Query the Prolog engine by issueing queries like:

```prolog
?- systemAssessment(system1).
```
The result on the LAN example will look like:

```prolog
Architecture: system1
Recyclability: 76.7%
Energy consumption: 4406.4 kWh
         Ei = 1503.0
         Eu = 2102.4
         Ef = 801.0
Carbon emissions: 1804.3 kgCO2-eq
         Ci = 615.4
         Cu = 860.9
         Cf = 328.0
true .
```