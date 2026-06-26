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
        Tb = guard_benchmark(benchmark_path("bubble_temperature", "default", model_name, fluid_label)) do
            bubble_temperature(model, p, z)[1]
        end
        Td = guard_benchmark(benchmark_path("dew_temperature", "default", model_name, fluid_label)) do
            dew_temperature(model, p, z)[1]
        end

        register_benchmark!(Suite["bubble_temperature"]["default"], model_name, fluid_label,
            benchmark_path("bubble_temperature", "default", model_name, fluid_label),
            () -> bubble_temperature(model, p, z),
            () -> @benchmarkable bubble_temperature($model, $p, $z))

        register_benchmark!(Suite["dew_temperature"]["default"], model_name, fluid_label,
            benchmark_path("dew_temperature", "default", model_name, fluid_label),
            () -> dew_temperature(model, p, z),
            () -> @benchmarkable dew_temperature($model, $p, $z))

        if !isnothing(Tb) && !isnothing(Td)
            Tf = (Tb + Td) / 2
            register_benchmark!(Suite["tp_flash"]["default"], model_name, fluid_label,
                benchmark_path("tp_flash", "default", model_name, fluid_label),
                () -> tp_flash(model, p, Tf, z),
                () -> @benchmarkable tp_flash($model, $p, $Tf, $z))
        end
    end
    nothing
end

function add_activity_pressure_benchmarks!(Suite::BenchmarkGroup, models, p, z, fluid_label)
    bubble_method = ActivityBubblePressure()
    dew_method = ActivityDewPressure()

    for (model_name, model) in models
        Tb = guard_benchmark(benchmark_path("bubble_pressure", "ActivityBubblePressure", model_name, fluid_label)) do
            bubble_temperature(model, p, z)[1]
        end
        Td = guard_benchmark(benchmark_path("dew_pressure", "ActivityDewPressure", model_name, fluid_label)) do
            dew_temperature(model, p, z)[1]
        end

        if !isnothing(Tb) && !isnothing(Td)
            T = (Tb + Td) / 2

            register_benchmark!(Suite["bubble_pressure"]["ActivityBubblePressure"], model_name, fluid_label,
                benchmark_path("bubble_pressure", "ActivityBubblePressure", model_name, fluid_label),
                () -> bubble_pressure(model, T, z, bubble_method),
                () -> @benchmarkable bubble_pressure($model, $T, $z, $bubble_method))

            register_benchmark!(Suite["dew_pressure"]["ActivityDewPressure"], model_name, fluid_label,
                benchmark_path("dew_pressure", "ActivityDewPressure", model_name, fluid_label),
                () -> dew_pressure(model, T, z, dew_method),
                () -> @benchmarkable dew_pressure($model, $T, $z, $dew_method))
        end
    end
    nothing
end

function add_all_benchmarks!(Suite::BenchmarkGroup)
    initialize_groups!(Suite)
    common = BenchmarkSystems.common
    common_label = join(common.components, "/")

    common_models = Tuple{String,Any}[]

    m_pr = push_model!(common_models, "PR", benchmark_path("models", "PR", common_label)) do
        PR(common.components; idealmodel=ReidIdeal)
    end
    push_model!(common_models, "tcPR", benchmark_path("models", "tcPR", common_label)) do
        tcPR(common.components; idealmodel=ReidIdeal)
    end
    push_model!(common_models, "VTPR", benchmark_path("models", "VTPR", common_label)) do
        VTPR(common.components; idealmodel=ReidIdeal)
    end
    push_model!(common_models, "CPA", benchmark_path("models", "CPA", common_label)) do
        CPA(common.components; idealmodel=ReidIdeal, assoc_options=AssocOptions(combining=:esd))
    end
    push_model!(common_models, "CKSAFT", benchmark_path("models", "CKSAFT", common_label)) do
        CKSAFT(common.components; idealmodel=ReidIdeal)
    end
    push_model!(common_models, "SAFTVRMie", benchmark_path("models", "SAFTVRMie", common_label)) do
        SAFTVRMie(common.components; idealmodel=ReidIdeal)
    end
    push_model!(common_models, "SAFTgammaMie", benchmark_path("models", "SAFTgammaMie", common_label)) do
        SAFTgammaMie(common.saftgammamie_components; idealmodel=ReidIdeal)
    end
    m_nrtl = isnothing(m_pr) ? nothing : push_model!(common_models, "NRTL", benchmark_path("models", "NRTL", common_label)) do
        NRTL(common.components; puremodel=m_pr)
    end
    m_unifac = isnothing(m_pr) ? nothing : push_model!(common_models, "UNIFAC", benchmark_path("models", "UNIFAC", common_label)) do
        UNIFAC(common.components; puremodel=m_pr)
    end
    m_nrtl_pr = if isnothing(m_pr) || isnothing(m_nrtl)
        nothing
    else
        push_model!(common_models, "NRTL_PR", benchmark_path("models", "NRTL_PR", common_label)) do
            CompositeModel(common.components; liquid=m_nrtl, fluid=m_pr)
        end
    end

    common_activity_models = Tuple{String,Any}[]
    !isnothing(m_nrtl) && push!(common_activity_models, ("NRTL", m_nrtl))
    !isnothing(m_unifac) && push!(common_activity_models, ("UNIFAC", m_unifac))
    !isnothing(m_nrtl_pr) && push!(common_activity_models, ("NRTL_PR", m_nrtl_pr))

    add_vle_benchmarks!(Suite, common_models, common.p, common.z, common_label)
    add_activity_pressure_benchmarks!(Suite, common_activity_models, common.p, common.z, common_label)
    add_ph_benchmarks!(Suite, common_models, common.p, common.z, common_label)
    add_common_bulk_benchmarks!(Suite, common_models, common.p, common.z, common_label)

    gerg2008 = BenchmarkSystems.gerg2008
    gerg2008_label = join(gerg2008.components, "/")
    gerg2008_models = Tuple{String,Any}[]
    m_gerg2008 = push_model!(gerg2008_models, "GERG2008", benchmark_path("models", "GERG2008", gerg2008_label)) do
        GERG2008(gerg2008.components)
    end

    add_vle_benchmarks!(Suite, gerg2008_models, gerg2008.p, gerg2008.z, gerg2008_label)
    add_ph_benchmarks!(Suite, gerg2008_models, gerg2008.p, gerg2008.z, gerg2008_label)
    !isnothing(m_gerg2008) && add_gas_bulk_benchmarks!(Suite, "GERG2008", m_gerg2008, gerg2008.p, gerg2008.T, gerg2008.z, gerg2008_label)

    iapws95 = BenchmarkSystems.iapws95
    iapws95_label = join(iapws95.components, "/")
    m_iapws95 = guard_benchmark(benchmark_path("models", "IAPWS95", iapws95_label)) do
        IAPWS95()
    end

    if !isnothing(m_iapws95)
        add_pure_saturation_benchmarks!(Suite, "IAPWS95", m_iapws95, iapws95.p, iapws95_label)
        add_pure_ph_benchmarks!(Suite, "IAPWS95", m_iapws95, iapws95.p, iapws95.z, iapws95_label)
        add_pure_bulk_benchmarks!(Suite, "IAPWS95", m_iapws95, iapws95.p, iapws95.z, iapws95_label)
    end

    epcsaft = BenchmarkSystems.epcsaft
    epcsaft_label = join([epcsaft.solvents; epcsaft.ions], "/")
    m_epcsaft = guard_benchmark(benchmark_path("models", "ePCSAFT", epcsaft_label)) do
        ePCSAFT(epcsaft.solvents, epcsaft.ions)
    end

    !isnothing(m_epcsaft) && add_electrolyte_benchmarks!(Suite, "ePCSAFT", m_epcsaft, epcsaft.p, epcsaft.T, epcsaft.z, epcsaft.m, epcsaft_label)
    nothing
end
