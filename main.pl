:- consult('data/lan.pl').
:- consult('src/core.pl').

systemAssessment(SystemId) :-
    systemRecyclability(SystemId, Recyclability), 
    systemEnergyConsumption(SystemId, (Ei, Eu, Ef), EnergyConsumption), 
    systemCarbonEmissions((Ei, Eu, Ef), (Ci, Cu, Cf), CarbonEmissions),
    write('Architecture: '), write(SystemId), nl,
    write('Recyclability: '), format('~1f', [Recyclability]), write('%'), nl,
    write('Energy consumption: '), format('~1f', [EnergyConsumption]), write(' kWh'), nl,
    write('\t Ei = '), format('~1f', [Ei]), nl,
    write('\t Eu = '), format('~1f', [Eu]), nl,
    write('\t Ef = '), format('~1f', [Ef]), nl,
    write('Carbon emissions: '), format('~1f', [CarbonEmissions]), write(' kgCO2-eq'), nl,
    write('\t Ci = '), format('~1f', [Ci]), nl,
    write('\t Cu = '), format('~1f', [Cu]), nl,
    write('\t Cf = '), format('~1f', [Cf]), nl.