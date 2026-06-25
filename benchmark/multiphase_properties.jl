function initialize_groups!(Suite::BenchmarkGroup)
    Suite["bubble_temperature"] = BenchmarkGroup()
    Suite["bubble_temperature"]["default"] = BenchmarkGroup()

    Suite["dew_temperature"] = BenchmarkGroup()
    Suite["dew_temperature"]["default"] = BenchmarkGroup()

    Suite["tp_flash"] = BenchmarkGroup()
    Suite["tp_flash"]["default"] = BenchmarkGroup()

    Suite["bubble_pressure"] = BenchmarkGroup()
    Suite["bubble_pressure"]["ActivityBubblePressure"] = BenchmarkGroup()

    Suite["dew_pressure"] = BenchmarkGroup()
    Suite["dew_pressure"]["ActivityDewPressure"] = BenchmarkGroup()

    Suite["saturation_temperature"] = BenchmarkGroup()
    Suite["saturation_temperature"]["default"] = BenchmarkGroup()

    Suite["saturation_pressure"] = BenchmarkGroup()
    Suite["saturation_pressure"]["default"] = BenchmarkGroup()

    Suite["PH.temperature"] = BenchmarkGroup()
    Suite["PH.temperature"]["two-phase"] = BenchmarkGroup()
    Suite["PH.temperature"]["liquid-phase"] = BenchmarkGroup()
    Suite["PH.temperature"]["vapour-phase"] = BenchmarkGroup()

    Suite["PH.entropy"] = BenchmarkGroup()
    Suite["PH.entropy"]["two-phase"] = BenchmarkGroup()
    Suite["PH.entropy"]["liquid-phase"] = BenchmarkGroup()
    Suite["PH.entropy"]["vapour-phase"] = BenchmarkGroup()

    Suite["volume"] = BenchmarkGroup()
    Suite["volume"]["liquid-phase"] = BenchmarkGroup()
    Suite["volume"]["vapour-phase"] = BenchmarkGroup()

    Suite["enthalpy"] = BenchmarkGroup()
    Suite["enthalpy"]["liquid-phase"] = BenchmarkGroup()
    Suite["enthalpy"]["vapour-phase"] = BenchmarkGroup()

    Suite["isobaric_heat_capacity"] = BenchmarkGroup()
    Suite["isobaric_heat_capacity"]["liquid-phase"] = BenchmarkGroup()
    Suite["isobaric_heat_capacity"]["vapour-phase"] = BenchmarkGroup()

    Suite["speed_of_sound"] = BenchmarkGroup()
    Suite["speed_of_sound"]["liquid-phase"] = BenchmarkGroup()
    Suite["speed_of_sound"]["vapour-phase"] = BenchmarkGroup()

    Suite["joule_thomson_coefficient"] = BenchmarkGroup()
    Suite["joule_thomson_coefficient"]["vapour-phase"] = BenchmarkGroup()

    Suite["mean_ionic_activity_coefficient"] = BenchmarkGroup()
    Suite["mean_ionic_activity_coefficient"]["default"] = BenchmarkGroup()

    Suite["osmotic_coefficient"] = BenchmarkGroup()
    Suite["osmotic_coefficient"]["default"] = BenchmarkGroup()

    Suite["osmotic_coefficient_sat"] = BenchmarkGroup()
    Suite["osmotic_coefficient_sat"]["default"] = BenchmarkGroup()
    nothing
end

function add_vle_benchmarks!(Suite::BenchmarkGroup, models, p, z, fluid_label)
    for (model_name, model) in models
        Tb = bubble_temperature(model, p, z)[1]
        Td = dew_temperature(model, p, z)[1]
        Tf = (Tb + Td) / 2

        Suite["bubble_temperature"]["default"][model_name] = BenchmarkGroup()
        Suite["bubble_temperature"]["default"][model_name][fluid_label] = @benchmarkable bubble_temperature($model, $p, $z)

        Suite["dew_temperature"]["default"][model_name] = BenchmarkGroup()
        Suite["dew_temperature"]["default"][model_name][fluid_label] = @benchmarkable dew_temperature($model, $p, $z)

        Suite["tp_flash"]["default"][model_name] = BenchmarkGroup()
        Suite["tp_flash"]["default"][model_name][fluid_label] = @benchmarkable tp_flash($model, $p, $Tf, $z)
    end
    nothing
end

function add_activity_pressure_benchmarks!(Suite::BenchmarkGroup, models, p, z, fluid_label)
    bubble_method = ActivityBubblePressure()
    dew_method = ActivityDewPressure()

    for (model_name, model) in models
        Tb = bubble_temperature(model, p, z)[1]
        Td = dew_temperature(model, p, z)[1]
        T = (Tb + Td) / 2

        Suite["bubble_pressure"]["ActivityBubblePressure"][model_name] = BenchmarkGroup()
        Suite["bubble_pressure"]["ActivityBubblePressure"][model_name][fluid_label] = @benchmarkable bubble_pressure($model, $T, $z, $bubble_method)

        Suite["dew_pressure"]["ActivityDewPressure"][model_name] = BenchmarkGroup()
        Suite["dew_pressure"]["ActivityDewPressure"][model_name][fluid_label] = @benchmarkable dew_pressure($model, $T, $z, $dew_method)
    end
    nothing
end

function add_all_benchmarks!(Suite::BenchmarkGroup)
    initialize_groups!(Suite)
    common = BenchmarkSystems.common
    common_label = join(common.components, "/")

    m_pr = PR(common.components; idealmodel=ReidIdeal)
    m_tcpr = tcPR(common.components; idealmodel=ReidIdeal)
    m_vtpr = VTPR(common.components; idealmodel=ReidIdeal)
    m_cpa = CPA(common.components; idealmodel=ReidIdeal, assoc_options=AssocOptions(combining=:esd))
    m_cksaft = CKSAFT(common.components; idealmodel=ReidIdeal)
    m_saftvrmie = SAFTVRMie(common.components; idealmodel=ReidIdeal)
    m_saftgammamie = SAFTgammaMie(common.saftgammamie_components; idealmodel=ReidIdeal)
    m_nrtl = NRTL(common.components; puremodel=m_pr)
    m_unifac = UNIFAC(common.components; puremodel=m_pr)
    m_nrtl_pr = CompositeModel(common.components; liquid=m_nrtl, fluid=m_pr)

    common_models = (("PR", m_pr), ("tcPR", m_tcpr), ("VTPR", m_vtpr), ("CPA", m_cpa), ("CKSAFT", m_cksaft), ("SAFTVRMie", m_saftvrmie), ("SAFTgammaMie", m_saftgammamie), ("NRTL", m_nrtl), ("UNIFAC", m_unifac), ("NRTL_PR", m_nrtl_pr))
    common_activity_models = (("NRTL", m_nrtl), ("UNIFAC", m_unifac), ("NRTL_PR", m_nrtl_pr))

    add_vle_benchmarks!(Suite, common_models, common.p, common.z, common_label)
    add_activity_pressure_benchmarks!(Suite, common_activity_models, common.p, common.z, common_label)
    add_ph_benchmarks!(Suite, common_models, common.p, common.z, common_label)
    add_common_bulk_benchmarks!(Suite, common_models, common.p, common.z, common_label)

    gerg2008 = BenchmarkSystems.gerg2008
    gerg2008_label = join(gerg2008.components, "/")
    m_gerg2008 = GERG2008(gerg2008.components)
    gerg2008_models = (("GERG2008", m_gerg2008),)

    add_vle_benchmarks!(Suite, gerg2008_models, gerg2008.p, gerg2008.z, gerg2008_label)
    add_ph_benchmarks!(Suite, gerg2008_models, gerg2008.p, gerg2008.z, gerg2008_label)
    add_gas_bulk_benchmarks!(Suite, "GERG2008", m_gerg2008, gerg2008.p, gerg2008.T, gerg2008.z, gerg2008_label)

    iapws95 = BenchmarkSystems.iapws95
    iapws95_label = join(iapws95.components, "/")
    m_iapws95 = IAPWS95()

    add_pure_saturation_benchmarks!(Suite, "IAPWS95", m_iapws95, iapws95.p, iapws95_label)
    add_pure_ph_benchmarks!(Suite, "IAPWS95", m_iapws95, iapws95.p, iapws95.z, iapws95_label)
    add_pure_bulk_benchmarks!(Suite, "IAPWS95", m_iapws95, iapws95.p, iapws95.z, iapws95_label)

    epcsaft = BenchmarkSystems.epcsaft
    epcsaft_label = join([epcsaft.solvents; epcsaft.ions], "/")
    m_epcsaft = ePCSAFT(epcsaft.solvents, epcsaft.ions)

    add_electrolyte_benchmarks!(Suite, "ePCSAFT", m_epcsaft, epcsaft.p, epcsaft.T, epcsaft.z, epcsaft.m, epcsaft_label)
    nothing
end
