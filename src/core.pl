systemAssessment(SystemId, Recyclability, EnergyConsumption, CarbonEmissions) :-
    systemRecyclability(SystemId, Recyclability),
    systemEnergyConsumption(SystemId, EnergyConsumptionPerStep, EnergyConsumption), 
    systemCarbonEmissions(EnergyConsumptionPerStep, _, CarbonEmissions).

systemRecyclability(SystemId, Score) :-
    system(SystemId, EquipmentIds, SubstitutionEquipment), append(EquipmentIds, SubstitutionEquipment, AllEquipmentIds),
    findall(R,( member(E, AllEquipmentIds), equipment(E, _, no, R, _, _)), Rs), sumlist(Rs, TotR),
    length(Rs, N), Score is TotR/N * 100.

systemEnergyConsumption(SystemId, (InitialEnergy, UsageEnergy, FinalEnergy), EnergyConsumption) :-
    system(SystemId, EquipmentIds, SubstitutionEquipment),
    append(EquipmentIds, SubstitutionEquipment, AllEquipmentIds),
    initialEnergy(AllEquipmentIds, 0, InitialEnergy),
    usageEnergy(EquipmentIds, 0, UsageEnergy),
    finalEnergy(AllEquipmentIds, 0, FinalEnergy),
    EnergyConsumption is InitialEnergy + UsageEnergy + FinalEnergy.

initialEnergy([E|Es], OldEnergy, NewEnergy) :-
    equipment(E, _, _, _, ProductionEnergyKWh, _),
    TmpEnergy is OldEnergy + ProductionEnergyKWh,
    initialEnergy(Es, TmpEnergy, NewEnergy).
initialEnergy([], E, E).

usageEnergy([E|Es], OldEnergy, NewEnergy) :-
    equipment(E, Type, _, _, _, _), powerProfile(Type, Power), 
    lifecycle(H), lifecycleInHours(H, LifecyleHours),
    Energy is Power * LifecyleHours, TmpEnergy is OldEnergy + Energy,
    usageEnergy(Es, TmpEnergy, NewEnergy).
usageEnergy([],E,E).

finalEnergy([E|Es], OldEnergy, NewEnergy) :-
    equipment(E, _, no, _, _, DismantlementEnergyKWh),
    TmpEnergy is OldEnergy + DismantlementEnergyKWh,
    finalEnergy(Es, TmpEnergy, NewEnergy).
finalEnergy([E|Es], OldEnergy, NewEnergy) :-
    equipment(E, _, yes, _, _, _),
    finalEnergy(Es, OldEnergy, NewEnergy).
finalEnergy([], E, E).

systemCarbonEmissions((InitialEnergy, UsageEnergy, FinalEnergy), (Ci, Cu, Cf), CarbonEmissions) :-
    transport(i,Ti), carbonIntensity(i,Ai), Ci is InitialEnergy * Ai/Ti,
    transport(u,Tu), carbonIntensity(u,Au), Cu is UsageEnergy * Au/Tu,
    transport(f,Tf), carbonIntensity(f,Af), Cf is FinalEnergy * Af/Tf,
    CarbonEmissions is Ci + Cu + Cf.

lifecycleInHours(Years, Hours) :- 
    lifecycle(Years), 
    Hours is Years * 8760.